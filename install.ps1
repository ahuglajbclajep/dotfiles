# powershell -executionpolicy remotesigned .\install.ps1

$ErrorActionPreference = "Stop"
Push-Location "$PSScriptRoot"

$mappings = @(
    @{ 'from' = '.config\Code\User\settings.json'; 'to' = "$env:APPDATA\Code\User\settings.json" },
    @{ 'from' = 'other\profiles.json'; 'to' = '' }
)

try {
    foreach ($m in $mappings) {
        New-Item -ItemType Directory -Path (Split-Path -Parent $m.to) -Force
        New-Item -ItemType SymbolicLink -Path $m.to -Value $m.from -Force -Confirm
    }
}
catch [UnauthorizedAccessException] { }

# for vscode
if (get-command code -ea stop) { }

trap { Pop-Location }
