[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$checker = Join-Path (Split-Path -Parent $PSScriptRoot) 'scripts\check-template.ps1'
$templateSource = Join-Path (Split-Path -Parent $PSScriptRoot) 'template'
$tempRoot = Join-Path ([System.IO.Path]::GetTempPath()) ('agent-template-check-' + [System.Guid]::NewGuid().ToString('N'))
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
    New-Item -ItemType Directory -Path $fixture | Out-Null
    Copy-Item -LiteralPath $templateSource -Destination (Join-Path $fixture 'template') -Recurse -Force
    return $fixture
}

function Invoke-Checker {
    param(
        [string]$Fixture,
        [switch]$Json,
        [switch]$Explain
    )

    $before = Get-TreeHash -Path $Fixture
    $arguments = @('-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', $checker, '-Root', $Fixture)
    if ($Json) {
        $arguments += '-Json'
    }
    if ($Explain) {
        $arguments += '-Explain'
    }
    $output = @(& powershell.exe @arguments)
    $exitCode = $LASTEXITCODE
    $after = Get-TreeHash -Path $Fixture
    if ($before -cne $after) {
        throw 'checker modified a fixture'
    }
    return [PSCustomObject]@{ Output = $output; ExitCode = $exitCode }
}

function Assert-Test {
    param([string]$Name, [scriptblock]$Body)

    $script:testCount++
    try {
        & $Body
    }
    catch {
        Add-Failure ($Name + ': ' + $_.Exception.Message)
    }
}

try {
    New-Item -ItemType Directory -Path $tempRoot | Out-Null

    Assert-Test -Name 'valid_template_passes' -Body {
        $result = Invoke-Checker -Fixture (New-Fixture)
        if ($result.ExitCode -ne 0 -or ($result.Output -join "`n") -notmatch '^PASS: 7 checks$') { throw 'expected a passing default check' }
    }

    Assert-Test -Name 'missing_required_file_fails' -Body {
        $fixture = New-Fixture
        Remove-Item -LiteralPath (Join-Path $fixture 'template\.agent\LOG.md') -Force
        $result = Invoke-Checker -Fixture $fixture
        if ($result.ExitCode -eq 0 -or ($result.Output -join "`n") -notmatch 'required_file_missing') { throw 'missing required file was not reported' }
    }

    Assert-Test -Name 'claude_only_name_fails' -Body {
        $fixture = New-Fixture
        Add-Content -LiteralPath (Join-Path $fixture 'template\AGENTS.md') -Value 'AskUserQuestion' -Encoding UTF8
        $result = Invoke-Checker -Fixture $fixture
        if ($result.ExitCode -eq 0 -or ($result.Output -join "`n") -notmatch 'claude_only_asset') { throw 'Claude-only name was not reported' }
    }

    Assert-Test -Name 'todo_and_tbd_text_is_allowed' -Body {
        $fixture = New-Fixture
        Add-Content -LiteralPath (Join-Path $fixture 'template\AGENTS.md') -Value 'TODO and TBD may be ordinary task labels.' -Encoding UTF8
        $result = Invoke-Checker -Fixture $fixture
        if ($result.ExitCode -ne 0) { throw 'ordinary TODO or TBD text was reported as a placeholder' }
    }

    Assert-Test -Name 'lite_default_state_machine_fails' -Body {
        $fixture = New-Fixture
        Add-Content -LiteralPath (Join-Path $fixture 'template\.agents\skills\workflow-lite\SKILL.md') -Value 'Read .agent/STATE_MACHINE.md before every Lite task.' -Encoding UTF8
        $result = Invoke-Checker -Fixture $fixture
        if ($result.ExitCode -eq 0 -or ($result.Output -join "`n") -notmatch 'lite_state_machine_reference') { throw 'Lite default state-machine dependency was not reported' }
    }

    Assert-Test -Name 'explain_includes_error_detail' -Body {
        $fixture = New-Fixture
        Add-Content -LiteralPath (Join-Path $fixture 'template\AGENTS.md') -Value 'AskUserQuestion' -Encoding UTF8
        $result = Invoke-Checker -Fixture $fixture -Explain
        $text = $result.Output -join "`n"
        if ($result.ExitCode -eq 0 -or $text -notmatch 'claude_only_asset' -or $text -notmatch 'AskUserQuestion') { throw 'Explain output did not include error detail' }
    }

    Assert-Test -Name 'json_is_parseable_and_stable' -Body {
        $fixture = New-Fixture
        $first = Invoke-Checker -Fixture $fixture -Json
        $second = Invoke-Checker -Fixture $fixture -Json
        $firstText = $first.Output -join "`n"
        $secondText = $second.Output -join "`n"
        if ($first.ExitCode -ne 0 -or $second.ExitCode -ne 0) { throw 'JSON check did not pass' }
        $parsed = $firstText | ConvertFrom-Json
        if (-not $parsed.passed -or $parsed.checks -ne 7) { throw 'JSON result was incomplete' }
        if ($firstText -cne $secondText) { throw 'JSON result was not stable' }
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
foreach ($failure in $failures) {
    Write-Output ('- ' + $failure)
}
exit 1
