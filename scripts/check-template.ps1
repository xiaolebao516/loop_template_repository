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
$checkCount = 9
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

function Test-BootstrapState {
    param(
        [Parameter(Mandatory = $true)][string]$LoopPath,
        [Parameter(Mandatory = $true)][string]$StatePath,
        [Parameter(Mandatory = $true)][string]$StateMachinePath
    )

    $problems = New-Object System.Collections.ArrayList
    if (-not (Test-Path -LiteralPath $LoopPath -PathType Leaf) -or -not (Test-Path -LiteralPath $StatePath -PathType Leaf) -or -not (Test-Path -LiteralPath $StateMachinePath -PathType Leaf)) {
        return @($problems)
    }

    $loopText = Get-FileText -Path $LoopPath
    $stateText = Get-FileText -Path $StatePath
    $stateMachineText = Get-FileText -Path $StateMachinePath
    foreach ($entry in @(
            @{ Heading = 'Status'; Value = 'inactive' },
            @{ Heading = 'Goal'; Value = 'none' },
            @{ Heading = 'Boundary / Scope'; Value = 'none' },
            @{ Heading = 'Success Criteria'; Value = 'none' }
        )) {
        $pattern = '(?m)^## ' + [regex]::Escape($entry.Heading) + '\r?\n\r?\n`' + $entry.Value + '`\s*$'
        if (-not [regex]::IsMatch($loopText, $pattern)) {
            [void]$problems.Add('template/.agent/LOOP.md: inactive ' + $entry.Heading + ' is missing or invalid')
        }
    }

    foreach ($entry in @(
            @{ Heading = 'Workflow'; Value = 'none' },
            @{ Heading = 'Stage'; Value = 'none' },
            @{ Heading = 'Status'; Value = 'inactive' },
            @{ Heading = 'Current Task'; Value = 'none' },
            @{ Heading = 'Next Actions'; Value = 'none' },
            @{ Heading = 'Verification Status'; Value = 'none' }
        )) {
        $pattern = '(?m)^## ' + [regex]::Escape($entry.Heading) + '\r?\n\r?\n`' + $entry.Value + '`\s*$'
        if (-not [regex]::IsMatch($stateText, $pattern)) {
            [void]$problems.Add('template/.agent/STATE.md: inactive ' + $entry.Heading + ' is missing or invalid')
        }
    }

    if (-not $stateMachineText.Contains('`inactive` is repository lifecycle metadata, not a Standard Stage.')) {
        [void]$problems.Add('template/.agent/STATE_MACHINE.md: inactive is not declared outside the Standard Stage set')
    }
    if ([regex]::IsMatch($loopText, '(?m)^.*SC-[0-9]+.*$') -or [regex]::IsMatch($stateText, '(?m)^.*SC-[0-9]+.*$')) {
        [void]$problems.Add('template/.agent: inactive bootstrap contains fabricated Success Criterion rows')
    }
    if ([regex]::IsMatch($stateText, '(?m)^## (Plan Status|Approval Context|Proposed Contract Draft|Iteration Control|Blocked Context)\s*$')) {
        [void]$problems.Add('template/.agent/STATE.md: inactive bootstrap contains an active conditional section')
    }

    return @($problems)
}

function Test-ReferenceWorkContract {
    param([Parameter(Mandatory = $true)][string]$ResolvedRoot)

    $problems = New-Object System.Collections.ArrayList
    $referenceKeep = Join-Path $ResolvedRoot 'template/.agent/reference/.gitkeep'
    $workKeep = Join-Path $ResolvedRoot 'template/.agent/work/.gitkeep'
    foreach ($entry in @(
            @{ Path = $referenceKeep; Relative = 'template/.agent/reference/.gitkeep' },
            @{ Path = $workKeep; Relative = 'template/.agent/work/.gitkeep' }
        )) {
        if (-not (Test-Path -LiteralPath $entry.Path -PathType Leaf)) {
            [void]$problems.Add($entry.Relative + ': required directory marker is missing')
        }
        elseif ((Get-Item -LiteralPath $entry.Path).Length -ne 0) {
            [void]$problems.Add($entry.Relative + ': directory marker must remain empty')
        }
    }

    foreach ($directory in @('template/.agent/reference', 'template/.agent/work')) {
        $directoryPath = Join-Path $ResolvedRoot $directory
        if (Test-Path -LiteralPath $directoryPath -PathType Container) {
            foreach ($file in Get-ChildItem -LiteralPath $directoryPath -File -Recurse -Force) {
                if ($file.Name -ne '.gitkeep') {
                    [void]$problems.Add((Get-RelativePath -BasePath $ResolvedRoot -Path $file.FullName) + ': template information layer must not contain project-specific seed content')
                }
            }
        }
    }

    $statePath = Join-Path $ResolvedRoot 'template/.agent/STATE.md'
    if (Test-Path -LiteralPath $statePath -PathType Leaf) {
        $stateText = Get-FileText -Path $statePath
        foreach ($heading in @('Active References', 'Work Directory')) {
            $pattern = '(?m)^## ' + [regex]::Escape($heading) + '\r?\n\r?\n`none`\s*$'
            if (-not [regex]::IsMatch($stateText, $pattern)) {
                [void]$problems.Add('template/.agent/STATE.md: inactive ' + $heading + ' must be none')
            }
        }
    }

    $contractMarkers = @(
        @{ Path = 'template/AGENTS.md'; Text = 'Read only the specific reference files required by the current task; never load `.agent/reference/` by default or recursively.' },
        @{ Path = 'template/AGENTS.md'; Text = 'Human Deliverables are not default Agent context;' },
        @{ Path = 'template/.agent/STATE_MACHINE.md'; Text = 'Work is an optional temporary layer for complex research, analysis, or recovery.' },
        @{ Path = 'template/.agent/STATE_MACHINE.md'; Text = 'Before DELIVER completes, classify and clean all Work Directory content.' },
        @{ Path = 'template/.agents/skills/workflow-standard/SKILL.md'; Text = 'Load only the exact reference files required by the current task; never recursively load `.agent/reference/`.' },
        @{ Path = 'template/.agents/skills/workflow-standard/SKILL.md'; Text = 'Use `.agent/work/<loop-id>/` only when complex research, analysis, or recovery material must persist.' },
        @{ Path = 'template/.agents/skills/workflow-standard/SKILL.md'; Text = 'Complete work classification and cleanup before DELIVER.' },
        @{ Path = 'template/.agents/skills/workflow-lite/SKILL.md'; Text = 'Do not create `.agent/work/` by default.' }
    )
    foreach ($marker in $contractMarkers) {
        $path = Join-Path $ResolvedRoot $marker.Path
        if ((Test-Path -LiteralPath $path -PathType Leaf) -and -not (Get-FileText -Path $path).Contains($marker.Text)) {
            [void]$problems.Add($marker.Path + ': required reference/work contract marker is missing')
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

$bootstrapProblems = Test-BootstrapState `
    -LoopPath (Join-Path $resolvedRoot 'template/.agent/LOOP.md') `
    -StatePath (Join-Path $resolvedRoot 'template/.agent/STATE.md') `
    -StateMachinePath (Join-Path $resolvedRoot 'template/.agent/STATE_MACHINE.md')
if ($bootstrapProblems.Count -gt 0) {
    Add-Finding -Id 'bootstrap_state_invalid' -Details @($bootstrapProblems)
}

$referenceWorkProblems = Test-ReferenceWorkContract -ResolvedRoot $resolvedRoot
if ($referenceWorkProblems.Count -gt 0) {
    Add-Finding -Id 'reference_work_contract_invalid' -Details @($referenceWorkProblems)
}

Write-Result -ResolvedRoot $resolvedRoot -Checks $checkCount -Errors $findings -AsJson:$Json -WithExplanation:$Explain
if ($findings.Count -gt 0) {
    exit 1
}

exit 0
