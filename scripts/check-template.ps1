[CmdletBinding()]
param(
    [switch]$Json,
    [switch]$Explain,
    [string]$Root
)

$ErrorActionPreference = 'Stop'
if ([string]::IsNullOrWhiteSpace($Root)) {
    $Root = Split-Path -Parent $PSScriptRoot
}
$checkCount = 7
$findings = New-Object System.Collections.ArrayList

function Add-Finding {
    param(
        [Parameter(Mandatory = $true)][string]$Id,
        [Parameter(Mandatory = $true)][string[]]$Details
    )

    [void]$findings.Add([PSCustomObject]@{
            id = $Id
            details = @($Details | Sort-Object -Unique)
        })
}

function Get-RelativePath {
    param(
        [Parameter(Mandatory = $true)][string]$BasePath,
        [Parameter(Mandatory = $true)][string]$Path
    )

    if ($Path.StartsWith($BasePath, [System.StringComparison]::OrdinalIgnoreCase)) {
        return $Path.Substring($BasePath.Length).TrimStart('\')
    }
    return $Path
}

function Get-FileText {
    param([Parameter(Mandatory = $true)][string]$Path)

    return [System.IO.File]::ReadAllText($Path, [System.Text.Encoding]::UTF8)
}

function Test-SkillFrontmatter {
    param(
        [Parameter(Mandatory = $true)][string]$Path,
        [Parameter(Mandatory = $true)][string]$RelativePath
    )

    $text = Get-FileText -Path $Path
    $match = [regex]::Match($text, '\A---\r?\n(?<body>[\s\S]*?)\r?\n---(?:\r?\n|\z)')
    if (-not $match.Success) {
        return @($RelativePath + ': frontmatter boundary is missing or incomplete')
    }

    $problems = New-Object System.Collections.ArrayList
    foreach ($field in @('name', 'description')) {
        $fieldMatch = [regex]::Match($match.Groups['body'].Value, '(?m)^\s*' + $field + '\s*:\s*(?<value>.*?)\s*$')
        $value = ''
        if ($fieldMatch.Success) {
            $value = $fieldMatch.Groups['value'].Value.Trim()
            if ($value.Length -ge 2 -and (($value.StartsWith('"') -and $value.EndsWith('"')) -or ($value.StartsWith("'") -and $value.EndsWith("'")))) {
                $value = $value.Substring(1, $value.Length - 2).Trim()
            }
        }
        if (-not $fieldMatch.Success -or [string]::IsNullOrWhiteSpace($value)) {
            [void]$problems.Add($RelativePath + ': required frontmatter field ' + $field + ' is missing or empty')
        }
    }

    return @($problems)
}

function Test-LiteDefaultDependency {
    param(
        [Parameter(Mandatory = $true)][string]$Path,
        [Parameter(Mandatory = $true)][string]$RelativePath
    )

    $problems = New-Object System.Collections.ArrayList
    $lineNumber = 0
    foreach ($line in Get-Content -LiteralPath $Path -Encoding UTF8) {
        $lineNumber++
        $lower = $line.ToLowerInvariant()
        foreach ($reference in @('.agent/state_machine.md', '.agent/state.md')) {
            if (-not $lower.Contains($reference)) {
                continue
            }

            $upgradeOnly = $lower -match '(after|once|when|only after).*upgrade.*standard|standard.*upgrade'
            $negativeRule = $lower -match '\bdo not\b'
            $defaultRead = $lower -match '\b(read|load|maintain|initialize|update)\b'
            if ($defaultRead -and -not $upgradeOnly -and -not $negativeRule) {
                [void]$problems.Add($RelativePath + ':' + $lineNumber + ': default dependency on ' + $reference)
            }
        }
    }

    return @($problems)
}

function Write-Result {
    param(
        [Parameter(Mandatory = $true)][string]$ResolvedRoot,
        [Parameter(Mandatory = $true)][int]$Checks,
        [Parameter(Mandatory = $true)][AllowEmptyCollection()][System.Collections.ArrayList]$Errors,
        [switch]$AsJson,
        [switch]$WithExplanation
    )

    $passed = $Errors.Count -eq 0
    if ($AsJson) {
        $result = [PSCustomObject]@{
            root = $ResolvedRoot
            passed = $passed
            checks = $Checks
            errors = @($Errors)
        }
        [Console]::Out.WriteLine(($result | ConvertTo-Json -Compress -Depth 5))
        return
    }

    if ($passed) {
        Write-Output ('PASS: ' + $Checks + ' checks')
        if ($WithExplanation) {
            Write-Output 'All deterministic template checks passed.'
        }
        return
    }

    Write-Output ('FAIL: ' + $Errors.Count)
    foreach ($error in $Errors) {
        Write-Output ('- ' + $error.id)
        if ($WithExplanation) {
            foreach ($detail in $error.details) {
                Write-Output ('  - ' + $detail)
            }
        }
    }
}

try {
    $resolvedRoot = (Resolve-Path -LiteralPath $Root).Path
}
catch {
    Add-Finding -Id 'root_not_found' -Details @($Root)
    Write-Result -ResolvedRoot $Root -Checks $checkCount -Errors $findings -AsJson:$Json -WithExplanation:$Explain
    exit 1
}

$templateRoot = Join-Path $resolvedRoot 'template'
$requiredFiles = @(
    'template/AGENTS.md',
    'template/.agent/LOOP.md',
    'template/.agent/STATE.md',
    'template/.agent/STATE_MACHINE.md',
    'template/.agent/LOG.md',
    'template/.agent/MODEL_POLICY.md',
    'template/.agents/skills/workflow-lite/SKILL.md',
    'template/.agents/skills/workflow-standard/SKILL.md'
)

$missing = New-Object System.Collections.ArrayList
foreach ($relativePath in $requiredFiles) {
    if (-not (Test-Path -LiteralPath (Join-Path $resolvedRoot $relativePath) -PathType Leaf)) {
        [void]$missing.Add($relativePath)
    }
}
if ($missing.Count -gt 0) {
    Add-Finding -Id 'required_file_missing' -Details @($missing)
}

$templateFiles = @()
if (Test-Path -LiteralPath $templateRoot -PathType Container) {
    $templateFiles = @(Get-ChildItem -LiteralPath $templateRoot -File -Recurse -Force | Sort-Object FullName)
}

$skillProblems = New-Object System.Collections.ArrayList
foreach ($skillRelativePath in @('template/.agents/skills/workflow-lite/SKILL.md', 'template/.agents/skills/workflow-standard/SKILL.md')) {
    $skillPath = Join-Path $resolvedRoot $skillRelativePath
    if (Test-Path -LiteralPath $skillPath -PathType Leaf) {
        foreach ($problem in Test-SkillFrontmatter -Path $skillPath -RelativePath $skillRelativePath) {
            [void]$skillProblems.Add($problem)
        }
    }
}
if ($skillProblems.Count -gt 0) {
    Add-Finding -Id 'skill_frontmatter_invalid' -Details @($skillProblems)
}

$placeholderProblems = New-Object System.Collections.ArrayList
$absolutePathProblems = New-Object System.Collections.ArrayList
$claudeProblems = New-Object System.Collections.ArrayList
$internalPathProblems = New-Object System.Collections.ArrayList
$claudeOnlyNames = @('AskUserQuestion', 'TodoWrite', 'PreToolUse', 'PostToolUse', 'UserPromptSubmit', 'SessionStart', 'SessionEnd', 'SubagentStart', 'SubagentStop', 'PreCompact')
$placeholderPattern = '(?i)\[(REPLACE_ME|YOUR_[A-Z0-9_]+)\]|\{\{(REPLACE_ME|YOUR_[A-Z0-9_]+)\}\}'
$absolutePathPattern = '(?i)([A-Z]:\\Users\\|/Users/|/home/|' + [regex]::Escape($resolvedRoot) + ')'
$internalPathPattern = '(?<![A-Za-z0-9_.-])(?<path>\.agent/[A-Za-z0-9_.-]+(?:/[A-Za-z0-9_.-]+)*\.(?:md|ps1)|\.agents/skills/[A-Za-z0-9_.-]+/SKILL\.md)'

foreach ($file in $templateFiles) {
    $relativePath = Get-RelativePath -BasePath $resolvedRoot -Path $file.FullName
    $text = Get-FileText -Path $file.FullName

    if ([regex]::IsMatch($text, $placeholderPattern)) {
        [void]$placeholderProblems.Add($relativePath + ': explicit unresolved placeholder marker')
    }
    if ([regex]::IsMatch($text, $absolutePathPattern)) {
        [void]$absolutePathProblems.Add($relativePath + ': prohibited personal or current development path')
    }
    foreach ($name in $claudeOnlyNames) {
        if ([regex]::IsMatch($text, '(?<![A-Za-z0-9_])' + [regex]::Escape($name) + '(?![A-Za-z0-9_])')) {
            [void]$claudeProblems.Add($relativePath + ': ' + $name)
        }
    }
    foreach ($pathMatch in [regex]::Matches($text, $internalPathPattern)) {
        $relativeTarget = $pathMatch.Groups['path'].Value.Replace('/', [System.IO.Path]::DirectorySeparatorChar)
        if (-not (Test-Path -LiteralPath (Join-Path $templateRoot $relativeTarget) -PathType Leaf)) {
            [void]$internalPathProblems.Add($relativePath + ': ' + $pathMatch.Groups['path'].Value)
        }
    }
}

if ($placeholderProblems.Count -gt 0) {
    Add-Finding -Id 'unreplaced_placeholder' -Details @($placeholderProblems)
}
if ($absolutePathProblems.Count -gt 0) {
    Add-Finding -Id 'absolute_user_path' -Details @($absolutePathProblems)
}
if ($claudeProblems.Count -gt 0) {
    Add-Finding -Id 'claude_only_asset' -Details @($claudeProblems)
}

$liteSkillPath = Join-Path $resolvedRoot 'template/.agents/skills/workflow-lite/SKILL.md'
if (Test-Path -LiteralPath $liteSkillPath -PathType Leaf) {
    $liteProblems = Test-LiteDefaultDependency -Path $liteSkillPath -RelativePath 'template/.agents/skills/workflow-lite/SKILL.md'
    if ($liteProblems.Count -gt 0) {
        Add-Finding -Id 'lite_state_machine_reference' -Details @($liteProblems)
    }
}

if ($internalPathProblems.Count -gt 0) {
    Add-Finding -Id 'internal_path_missing' -Details @($internalPathProblems)
}

Write-Result -ResolvedRoot $resolvedRoot -Checks $checkCount -Errors $findings -AsJson:$Json -WithExplanation:$Explain
if ($findings.Count -gt 0) {
    exit 1
}

exit 0
