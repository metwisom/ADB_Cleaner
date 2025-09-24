@Echo off
setlocal enabledelayedexpansion

:: Check if ADB is installed
where adb >nul 2>nul
if %errorlevel% neq 0 (
    echo [ERROR] ADB not found. Please install it and add to PATH.
    pause
    exit /b
)

echo Starting debloat...

:: Read packages from packs.txt
for /f "usebackq tokens=* delims=" %%A in ("packs.txt") do (
    set "pkg=%%A"
    if not "!pkg!"=="" (
        echo Removing package: !pkg!
        adb shell pm uninstall --user 0 "!pkg!"
    )
)

echo Done! It is recommended to reboot your phone.
pause
