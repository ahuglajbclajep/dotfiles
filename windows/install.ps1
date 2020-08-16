$ErrorActionPreference = "Stop"

# this line also works if you write `bash -c "sed -i 's/^#//' ../vscode/_extensions.txt"`
# via an array of bytes to save the input file in UTF8 without BOM
[Text.Encoding]::UTF8.GetBytes(((Get-Content '..\vscode\_extensions.txt' |
        ForEach-Object { $_ -replace '^#', '' }) -join "`n") + "`n") |
    Set-Content '..\vscode\_extensions.txt' -Encoding Byte

# see https://devblogs.microsoft.com/scripting/check-for-admin-credentials-in-a-powershell-script/
$isadmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(
  [Security.Principal.WindowsBuiltInRole]"Administrator")

$wt = "$env:LOCALAPPDATA\Microsoft\WindowsApps\wt.exe"
$wtdir = Get-ChildItem "$env:LOCALAPPDATA\Packages" | Where-Object Name -Match 'WindowsTerminal' |
  Select-Object -ExpandProperty 'FullName'
$bin = "$HOME\app\bin"

$mappings = @(
  @{ 'name' = 'vscode'; 'from' = '..\vscode'; 'to' = "$env:APPDATA\Code\User" },
  @{ 'name' = 'terminal'; 'from' = 'terminal'; 'to' = "$wtdir\LocalState" }
)


$yn = Read-Host 'create symbolic links? (y/N)'
if ($yn -eq 'y') {
  # powershell 5.x requires an administrator privilege to execute the `ln` command
  if (!$isadmin) {
    Write-Host 'creating a symbolic link on Windows requires elevation as administrator.' -ForegroundColor Red
  } else {
    foreach ($m in $mappings) {
      # if Windows Terminal is not installed, do nothing because the path of the configuration directory is unknown
      if (($m.name -eq 'terminal') -and (!$wtdir)) { continue }

      foreach ($file in Get-ChildItem $m.from -Recurse -File -Exclude '_*' -Name) {
        $target = "$($m.to)\$file"
        New-Item -ItemType Directory -Path (Split-Path -Parent $target) -Force > $null
        # see https://docs.microsoft.com/powershell/module/microsoft.powershell.core/about/about_commonparameters#confirm
        New-Item -ItemType SymbolicLink -Path $target -Value "$($m.from)\$file" -Force -cf:(Test-Path $target) > $null
      }
    }
  }
}

$yn = Read-Host 'add "Open in Windows Terminal" into right-click context menu? (y/N)'
if ($yn -eq 'y') {
  New-Item -Path "HKCU:\Software\Classes\Directory\Background\shell\MyTerminal" -Value 'Open in Windows Terminal' -Force > $null
  New-Item -Path "HKCU:\Software\Classes\Directory\Background\shell\MyTerminal\command" -Value "$wt -d `"%V`"" -Force > $null
}

$yn = Read-Host 'install wslgit? (y/N)'
if ($yn -eq 'y') {
  # add ~\app\bin to the `$env:Path`
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
  foreach ($extension in Get-Content '..\vscode\_extensions.txt') {
    code --install-extension "$extension"
  }
}
