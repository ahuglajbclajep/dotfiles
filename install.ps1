# powershell -executionpolicy remotesigned .\install.ps1

$ErrorActionPreference = "Stop"
Push-Location "$PSScriptRoot"
trap { Pop-Location }

$mappings = @(
    @{ 'from' = '.config\Code\User\settings.json'; 'to' = "$env:APPDATA\Code\User\settings.json" }
    @{ 'from' = 'other\profiles.json'; 'to' = '' }
)

try {
    foreach ($m in $mappings) {
        New-Item -ItemType Directory -Path (Split-Path -Parent $m.to) -Force > $null
        New-Item -ItemType SymbolicLink -Path $m.to -Value $m.from -Force -Confirm > $null
    }
}
catch [UnauthorizedAccessException] {
    $ErrorActionPreference = "SilentlyContinue"
}

# for vscode
if (get-command code -ea stop) { }

Pop-Location
