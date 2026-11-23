# The commit gates, in order. Stops at the first failure.
# See docs/Testing.md for the reason behind each.
$ErrorActionPreference = 'Stop'
Set-Location $PSScriptRoot

function Invoke-Gate([string]$Name, [scriptblock]$Command) {
    Write-Host "== $Name"
    & $Command
    if ($LASTEXITCODE -ne 0) {
        Write-Host "FAILED: $Name"
        exit 1
    }
}

Invoke-Gate '1/4 flutter analyze' { flutter analyze }
Invoke-Gate '2/4 flutter test' { flutter test --reporter=failures-only }
Invoke-Gate '3/4 packs are what the generator makes' { dart run tool/generate_cases.dart --dry-run }
Invoke-Gate '4/4 every case: one answer, no guessing' { dart run tool/check_cases.dart }

Write-Host 'All gates green.'
