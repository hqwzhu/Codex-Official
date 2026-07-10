@echo off
setlocal
cd /d "%~dp0"
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0installer\install.ps1"
echo.
echo Installation finished. If you saw no error above, open "Codex Provider Switcher" from Desktop or Start menu.
pause
