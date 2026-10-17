@echo off
title Install Price Tag Stickers shortcut
echo ==========================================
echo   Install "Price Tag Stickers" shortcut
echo ==========================================
echo.
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0install-shortcut.ps1"
echo.
pause
