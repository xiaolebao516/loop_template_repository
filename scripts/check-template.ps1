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

$checkCount = 6
$findings = New-Object System.Collections.ArrayList

function Add-Problem {
    param(
        [Parameter(Mandatory = $true)][AllowEmptyCollection()][System.Collections.ArrayList]$Problems,
        [Parameter(Mandatory = $true)][string]$Message
    )
    [void]$Problems.Add($Message)
}

function Get-FileText {
    param([Parameter(Mandatory = $true)][string]$Path)
    return [System.IO.File]::ReadAllText($Path, [System.Text.Encoding]::UTF8)
}

function Get-RelativeTemplateFiles {
    param([Parameter(Mandatory = $true)][string]$TemplateRoot)

    $files = New-Object System.Collections.ArrayList
    if (Test-Path -LiteralPath $TemplateRoot -PathType Container) {
        foreach ($file in Get-ChildItem -LiteralPath $TemplateRoot -File -Recurse -Force | Sort-Object FullName) {
            [void]$files.Add($file.FullName.Substring($TemplateRoot.Length).TrimStart('\').Replace('\', '/'))
        }
    }
    return @($files)
}

function Test-MinimalRuntimeContract {
    param([Parameter(Mandatory = $true)][string]$ResolvedRoot)

    $problems = New-Object System.Collections.ArrayList
    $templateRoot = Join-Path $ResolvedRoot 'template'
    $requiredFiles = @('AGENTS.md', '.agent/LOOP.md', '.agent/STATE.md')
    foreach ($relativePath in $requiredFiles) {
        if (-not (Test-Path -LiteralPath (Join-Path $templateRoot $relativePath) -PathType Leaf)) {
            Add-Problem -Problems $problems -Message ('template/' + $relativePath + ': required runtime file is missing')
        }
    }

    $actualFiles = @(Get-RelativeTemplateFiles -TemplateRoot $templateRoot)
    $expectedFiles = @($requiredFiles | Sort-Object)
    if (($actualFiles -join '|') -cne ($expectedFiles -join '|')) {
        Add-Problem -Problems $problems -Message ('template: runtime must contain only AGENTS.md, .agent/LOOP.md, and .agent/STATE.md; found: ' + ($actualFiles -join ', '))
    }

    $loopPath = Join-Path $templateRoot '.agent/LOOP.md'
    if (Test-Path -LiteralPath $loopPath -PathType Leaf) {
        $loopText = Get-FileText -Path $loopPath
        $headings = @([regex]::Matches($loopText, '(?m)^# (?<heading>[^\r\n]+)\s*$') | ForEach-Object { $_.Groups['heading'].Value })
        if (($headings -join '|') -cne 'Goal|Boundaries|SOP') {
            Add-Problem -Problems $problems -Message 'template/.agent/LOOP.md: top-level sections must be exactly Goal, Boundaries, and SOP'
        }
        foreach ($heading in @('Goal', 'Boundaries', 'SOP')) {
            if (-not [regex]::IsMatch($loopText, '(?m)^# ' + $heading + '\r?\n\r?\nnone\s*$')) {
                Add-Problem -Problems $problems -Message ('template/.agent/LOOP.md: default ' + $heading + ' must be none')
            }
        }
    }

    $statePath = Join-Path $templateRoot '.agent/STATE.md'
    if (Test-Path -LiteralPath $statePath -PathType Leaf) {
        $stateText = Get-FileText -Path $statePath
        $headings = @([regex]::Matches($stateText, '(?m)^# (?<heading>[^\r\n]+)\s*$') | ForEach-Object { $_.Groups['heading'].Value })
        if (($headings -join '|') -cne 'Current State|Learnings|History') {
            Add-Problem -Problems $problems -Message 'template/.agent/STATE.md: top-level sections must be exactly Current State, Learnings, and History'
        }
        foreach ($field in @('Task: none', 'Status: inactive', 'Current Step: none', 'Last Result: none', 'Blockers: none', 'Next Action: none')) {
            if (-not [regex]::IsMatch($stateText, '(?m)^- ' + [regex]::Escape($field) + '\s*$')) {
                Add-Problem -Problems $problems -Message ('template/.agent/STATE.md: default field is missing: ' + $field)
            }
        }
    }

    $agentsPath = Join-Path $templateRoot 'AGENTS.md'
    if (Test-Path -LiteralPath $agentsPath -PathType Leaf) {
        $agentsText = Get-FileText -Path $agentsPath
        foreach ($marker in @(
                'Build, Test, and Verify must resolve to deterministic scripts or explicit commands.',
                'Classify each failure before retrying',
                'Do not blindly retry the same cause.',
                'Do not exceed five meaningful attempts for the same unresolved root cause',
                'Promote repeated problems to deterministic scripts, tools, tests, Skills, or a short AGENTS rule.',
                'Clarify when needed',
                'Initialization creates no business LOOP or History entry, leaves STATE inactive, and does not commit or push by default.'
            )) {
            if (-not $agentsText.Contains($marker)) {
                Add-Problem -Problems $problems -Message ('template/AGENTS.md: required minimal runtime rule is missing: ' + $marker)
            }
        }
    }

    foreach ($forbidden in @(
            'template/.agent/STATE_MACHINE.md',
            'template/.agent/LOG.md',
            'template/.agent/MODEL_POLICY.md',
            'template/.agent/reference',
            'template/.agent/work',
            'template/.agents'
        )) {
        if (Test-Path -LiteralPath (Join-Path $ResolvedRoot $forbidden)) {
            Add-Problem -Problems $problems -Message ($forbidden + ': legacy fixed runtime path must not exist')
        }
    }

    $installerPath = Join-Path $ResolvedRoot 'scripts/install-agent-loop.ps1'
    if (-not (Test-Path -LiteralPath $installerPath -PathType Leaf)) {
        Add-Problem -Problems $problems -Message 'scripts/install-agent-loop.ps1: installer is missing'
    }
    else {
        $installerText = Get-FileText -Path $installerPath
        $payloadMatch = [regex]::Match($installerText, '(?s)function Get-RequiredPayloadFiles\s*\{.*?return\s*@\((?<body>.*?)\)\s*\}')
        if (-not $payloadMatch.Success) {
            Add-Problem -Problems $problems -Message 'scripts/install-agent-loop.ps1: runtime payload declaration is missing'
        }
        else {
            $payload = @([regex]::Matches($payloadMatch.Groups['body'].Value, "'(?<path>[^']+)'\s*,?") | ForEach-Object { $_.Groups['path'].Value } | Sort-Object)
            if (($payload -join '|') -cne ((@($requiredFiles | Sort-Object)) -join '|')) {
                Add-Problem -Problems $problems -Message ('scripts/install-agent-loop.ps1: installer payload is not the minimal runtime: ' + ($payload -join ', '))
            }
        }
        foreach ($marker in @('[switch]$DryRun', '[switch]$VerifyOnly')) {
            if (-not $installerText.Contains($marker)) {
                Add-Problem -Problems $problems -Message ('scripts/install-agent-loop.ps1: required read-only mode is missing: ' + $marker)
            }
        }
        if ([regex]::IsMatch($installerText, '(?im)^\s*(git\s+|&\s*\$[^\r\n]*git[^\r\n]*)(commit|push)\b')) {
            Add-Problem -Problems $problems -Message 'scripts/install-agent-loop.ps1: installer must not commit or push'
        }
        if ([regex]::IsMatch($installerText, '(?im)^\s*(Import-Module|#requires\s+-Modules)\b')) {
            Add-Problem -Problems $problems -Message 'scripts/install-agent-loop.ps1: external PowerShell modules are not allowed'
        }
    }

    return ,$problems
}

function Write-Result {
    param(
        [string]$ResolvedRoot,
        [AllowEmptyCollection()][System.Collections.ArrayList]$Problems,
        [switch]$AsJson,
        [switch]$WithExplanation
    )

    $passed = $Problems.Count -eq 0
    if ($AsJson) {
        $errors = @()
        if (-not $passed) {
            $errors = @([PSCustomObject]@{ id = 'minimal_runtime_contract_invalid'; details = @($Problems | Sort-Object -Unique) })
        }
        [Console]::Out.WriteLine(([PSCustomObject]@{ root = $ResolvedRoot; passed = $passed; checks = $checkCount; errors = $errors } | ConvertTo-Json -Compress -Depth 5))
        return
    }

    if ($passed) {
        Write-Output ('PASS: ' + $checkCount + ' checks')
        if ($WithExplanation) { Write-Output 'The minimal three-file runtime contract is valid.' }
        return
    }

    Write-Output 'FAIL: 1'
    Write-Output '- minimal_runtime_contract_invalid'
    if ($WithExplanation) {
        foreach ($problem in @($Problems | Sort-Object -Unique)) { Write-Output ('  - ' + $problem) }
    }
}

try {
    $resolvedRoot = (Resolve-Path -LiteralPath $Root).Path
}
catch {
    $rootProblems = New-Object System.Collections.ArrayList
    [void]$rootProblems.Add('root_not_found: ' + $Root)
    Write-Result -ResolvedRoot $Root -Problems $rootProblems -AsJson:$Json -WithExplanation:$Explain
    throw 'root_not_found'
}

$problems = Test-MinimalRuntimeContract -ResolvedRoot $resolvedRoot
Write-Result -ResolvedRoot $resolvedRoot -Problems $problems -AsJson:$Json -WithExplanation:$Explain
if ($problems.Count -gt 0) { exit 1 }
exit 0
