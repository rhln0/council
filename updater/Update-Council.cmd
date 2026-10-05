@echo off
set "COUNCIL_INSTALL=%USERPROFILE%\Downloads\Council-Chrome-Extension\council"
if not exist "%COUNCIL_INSTALL%\manifest.json" set "COUNCIL_INSTALL=%~dp0."
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "$ErrorActionPreference='Stop'; try { $p=$env:COUNCIL_INSTALL; Invoke-WebRequest -UseBasicParsing 'https://raw.githubusercontent.com/rhln0/council/main/updater/Update-Council.ps1' -OutFile (Join-Path $p 'Update-Council.ps1'); & (Join-Path $p 'Update-Council.ps1') -InstallPath $p } catch { Write-Host $_.Exception.Message -ForegroundColor Red; exit 1 }"
pause
