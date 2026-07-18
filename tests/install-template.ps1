[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$repositoryRoot = Split-Path -Parent $PSScriptRoot
$installer = Join-Path $repositoryRoot 'scripts\install-agent-loop.ps1'
$templateSource = Join-Path $repositoryRoot 'template'
$tempRoot = Join-Path ([System.IO.Path]::GetTempPath()) ('minimal-runtime-install-' + [System.Guid]::NewGuid().ToString('N'))
$failures = New-Object System.Collections.ArrayList
$testCount = 0

function Add-Failure {
    param([string]$Message)
    [void]$failures.Add($Message)
}

function Get-TreeHash {
    param([string]$Path)

    $entries = New-Object System.Collections.ArrayList
    foreach ($file in Get-ChildItem -LiteralPath $Path -File -Recurse -Force | Sort-Object FullName) {
        $relative = $file.FullName.Substring($Path.Length).TrimStart('\')
        [void]$entries.Add($relative + ':' + (Get-FileHash -Algorithm SHA256 -LiteralPath $file.FullName).Hash)
    }
    return ($entries -join "`n")
}

function Invoke-Git {
    param([string]$WorkingDirectory, [string[]]$Arguments)

    $savedPreference = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'
    try {
        $output = @(& git -C $WorkingDirectory @Arguments 2>&1)
        $exitCode = $LASTEXITCODE
    }
    finally { $ErrorActionPreference = $savedPreference }
    if ($exitCode -ne 0) {
        throw ('git failed: ' + (($output | ForEach-Object { $_.ToString() }) -join ' '))
    }
}

function New-SourceRepository {
    param([switch]$Invalid)

    $source = Join-Path $tempRoot ('source-' + [System.Guid]::NewGuid().ToString('N'))
    New-Item -ItemType Directory -Path $source | Out-Null
    Copy-Item -LiteralPath $templateSource -Destination (Join-Path $source 'template') -Recurse -Force
    Set-Content -LiteralPath (Join-Path $source 'README.md') -Value 'source-only file' -Encoding UTF8
    if ($Invalid) { Remove-Item -LiteralPath (Join-Path $source 'template\.agent\STATE.md') -Force }
    Invoke-Git -WorkingDirectory $source -Arguments @('init')
    Invoke-Git -WorkingDirectory $source -Arguments @('checkout', '-b', 'main')
    Invoke-Git -WorkingDirectory $source -Arguments @('config', 'user.name', 'Installer Test')
    Invoke-Git -WorkingDirectory $source -Arguments @('config', 'user.email', 'installer-test@example.invalid')
    Invoke-Git -WorkingDirectory $source -Arguments @('add', '--all')
    Invoke-Git -WorkingDirectory $source -Arguments @('commit', '-m', 'fixture')
    return $source
}

function New-Target {
    $target = Join-Path $tempRoot ('target-' + [System.Guid]::NewGuid().ToString('N'))
    New-Item -ItemType Directory -Path $target | Out-Null
    return $target
}

function Invoke-Installer {
    param(
        [string]$Repository,
        [string]$Target,
        [switch]$DryRun,
        [switch]$VerifyOnly
    )

    $arguments = @('-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', $installer, '-Repository', $Repository, '-Ref', 'main', '-Target', $Target)
    if ($DryRun) { $arguments += '-DryRun' }
    if ($VerifyOnly) { $arguments += '-VerifyOnly' }
    $savedPreference = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'
    try {
        $output = @(& powershell.exe @arguments 2>&1)
        $exitCode = $LASTEXITCODE
    }
    finally { $ErrorActionPreference = $savedPreference }
    return [PSCustomObject]@{ Output = @($output | ForEach-Object { $_.ToString() }); ExitCode = $exitCode }
}

function Assert-Test {
    param([string]$Name, [scriptblock]$Body)
    $script:testCount++
    try { & $Body }
    catch { Add-Failure ($Name + ': ' + $_.Exception.Message) }
}

try {
    if ($null -eq (Get-Command git -ErrorAction SilentlyContinue)) { throw 'Git is required for installer tests' }
    New-Item -ItemType Directory -Path $tempRoot | Out-Null
    $validSource = New-SourceRepository

    Assert-Test -Name 'empty_target_one_click_install_succeeds' -Body {
        $target = New-Target
        $result = Invoke-Installer -Repository $validSource -Target $target
        if ($result.ExitCode -ne 0) { throw ('installer failed: ' + ($result.Output -join ' ')) }
        if (($result.Output -join "`n") -notmatch 'Source Commit:' -or ($result.Output -join "`n") -notmatch 'Template Tree Hash:') { throw 'source provenance was not reported' }
    }

    Assert-Test -Name 'install_result_contains_only_three_runtime_files' -Body {
        $target = New-Target
        $result = Invoke-Installer -Repository $validSource -Target $target
        if ($result.ExitCode -ne 0) { throw 'installer failed' }
        $files = @(Get-ChildItem -LiteralPath $target -File -Recurse -Force | ForEach-Object { $_.FullName.Substring($target.Length).TrimStart('\').Replace('\', '/') } | Sort-Object)
        if (($files -join '|') -cne '.agent/LOOP.md|.agent/STATE.md|AGENTS.md') { throw ('unexpected installed files: ' + ($files -join ', ')) }
        if (Test-Path -LiteralPath (Join-Path $target '.agents')) { throw '.agents was created' }
    }

    Assert-Test -Name 'hidden_agent_directory_is_installed' -Body {
        $target = New-Target
        $result = Invoke-Installer -Repository $validSource -Target $target
        if ($result.ExitCode -ne 0 -or -not (Test-Path -LiteralPath (Join-Path $target '.agent') -PathType Container)) { throw 'hidden .agent directory was not installed' }
    }

    Assert-Test -Name 'dry_run_is_read_only' -Body {
        $target = New-Target
        Set-Content -LiteralPath (Join-Path $target 'project.txt') -Value 'preserve' -Encoding UTF8
        $before = Get-TreeHash -Path $target
        $result = Invoke-Installer -Repository $validSource -Target $target -DryRun
        $after = Get-TreeHash -Path $target
        if ($result.ExitCode -ne 0 -or ($result.Output -join "`n") -notmatch 'DRY RUN') { throw 'DryRun did not succeed' }
        if ($before -cne $after) { throw 'DryRun changed the target' }
    }

    Assert-Test -Name 'verify_only_is_read_only' -Body {
        $target = New-Target
        $install = Invoke-Installer -Repository $validSource -Target $target
        if ($install.ExitCode -ne 0) { throw 'setup install failed' }
        $before = Get-TreeHash -Path $target
        $result = Invoke-Installer -Repository $validSource -Target $target -VerifyOnly
        $after = Get-TreeHash -Path $target
        if ($result.ExitCode -ne 0 -or ($result.Output -join "`n") -notmatch '^PASS: minimal Agent Loop runtime') { throw 'VerifyOnly did not pass' }
        if ($before -cne $after) { throw 'VerifyOnly changed the target' }
    }

    Assert-Test -Name 'existing_conflict_is_not_overwritten' -Body {
        $target = New-Target
        $agentsPath = Join-Path $target 'AGENTS.md'
        Set-Content -LiteralPath $agentsPath -Value 'existing rules' -Encoding UTF8
        $before = Get-TreeHash -Path $target
        $result = Invoke-Installer -Repository $validSource -Target $target
        if ($result.ExitCode -eq 0 -or ($result.Output -join "`n") -notmatch 'agent_trace_exists') { throw 'existing conflict did not block installation' }
        if ($before -cne (Get-TreeHash -Path $target)) { throw 'conflicting target was changed' }
    }

    Assert-Test -Name 'repeated_install_is_safe' -Body {
        $target = New-Target
        $first = Invoke-Installer -Repository $validSource -Target $target
        if ($first.ExitCode -ne 0) { throw 'first install failed' }
        $before = Get-TreeHash -Path $target
        $second = Invoke-Installer -Repository $validSource -Target $target
        if ($second.ExitCode -eq 0 -or ($second.Output -join "`n") -notmatch 'agent_trace_exists') { throw 'repeated install did not stop safely' }
        if ($before -cne (Get-TreeHash -Path $target)) { throw 'repeated install changed the runtime' }
    }

    Assert-Test -Name 'invalid_source_leaves_no_partial_install' -Body {
        $invalidSource = New-SourceRepository -Invalid
        $target = New-Target
        $result = Invoke-Installer -Repository $invalidSource -Target $target
        if ($result.ExitCode -eq 0 -or ($result.Output -join "`n") -notmatch 'minimal_runtime_invalid') { throw 'invalid source was not rejected' }
        if ((Get-ChildItem -LiteralPath $target -Force).Count -ne 0) { throw 'partial install remained after source failure' }
    }

    Assert-Test -Name 'remote_scriptblock_style_succeeds' -Body {
        $target = New-Target
        $scriptText = [System.IO.File]::ReadAllText($installer, [System.Text.Encoding]::UTF8)
        $output = @(& ([scriptblock]::Create($scriptText)) -Repository $validSource -Ref main -Target $target)
        if (-not (Test-Path -LiteralPath (Join-Path $target '.agent\STATE.md') -PathType Leaf)) { throw 'scriptblock invocation did not install STATE' }
        if (($output -join "`n") -notmatch 'Installed minimal Agent Loop runtime') { throw 'scriptblock invocation did not report success' }
    }
}
finally {
    if (Test-Path -LiteralPath $tempRoot) {
        Remove-Item -LiteralPath $tempRoot -Recurse -Force -ErrorAction SilentlyContinue
    }
}

if ($failures.Count -eq 0) {
    Write-Output ('PASS: ' + $testCount + ' tests')
    exit 0
}

Write-Output ('FAIL: ' + $failures.Count)
foreach ($failure in $failures) { Write-Output ('- ' + $failure) }
exit 1
