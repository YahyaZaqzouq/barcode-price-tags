@echo off
chcp 65001 >nul
title طباعة الاستيكرات - مباشر

rem ==========================================================
rem  يفتح أداة الاستيكرات في وضع الطباعة المباشرة (kiosk-printing)
rem  يعني لما تضغط زر الطباعة يطبع على طول من غير نافذة الإعدادات
rem ==========================================================

set "URL=https://yahyazaqzouq.github.io/barcode-price-tags/"
set "PROFILE=%LOCALAPPDATA%\PriceTagPrint"

set "CHROME=%ProgramFiles%\Google\Chrome\Application\chrome.exe"
if not exist "%CHROME%" set "CHROME=%ProgramFiles(x86)%\Google\Chrome\Application\chrome.exe"
if not exist "%CHROME%" set "CHROME=%LOCALAPPDATA%\Google\Chrome\Application\chrome.exe"

set "EDGE=%ProgramFiles%\Microsoft\Edge\Application\msedge.exe"
if not exist "%EDGE%" set "EDGE=%ProgramFiles(x86)%\Microsoft\Edge\Application\msedge.exe"

set "FLAGS=--kiosk-printing --user-data-dir=""%PROFILE%"" --no-first-run --new-window"

if exist "%CHROME%" (
  start "" "%CHROME%" %FLAGS% "%URL%"
  goto :end
)
if exist "%EDGE%" (
  start "" "%EDGE%" %FLAGS% "%URL%"
  goto :end
)

echo مفيش Google Chrome ولا Microsoft Edge على الجهاز.
echo نزّل Chrome من: https://www.google.com/chrome/
pause
exit /b 1

:end
exit /b 0
