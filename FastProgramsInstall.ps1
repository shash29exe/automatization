if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

$Host.UI.RawUI.WindowTitle = "Fast Programs Install"
$ProgressPreference = 'SilentlyContinue'

Write-Host "Removing Microsoft Edge..." -ForegroundColor Yellow

Get-Process | Where-Object { $_.Name -like "*msedge*" -or $_.Name -like "*edge*" } | Stop-Process -Force -ErrorAction SilentlyContinue
Get-Service | Where-Object { $_.Name -like "*edge*" } | Stop-Service -Force -ErrorAction SilentlyContinue

$edgeUninstallers = @()
'ProgramFilesX86', 'ProgramFiles', 'LocalApplicationData' | ForEach-Object {
    $folder = [Environment]::GetFolderPath($_)
    $edgeUninstallers += Get-ChildItem "$folder\Microsoft\Edge*\setup.exe" -Recurse -ErrorAction SilentlyContinue |
        Where-Object { $_.FullName -like "*Edge\Application*" }
}

foreach ($setup in $edgeUninstallers) {
    if (Test-Path $setup.FullName) {
        Start-Process -FilePath $setup.FullName -ArgumentList "--uninstall --msedge --system-level --channel=stable --force-uninstall" -Wait -WindowStyle Hidden
    }
}

Remove-Item "$([Environment]::GetFolderPath('Desktop'))\Microsoft Edge.lnk" -Force -ErrorAction SilentlyContinue
Remove-Item "$([Environment]::GetFolderPath('CommonStartMenu'))\Microsoft Edge.lnk" -Force -ErrorAction SilentlyContinue

Write-Host "Complete!" -ForegroundColor Green

# 2
mkdir "$env:TEMP\installers" -Force > $null
cd "$env:TEMP\installers"

Write-Host "Downloading program installers..." -ForegroundColor Yellow
$link = ((Invoke-RestMethod 'https://www.7-zip.org/download.html') | Select-String -Pattern 'a/7z\d+-x64\.exe').Matches[0].Value
Invoke-WebRequest -Uri "https://www.7-zip.org/$link" -OutFile "7zip.exe"
$link_vlc = ((Invoke-RestMethod 'https://get.videolan.org/vlc/last/win64/') | Select-String -Pattern 'vlc-[\d\.]+-win64\.exe(?=")').Matches[0].Value
Invoke-WebRequest -Uri "https://ftp.halifax.rwth-aachen.de/videolan/vlc/last/win64/$link_vlc" -OutFile "vlc.exe" -UseBasicParsing
Invoke-WebRequest -Uri "https://download.mozilla.org/?product=firefox-latest&os=win&lang=en-US" -OutFile "firefox.exe"
Invoke-WebRequest -Uri "https://go.microsoft.com/fwlink/p/?LinkId=2099617" -OutFile "webview2.exe"
Invoke-WebRequest -Uri "https://c2rsetup.officeapps.live.com/c2r/download.aspx?ProductreleaseID=Home2024Retail&platform=x64&language=ru-ru&version=O16GA" -OutFile "MSOffice.exe"
Invoke-WebRequest -Uri "https://www.glenn.delahoy.com/downloads/sdio/SDIO_1.18.0.830.zip" -OutFile "SDIO.zip"

Write-Host "extracting SDIO..." -ForegroundColor Cyan
Expand-Archive -Path "SDIO.zip" -DestinationPath "$env:USERPROFILE\Downloads\SDIO" -Force
Write-Host "Complete!" -ForegroundColor Green

$ProgressPreference = 'Continue'

Write-Host "Installing 7-Zip..." -ForegroundColor Cyan
Start-Process -FilePath ".\7zip.exe" -ArgumentList "/S" -Wait
Write-Host "Complete!" -ForegroundColor Green


Write-Host "Installing VLC..." -ForegroundColor Cyan
Start-Process -FilePath ".\vlc.exe" -ArgumentList "/S" -Wait
Write-Host "Complete!" -ForegroundColor Green


Write-Host "Installing Firefox..." -ForegroundColor Cyan
Start-Process -FilePath ".\firefox.exe" -ArgumentList "/S" -Wait
Write-Host "Complete!" -ForegroundColor Green


Write-Host "Installing WebView2..." -ForegroundColor Cyan
Start-Process -FilePath ".\webview2.exe" -ArgumentList "/silent /install" -Wait
Write-Host "Complete!" -ForegroundColor Green


Write-Host "Installing MS Office..." -ForegroundColor Cyan
Start-Process -FilePath ".\MSOffice.exe" -Wait
Write-Host "Complete!" -ForegroundColor Green


cd "$env:TEMP"
Remove-Item ".\installers" -Recurse -Force -ErrorAction SilentlyContinue


Write-Host "Starting massgrave's activator..." -ForegroundColor Green
irm https://get.activated.win | iex
