@echo off
chcp 65001 >nul
cd /d "%~dp0"
echo ============================================
echo   رفع التحديثات على GitHub
echo ============================================
echo.

echo [1/2] تحديث قائمة الأصناف من Excel ...
node build-inventory.js
if errorlevel 1 goto fail

echo.
echo [2/2] رفع الملفات على GitHub ...
git add -A
git commit -m "تحديث الاسعار و الاصناف %date%"
git push origin main
if errorlevel 1 goto fail

echo.
echo تم الرفع بنجاح. الموقع هيتحدّث خلال دقيقة:
echo https://yahyazaqzouq.github.io/barcode-price-tags/
goto end

:fail
echo.
echo حصل خطأ. راجع الرسائل فوق.

:end
echo.
pause
