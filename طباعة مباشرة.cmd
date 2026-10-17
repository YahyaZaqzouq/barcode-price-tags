@echo off
title Price Tag Stickers - Print Settings

rem ==========================================================
rem  Opens the price-tag tool. The print dialog is SHOWN so the
rem  settings (orientation = landscape, margins = none, scale = 100%)
rem  can be set. Chrome remembers them in this browser profile.
rem ==========================================================

set "URL=https://yahyazaqzouq.github.io/barcode-price-tags/"
set "PROFILE=%LOCALAPPDATA%\PriceTagPrint"

set "CHROME=%ProgramFiles%\Google\Chrome\Application\chrome.exe"
if not exist "%CHROME%" set "CHROME=%ProgramFiles(x86)%\Google\Chrome\Application\chrome.exe"
if not exist "%CHROME%" set "CHROME=%LOCALAPPDATA%\Google\Chrome\Application\chrome.exe"

set "BRAVE=%ProgramFiles%\BraveSoftware\Brave-Browser\Application\Brave.exe"
if not exist "%BRAVE%" set "BRAVE=%LOCALAPPDATA%\BraveSoftware\Brave-Browser\Application\Brave.exe"

set "EDGE=%ProgramFiles%\Microsoft\Edge\Application\msedge.exe"
if not exist "%EDGE%" set "EDGE=%ProgramFiles(x86)%\Microsoft\Edge\Application\msedge.exe"

if exist "%CHROME%" (
  start "" "%CHROME%" --no-first-run --user-data-dir="%PROFILE%" --app=%URL%
  goto :end
)
if exist "%BRAVE%" (
  start "" "%BRAVE%" --no-first-run --user-data-dir="%PROFILE%" --app=%URL%
  goto :end
)
if exist "%EDGE%" (
  start "" "%EDGE%" --no-first-run --user-data-dir="%PROFILE%" --app=%URL%
  goto :end
)

echo Google Chrome, Brave, or Microsoft Edge not found.
echo Install Chrome from: https://www.google.com/chrome/
pause
exit /b 1

:end
exit /b 0