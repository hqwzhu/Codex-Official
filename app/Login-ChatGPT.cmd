@echo off
echo Codex ChatGPT account login
echo Choose "Sign in with ChatGPT" when Codex asks how to sign in.
echo.
choice /M "Continue"
if errorlevel 2 exit /b 1

if exist "%USERPROFILE%\.codex\auth.json" (
  copy "%USERPROFILE%\.codex\auth.json" "%USERPROFILE%\.codex\provider-switch\backups\auth-before-chatgpt-login.json" >nul
)

call codex logout
call codex login
echo.
echo Login flow finished. You can close this window after checking the result.
pause
