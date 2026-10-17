@echo off
chcp 65001 >nul
title تثبيت اختصار الاستيكرات
echo ============================================
echo   تثبيت اختصار "الاستيكرات - طباعة مباشرة"
echo ============================================
echo.
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0install-shortcut.ps1"
echo.
pause
