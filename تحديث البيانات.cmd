@echo off
chcp 65001 >nul
cd /d "%~dp0"
echo ============================================
echo   تحديث قائمة الأصناف من ملف Excel
echo ============================================
echo.
node build-inventory.js %*
echo.
echo تم. اقفل النافذة وافتح بطاقات_تسعير.html
pause
