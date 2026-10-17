@echo off
title Price Tag Stickers - Direct Print

rem ==========================================================
rem  Opens the price-tag tool in direct-print mode
rem  (kiosk-printing): prints straight to the default printer
rem  with no settings dialog.
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
  start "" "%CHROME%" --kiosk-printing --no-first-run --user-data-dir="%PROFILE%" --app=%URL%
  goto :end
)
if exist "%BRAVE%" (
  start "" "%BRAVE%" --kiosk-printing --no-first-run --user-data-dir="%PROFILE%" --app=%URL%
  goto :end
)
if exist "%EDGE%" (
  start "" "%EDGE%" --kiosk-printing --no-first-run --user-data-dir="%PROFILE%" --app=%URL%
  goto :end
)

echo Google Chrome, Brave, or Microsoft Edge not found.
echo Install Chrome from: https://www.google.com/chrome/
pause
exit /b 1

:end
exit /b 0