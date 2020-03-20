$ErrorActionPreference = "Stop"

# see https://devblogs.microsoft.com/scripting/check-for-admin-credentials-in-a-powershell-script/
$isadmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(
    [Security.Principal.WindowsBuiltInRole] "Administrator")

$wt = "$env:LOCALAPPDATA\Microsoft\WindowsApps\wt.exe"
$wtdir = Get-ChildItem "$env:LOCALAPPDATA\Packages" | Where-Object Name -match 'WindowsTerminal' |
    Select-Object -ExpandProperty 'FullName'

$mappings = @(
    @{ 'name' = 'code'; 'from' = '..\vscode\settings.json'; 'to' = "$env:APPDATA\Code\User\settings.json" },
    @{ 'name' = 'wt'; 'from' = 'profiles.json'; 'to' = "$wtdir\LocalState\profiles.json" }
)


$yn = Read-Host 'create symbolic links? (y/N)'
if ($yn -eq 'y') {
    if (!$isadmin) {
        Write-Host 'creating a symbolic link on Windows requires elevation as administrator.' -ForegroundColor Red
    } else {
        foreach ($m in $mappings) {
            if (($m.name -eq 'wt') -and (!$wtdir)) { continue }

            New-Item -ItemType Directory -Path (Split-Path -Parent $m.to) -Force > $null
            # see https://docs.microsoft.com/powershell/module/microsoft.powershell.core/about/about_commonparameters#confirm
            New-Item -ItemType SymbolicLink -Path $m.to -Value $m.from -Force -cf:(Test-Path $m.to) > $null
        }
    }
}

$yn = Read-Host 'add "Open with Terminal" into right-click context menu? (y/N)'
if ($yn -eq 'y') {
    $targets = @('Directory', 'Directory\Background')

    foreach ($t in $targets) {
        New-Item -Path "HKCU:\Software\Classes\$t\shell\MyTerminal" -Value 'Open with Terminal' -Force > $null
        New-Item -Path "HKCU:\Software\Classes\$t\shell\MyTerminal\command" -Value "$wt -d `"%V`"" -Force > $null
    }
}

$yn = Read-Host 'install wslgit? (y/N)'
if ($yn -eq 'y') {
    $bin = "$HOME\app\bin"

    # see https://stackoverflow.com/questions/714877/setting-windows-powershell-environment-variables
    $path = [Environment]::GetEnvironmentVariable('Path', [EnvironmentVariableTarget]::User) -replace ';$', ''
    if (($path -split ';') -notcontains $bin) {
        [Environment]::SetEnvironmentVariable('Path', "$path;$bin;", [EnvironmentVariableTarget]::User)
        # see https://stackoverflow.com/questions/17794507/reload-the-path-in-powershell
        $env:Path = [Environment]::GetEnvironmentVariable('Path', [EnvironmentVariableTarget]::User)
    }

    New-Item -ItemType Directory -Path $bin -Force > $null
    Invoke-WebRequest 'https://github.com/andy-5/wslgit/releases/latest/download/wslgit.exe' -OutFile "$bin\git.exe"
    Write-Host (git --version)
}

$yn = Read-Host 'install VS Code extensions? (y/N)'
if (($yn -eq 'y') -and (Get-Command 'code' -ea SilentlyContinue)) {
    foreach ($e in Get-Content '..\vscode\_extensions.txt') {
        code --install-extension "$e"
    }
}
