[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$repositoryRoot = Split-Path -Parent $PSScriptRoot
$checker = Join-Path $repositoryRoot 'scripts\check-template.ps1'
$templateSource = Join-Path $repositoryRoot 'template'
$installerSource = Join-Path $repositoryRoot 'scripts\install-agent-loop.ps1'
$tempRoot = Join-Path ([System.IO.Path]::GetTempPath()) ('minimal-runtime-check-' + [System.Guid]::NewGuid().ToString('N'))
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
        $hash = (Get-FileHash -Algorithm SHA256 -LiteralPath $file.FullName).Hash
        [void]$entries.Add($relative + ':' + $hash)
    }
    return ($entries -join "`n")
}

function New-Fixture {
    $fixture = Join-Path $tempRoot ([System.Guid]::NewGuid().ToString('N'))
    New-Item -ItemType Directory -Path (Join-Path $fixture 'scripts') -Force | Out-Null
    Copy-Item -LiteralPath $templateSource -Destination (Join-Path $fixture 'template') -Recurse -Force
    Copy-Item -LiteralPath $installerSource -Destination (Join-Path $fixture 'scripts\install-agent-loop.ps1')
    return $fixture
}

function Invoke-Checker {
    param(
        [string]$Fixture,
        [switch]$Json
    )

    $before = Get-TreeHash -Path $Fixture
    $arguments = @('-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', $checker, '-Root', $Fixture)
    if ($Json) { $arguments += '-Json' }
    $output = @(& powershell.exe @arguments)
    $exitCode = $LASTEXITCODE
    $after = Get-TreeHash -Path $Fixture
    if ($before -cne $after) { throw 'checker modified a fixture' }
    return [PSCustomObject]@{ Output = $output; ExitCode = $exitCode }
}

function Remove-TopLevelSection {
    param(
        [string]$Path,
        [string]$Heading
    )

    $text = [System.IO.File]::ReadAllText($Path, [System.Text.Encoding]::UTF8)
    $pattern = '(?ms)^# ' + [regex]::Escape($Heading) + '\r?\n.*?(?=^# |\z)'
    $text = [regex]::Replace($text, $pattern, '')
    [System.IO.File]::WriteAllText($Path, $text, [System.Text.Encoding]::UTF8)
}

function Assert-Test {
    param([string]$Name, [scriptblock]$Body)

    $script:testCount++
    try { & $Body }
    catch { Add-Failure ($Name + ': ' + $_.Exception.Message) }
}

try {
    New-Item -ItemType Directory -Path $tempRoot | Out-Null

    Assert-Test -Name 'valid_minimal_template_passes' -Body {
        $result = Invoke-Checker -Fixture (New-Fixture)
        if ($result.ExitCode -ne 0 -or ($result.Output -join "`n") -notmatch '^PASS: 6 checks$') { throw 'expected the minimal template to pass' }
    }

    foreach ($relativePath in @('AGENTS.md', '.agent\LOOP.md', '.agent\STATE.md')) {
        Assert-Test -Name ('missing_' + $relativePath.Replace('\', '_').Replace('.', '_') + '_fails') -Body ({
                $fixture = New-Fixture
                Remove-Item -LiteralPath (Join-Path $fixture ('template\' + $relativePath)) -Force
                $result = Invoke-Checker -Fixture $fixture
                if ($result.ExitCode -eq 0 -or ($result.Output -join "`n") -notmatch 'minimal_runtime_contract_invalid') { throw ('missing file was not reported: ' + $relativePath) }
            }.GetNewClosure())
    }

    foreach ($heading in @('Goal', 'Boundaries', 'SOP')) {
        Assert-Test -Name ('loop_missing_' + $heading.ToLowerInvariant() + '_fails') -Body ({
                $fixture = New-Fixture
                Remove-TopLevelSection -Path (Join-Path $fixture 'template\.agent\LOOP.md') -Heading $heading
                $result = Invoke-Checker -Fixture $fixture
                if ($result.ExitCode -eq 0 -or ($result.Output -join "`n") -notmatch 'minimal_runtime_contract_invalid') { throw ('missing LOOP section was not reported: ' + $heading) }
            }.GetNewClosure())
    }

    foreach ($heading in @('Learnings', 'History')) {
        Assert-Test -Name ('state_missing_' + $heading.ToLowerInvariant() + '_fails') -Body ({
                $fixture = New-Fixture
                Remove-TopLevelSection -Path (Join-Path $fixture 'template\.agent\STATE.md') -Heading $heading
                $result = Invoke-Checker -Fixture $fixture
                if ($result.ExitCode -eq 0 -or ($result.Output -join "`n") -notmatch 'minimal_runtime_contract_invalid') { throw ('missing STATE section was not reported: ' + $heading) }
            }.GetNewClosure())
    }

    Assert-Test -Name 'legacy_runtime_reappearance_fails' -Body {
        $fixture = New-Fixture
        Set-Content -LiteralPath (Join-Path $fixture 'template\.agent\STATE_MACHINE.md') -Value 'legacy runtime' -Encoding UTF8
        $result = Invoke-Checker -Fixture $fixture
        if ($result.ExitCode -eq 0 -or ($result.Output -join "`n") -notmatch 'minimal_runtime_contract_invalid') { throw 'legacy runtime file was not reported' }
    }

    Assert-Test -Name 'json_is_parseable_stable_and_read_only' -Body {
        $fixture = New-Fixture
        $first = Invoke-Checker -Fixture $fixture -Json
        $second = Invoke-Checker -Fixture $fixture -Json
        $firstText = $first.Output -join "`n"
        $secondText = $second.Output -join "`n"
        if ($first.ExitCode -ne 0 -or $second.ExitCode -ne 0) { throw 'JSON check did not pass' }
        $parsed = $firstText | ConvertFrom-Json
        if (-not $parsed.passed -or $parsed.checks -ne 6) { throw 'JSON result was incomplete' }
        if ($firstText -cne $secondText) { throw 'JSON output was not stable' }
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
