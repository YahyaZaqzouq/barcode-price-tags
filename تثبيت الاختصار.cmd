@echo off
chcp 65001 >nul
title Install Price Tag Stickers shortcut
echo ==========================================
echo   Install "Price Tag Stickers" shortcut
echo ==========================================
echo.
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0install-shortcut.ps1"
echo.
pause
