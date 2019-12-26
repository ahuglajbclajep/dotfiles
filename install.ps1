# powershell -executionpolicy remotesigned .\install.ps1

$ErrorActionPreference = "Stop"
trap { Pop-Location }
Push-Location "$PSScriptRoot"

# see https://devblogs.microsoft.com/scripting/check-for-admin-credentials-in-a-powershell-script/
$isadmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(
    [Security.Principal.WindowsBuiltInRole] "Administrator")

$wtdir = Get-ChildItem "$env:LOCALAPPDATA/Packages" | Where-Object Name -match 'WindowsTerminal' |`
    Select-Object -ExpandProperty 'FullName'

$mappings = @(
    @{ 'from' = '.config\Code\User\settings.json'; 'to' = "$env:APPDATA\Code\User\settings.json" },
    @{ 'from' = 'other\profiles.json'; 'to' = "$wtdir\LocalState\profiles.json" }
)

if ($isadmin) {
    foreach ($m in $mappings) {
        New-Item -ItemType Directory -Path (Split-Path -Parent $m.to) -Force > $null
        New-Item -ItemType SymbolicLink -Path $m.to -Value $m.from -Force -cf > $null
    }
}
else {
    Write-Host 'creating a symbolic link on Windows requires elevation as administrator.' -ForegroundColor Red
}

$yn = Read-Host 'install VS Code extensions? (y/N)'
if (($yn -eq 'y') -and (Get-Command 'code' -ea SilentlyContinue)) {
    foreach ($e in Get-Content 'other\vscode-extensions.txt') {
        code --install-extension "$e"
    }
}

Pop-Location
