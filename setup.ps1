$ErrorActionPreference = 'Stop'

$desktop = Join-Path $PSScriptRoot 'apps/DotfilesSync/desktop'
$linuxProject = Join-Path $desktop 'linux'
$destination = Join-Path $env:LOCALAPPDATA 'Programs/DotfilesSync'
$shortcutPath = Join-Path ([Environment]::GetFolderPath('Programs')) 'Dotfiles Sync.lnk'

function Invoke-CheckedCommand {
    param(
        [Parameter(Mandatory = $true)][string]$Command,
        [Parameter(ValueFromRemainingArguments = $true)][string[]]$Arguments
    )

    & $Command @Arguments
    if ($LASTEXITCODE -ne 0) {
        throw "$Command failed with exit code $LASTEXITCODE."
    }
}

if (-not (Get-Command node -ErrorAction SilentlyContinue)) {
    throw 'Node.js 22 or later is required to build Dotfiles Sync.'
}
if (-not (Get-Command yarn -ErrorAction SilentlyContinue)) {
    throw 'Yarn 1.22 or later is required to build Dotfiles Sync.'
}
$nodeVersion = [version]((& node --version).TrimStart('v'))
if ($nodeVersion -lt [version]'22.0') {
    throw "Node.js 22 or later is required; found $nodeVersion."
}
$yarnVersion = [version](& yarn --version)
if ($yarnVersion -lt [version]'1.22') {
    throw "Yarn 1.22 or later is required; found $yarnVersion."
}

Push-Location $desktop
try {
    Invoke-CheckedCommand yarn install --frozen-lockfile
    Invoke-CheckedCommand yarn linux:install
    Invoke-CheckedCommand yarn windows:build
}
finally {
    Pop-Location
}

$builtApp = Get-ChildItem (Join-Path $linuxProject 'dist') -Filter '*.exe' -File |
    Sort-Object LastWriteTime -Descending |
    Select-Object -First 1
if (-not $builtApp) {
    throw 'The Windows build did not produce an executable in apps/DotfilesSync/desktop/linux/dist.'
}

New-Item -ItemType Directory -Path $destination -Force | Out-Null
$installedApp = Join-Path $destination 'DotfilesSync.exe'
Copy-Item $builtApp.FullName $installedApp -Force

$shell = New-Object -ComObject WScript.Shell
$shortcut = $shell.CreateShortcut($shortcutPath)
$shortcut.TargetPath = $installedApp
$shortcut.WorkingDirectory = $destination
$shortcut.Description = 'Dotfiles Sync'
$shortcut.Save()

Write-Host "Installed Dotfiles Sync to $installedApp"
