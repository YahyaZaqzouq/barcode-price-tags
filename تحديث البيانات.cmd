@echo off
chcp 65001 >nul
cd /d "%~dp0"
echo ============================================
echo   Update item list from Excel
echo ============================================
echo.
node build-inventory.js %*
echo.
pause
