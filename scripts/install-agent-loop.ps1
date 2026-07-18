[CmdletBinding()]
param(
    [string]$Repository = 'https://github.com/xiaolebao516/loop_template_repository.git',
    [string]$Ref = 'main',
    [string]$Target = (Get-Location).Path,
    [switch]$DryRun,
    [switch]$VerifyOnly
)

Set-StrictMode -Version 2.0
$ErrorActionPreference = 'Stop'

function Get-RequiredPayloadFiles {
    return @(
        'AGENTS.md',
        '.agent/LOOP.md',
        '.agent/STATE.md'
    )
}

function Get-RelativeFileList {
    param([Parameter(Mandatory = $true)][string]$Root)

    $files = New-Object System.Collections.ArrayList
    foreach ($file in Get-ChildItem -LiteralPath $Root -File -Recurse -Force | Sort-Object FullName) {
        $relative = $file.FullName.Substring($Root.Length).TrimStart('\').Replace('\', '/')
        [void]$files.Add($relative)
    }
    return @($files)
}

function Test-MinimalRuntime {
    param([Parameter(Mandatory = $true)][string]$RuntimeRoot)

    foreach ($relativePath in Get-RequiredPayloadFiles) {
        if (-not (Test-Path -LiteralPath (Join-Path $RuntimeRoot $relativePath) -PathType Leaf)) {
            throw ('minimal_runtime_invalid: required file is missing: ' + $relativePath)
        }
    }

    $loopText = [System.IO.File]::ReadAllText((Join-Path $RuntimeRoot '.agent/LOOP.md'), [System.Text.Encoding]::UTF8)
    $loopHeadings = @([regex]::Matches($loopText, '(?m)^# (?<heading>[^\r\n]+)\s*$') | ForEach-Object { $_.Groups['heading'].Value })
    if (($loopHeadings -join '|') -cne 'Goal|Boundaries|SOP') {
        throw 'minimal_runtime_invalid: LOOP must contain only Goal, Boundaries, and SOP'
    }

    $stateText = [System.IO.File]::ReadAllText((Join-Path $RuntimeRoot '.agent/STATE.md'), [System.Text.Encoding]::UTF8)
    foreach ($heading in @('Current State', 'Learnings', 'History')) {
        if (-not [regex]::IsMatch($stateText, '(?m)^# ' + [regex]::Escape($heading) + '\s*$')) {
            throw ('minimal_runtime_invalid: STATE section is missing: ' + $heading)
        }
    }
    if (-not [regex]::IsMatch($stateText, '(?m)^- Status:\s*inactive\s*$')) {
        throw 'minimal_runtime_invalid: STATE must initialize with Status inactive'
    }
}

function Test-SourceTemplate {
    param([Parameter(Mandatory = $true)][string]$TemplateRoot)

    if (-not (Test-Path -LiteralPath $TemplateRoot -PathType Container)) {
        throw 'source_template_invalid: template directory is missing'
    }
    Test-MinimalRuntime -RuntimeRoot $TemplateRoot

    foreach ($item in Get-ChildItem -LiteralPath $TemplateRoot -Recurse -Force) {
        if (($item.Attributes -band [System.IO.FileAttributes]::ReparsePoint) -ne 0) {
            throw ('source_template_invalid: reparse points are not allowed: ' + $item.FullName)
        }
    }

    $actual = @(Get-RelativeFileList -Root $TemplateRoot)
    $expected = @(Get-RequiredPayloadFiles | Sort-Object)
    if (($actual -join '|') -cne ($expected -join '|')) {
        throw ('source_template_invalid: template must contain only the three runtime files; found: ' + ($actual -join ', '))
    }
}

function Get-AgentTraces {
    param([Parameter(Mandatory = $true)][string]$TargetRoot)

    $traces = New-Object System.Collections.ArrayList
    foreach ($name in @('AGENTS.md', '.agent', '.agents')) {
        if (Test-Path -LiteralPath (Join-Path $TargetRoot $name)) {
            [void]$traces.Add($name)
        }
    }
    return @($traces)
}

if ($DryRun -and $VerifyOnly) {
    throw 'mode_invalid: DryRun and VerifyOnly are mutually exclusive'
}

try {
    $targetRoot = (Resolve-Path -LiteralPath $Target).Path
}
catch {
    throw ('target_invalid: target directory does not exist: ' + $Target)
}
if (-not (Test-Path -LiteralPath $targetRoot -PathType Container)) {
    throw ('target_invalid: target is not a directory: ' + $targetRoot)
}

if ($VerifyOnly) {
    Test-MinimalRuntime -RuntimeRoot $targetRoot
    Write-Output 'PASS: minimal Agent Loop runtime is installed.'
    Write-Output ('Target: ' + $targetRoot)
    return
}

$initialTraces = @(Get-AgentTraces -TargetRoot $targetRoot)
if ($initialTraces.Count -gt 0) {
    throw ('agent_trace_exists: remove or audit these paths before installation: ' + ($initialTraces -join ', '))
}
if ([string]::IsNullOrWhiteSpace($Repository)) {
    throw 'repository_invalid: Repository must not be empty'
}
if ([string]::IsNullOrWhiteSpace($Ref) -or $Ref.StartsWith('-')) {
    throw 'repository_invalid: Ref must be a branch or tag name and must not start with a dash'
}

$gitCommand = Get-Command git -ErrorAction SilentlyContinue
if ($null -eq $gitCommand) {
    throw 'git_not_found: Git is required for remote installation'
}

$sourceTemp = Join-Path ([System.IO.Path]::GetTempPath()) ('agent-loop-source-' + [System.Guid]::NewGuid().ToString('N'))
$cloneRoot = Join-Path $sourceTemp 'repository'
$stagingRoot = Join-Path $targetRoot ('.agent-loop-install-' + [System.Guid]::NewGuid().ToString('N'))
$installedPaths = New-Object System.Collections.ArrayList
$sourceCommit = $null
$templateTreeHash = $null
$failureMessage = $null

try {
    New-Item -ItemType Directory -Path $sourceTemp | Out-Null

    $savedPreference = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'
    try {
        $cloneOutput = @(& $gitCommand.Source clone --quiet --depth 1 --single-branch --branch $Ref -- $Repository $cloneRoot 2>&1)
        $cloneExitCode = $LASTEXITCODE
    }
    finally {
        $ErrorActionPreference = $savedPreference
    }
    if ($cloneExitCode -ne 0) {
        throw ('repository_clone_failed: ' + (($cloneOutput | ForEach-Object { $_.ToString() }) -join ' '))
    }

    $sourceCommit = ((@(& $gitCommand.Source -C $cloneRoot rev-parse HEAD) -join '')).Trim()
    if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace($sourceCommit)) {
        throw 'source_provenance_failed: unable to resolve Source Commit'
    }
    $templateTreeHash = ((@(& $gitCommand.Source -C $cloneRoot rev-parse HEAD:template) -join '')).Trim()
    if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace($templateTreeHash)) {
        throw 'source_provenance_failed: unable to resolve Template Tree Hash'
    }

    $templateRoot = Join-Path $cloneRoot 'template'
    Test-SourceTemplate -TemplateRoot $templateRoot

    if ($DryRun) {
        Write-Output 'DRY RUN: minimal Agent Loop runtime can be installed.'
        Write-Output ('Target: ' + $targetRoot)
        Write-Output ('Source Commit: ' + $sourceCommit)
        Write-Output ('Template Tree Hash: ' + $templateTreeHash)
        return
    }

    $secondTraceCheck = @(Get-AgentTraces -TargetRoot $targetRoot)
    if ($secondTraceCheck.Count -gt 0) {
        throw ('agent_trace_exists: target changed during installation: ' + ($secondTraceCheck -join ', '))
    }

    New-Item -ItemType Directory -Path (Join-Path $stagingRoot '.agent') -Force | Out-Null
    foreach ($relativePath in Get-RequiredPayloadFiles) {
        Copy-Item -LiteralPath (Join-Path $templateRoot $relativePath) -Destination (Join-Path $stagingRoot $relativePath)
    }
    Test-SourceTemplate -TemplateRoot $stagingRoot

    $finalTraceCheck = @(Get-AgentTraces -TargetRoot $targetRoot)
    if ($finalTraceCheck.Count -gt 0) {
        throw ('agent_trace_exists: target changed before installation completed: ' + ($finalTraceCheck -join ', '))
    }

    foreach ($name in @('AGENTS.md', '.agent')) {
        $destination = Join-Path $targetRoot $name
        Move-Item -LiteralPath (Join-Path $stagingRoot $name) -Destination $destination
        [void]$installedPaths.Add($destination)
    }
}
catch {
    $failureMessage = $_.Exception.Message
    foreach ($path in @($installedPaths)) {
        if (Test-Path -LiteralPath $path) {
            Remove-Item -LiteralPath $path -Recurse -Force -ErrorAction SilentlyContinue
        }
    }
}
finally {
    if (Test-Path -LiteralPath $stagingRoot) {
        Remove-Item -LiteralPath $stagingRoot -Recurse -Force -ErrorAction SilentlyContinue
    }
    if (Test-Path -LiteralPath $sourceTemp) {
        Remove-Item -LiteralPath $sourceTemp -Recurse -Force -ErrorAction SilentlyContinue
    }
}

if ($null -ne $failureMessage) {
    throw ('installation_failed: ' + $failureMessage)
}

Write-Output 'Installed minimal Agent Loop runtime.'
Write-Output ('Target: ' + $targetRoot)
Write-Output ('Source Commit: ' + $sourceCommit)
Write-Output ('Template Tree Hash: ' + $templateTreeHash)
Write-Output 'Next: ask the Agent to initialize Agent Loop Engineering as described in AGENTS.md.'
