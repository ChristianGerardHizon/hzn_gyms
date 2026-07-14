@echo off
REM Cross-platform PocketBase server launcher (Windows)

SET SCRIPT_DIR=%~dp0
SET SERVER_DIR=%SCRIPT_DIR%server

REM Find pocketbase binary
WHERE pocketbase >nul 2>&1
IF %ERRORLEVEL% EQU 0 (
  SET PB_BIN=pocketbase
) ELSE IF EXIST "%SERVER_DIR%\pocketbase.exe" (
  SET PB_BIN=%SERVER_DIR%\pocketbase.exe
) ELSE (
  echo Error: pocketbase binary not found in PATH or server\
  exit /b 1
)

echo Starting PocketBase server (dev mode)...
echo Data dir:    %SERVER_DIR%\pb_data
echo Hooks dir:   %SERVER_DIR%\pb_hooks
echo Public dir:  %SERVER_DIR%\pb_public
%PB_BIN% serve --dir "%SERVER_DIR%\pb_data" --hooksDir "%SERVER_DIR%\pb_hooks" --publicDir "%SERVER_DIR%\pb_public" --dev
