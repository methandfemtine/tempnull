@echo off
setlocal EnableDelayedExpansion
title EES   -   6arth / pine

net session >nul 2>&1
if %errorlevel% neq 0 (
    echo Requesting administrative privileges...
    goto UACPrompt
)
goto gotAdmin

:UACPrompt
echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
echo UAC.ShellExecute "%~f0", "", "", "runas", 1 >> "%temp%\getadmin.vbs"
cscript "%temp%\getadmin.vbs" >nul
del "%temp%\getadmin.vbs"
exit /b

:gotAdmin
cd /d "%~dp0"

echo Administrative privileges obtained.
echo [+] Checking for WSL...

where wsl >nul 2>&1
if %errorlevel% neq 0 (
    echo [+] WSL not installed at all.
    goto install_wsl
)

wsl -l -q >nul 2>&1
if %errorlevel% neq 0 (
    echo [+] WSL installed but no distro found.
    goto install_wsl
)

echo [+] WSL is already installed and ready.
goto continue

:install_wsl
echo.
echo [+] Installing WSL, this WILL reboot your PC, please Prepare.
echo [!] Please Refrain from Highlighting anything, if you do right click. Interact to continue
pause >nul

wsl --install 
wsl -d Arch -- echo "found" >nul 2>&1
if %errorlevel% neq 0 (
    shutdown /r /t 0
)

echo.
echo WSL installation started.   Interact.
echo Please RESTART your PC.     To.
echo Then run this script again. Continue.
pause >nul
exit /b

:continue
set "DOWNLOAD_URL=https://github.com/methandfemtine/tempnull/releases/download/die1/EOSSDK-Win64-Shipping.dll"
set "TEMP_DLL=%TEMP%\EOSSDK-Win64-Shipping.dll"

set "VRC_PATH=%ProgramFiles(x86)%\Steam\steamapps\common\VRChat\VRChat.exe"
set "PLUGIN_DIR=%ProgramFiles(x86)%\Steam\steamapps\common\VRChat\VRChat_Data\Plugins\x86_64"

echo [+] Downloading EOSSDK DLL...

where curl >nul 2>&1
if %errorlevel% equ 0 (
    curl -L "%DOWNLOAD_URL%" -o "%TEMP_DLL%"
) else (
    echo [-] curl not found, using PowerShell...
    powershell -Command "Invoke-WebRequest -Uri '%DOWNLOAD_URL%' -OutFile '%TEMP_DLL%'"
)

if not exist "%TEMP_DLL%" (
    echo [-] DLL download failed.
    pause
    exit /b
)

if not exist "%PLUGIN_DIR%" (
    echo [+] Creating plugin directory...
    mkdir "%PLUGIN_DIR%"
)

echo [+] Moving DLL...
move /Y "%TEMP_DLL%" "%PLUGIN_DIR%\EOSSDK-Win64-Shipping.dll" >nul

echo [*] Opening a new WSL Window.
start "" cmd /k wsl bash -c "curl -fsSL 'https://github.com/methandfemtine/tempnull/releases/download/tuff/EES.sh' -o EES.sh && bash EES.sh; exec bash"

echo.
choice /M "Would you like to open VRChat.exe?"

if %errorlevel%==1 (
    if exist "%VRC_PATH%" (
        echo [+] Launching VRChat...
        start "" "%VRC_PATH%"
    ) else (
        echo [-] VRChat not found at expected path.
    )
) else (
    echo [+] User chose NOT to open VRChat.
)

echo [+] Done.
sleep 5