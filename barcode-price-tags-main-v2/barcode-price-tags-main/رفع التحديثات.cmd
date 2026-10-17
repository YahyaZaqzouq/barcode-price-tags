@echo off
chcp 65001 >nul
cd /d "%~dp0"
echo ============================================
echo   Upload updates to GitHub
echo ============================================
echo.

echo [1/2] Building item list from Excel ...
node build-inventory.js
if errorlevel 1 goto fail

echo.
echo [2/2] Uploading to GitHub ...
git add -A
git commit -m "update prices and items"
git push origin main
if errorlevel 1 goto fail

echo.
echo Done. The website updates within a minute:
echo https://yahyazaqzouq.github.io/barcode-price-tags/
goto end

:fail
echo.
echo Something went wrong - check the messages above.

:end
echo.
pause
