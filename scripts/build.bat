@Echo off
setlocal enabledelayedexpansion

###############################################################################
# Build Script for ADB Cleaner (Windows)
# Supports: Windows, Linux, macOS (cross-compile)
###############################################################################

REM Configuration
set APP_NAME=adb-cleaner
set VERSION=2.0.0
set BUILD_DIR=build
set DIST_DIR=dist

REM Colors (Windows 10+)
for /f %%i in ('echo prompt $E ^| cmd') do set "ESC=%%i"
set "RED=%ESC%[31m"
set "GREEN=%ESC%[32m"
set "YELLOW=%ESC%[33m"
set "BLUE=%ESC%[34m"
set "CYAN=%ESC%[36m"
set "NC=%ESC%[0m"

REM Print header
echo.
echo %BLUE%==========================================%NC%
echo %BLUE%  ADB Cleaner Build Script%NC%
echo %BLUE%==========================================%NC%
echo.

REM Print usage
if "%~1"=="" goto :usage
if "%~1"=="--help" goto :usage
if "%~1"=="/?" goto :usage

REM Check Go installation
where go >nul 2>nul
if %errorlevel% neq 0 (
    echo %RED%[ERROR] Go is not installed.%NC%
    echo Please install Go from https://golang.org/dl/
    exit /b 1
)

for /f "tokens=3" %%i in ('go version') do set GO_VERSION=%%i
echo %GREEN%[OK] Go version: %GO_VERSION%%NC%
echo.

REM Create build directories
if not exist "%BUILD_DIR%" mkdir "%BUILD_DIR%"
if not exist "%DIST_DIR%" mkdir "%DIST_DIR%"

REM Parse arguments
:parse_args
if "%~1"=="" goto :done
if "%~1"=="--windows" goto :build_windows
if "%~1"=="--windows-arm64" goto :build_windows_arm64
if "%~1"=="--linux" goto :build_linux
if "%~1"=="--linux-arm64" goto :build_linux_arm64
if "%~1"=="--macos" goto :build_macos
if "%~1"=="--macos-arm64" goto :build_macos_arm64
if "%~1"=="--all" goto :build_all
if "%~1"=="--clean" goto :clean_build

echo %RED%[ERROR] Unknown option: %~1%NC%
goto :usage

:build_windows
echo %BLUE%[INFO] Building for Windows/amd64...%NC%
call :download_deps
set GOOS=windows
set GOARCH=amd64
set OUTPUT=%BUILD_DIR%\%APP_NAME%-windows-amd64.exe
go build -ldflags "-s -w -X main.Version=%VERSION%" -o "%OUTPUT%" .\cmd\adb-cleaner
cd "%BUILD_DIR%"
powershell -Command "Compress-Archive -Path '%APP_NAME%-windows-amd64.exe' -DestinationPath '..\%DIST_DIR%\%APP_NAME%-windows-amd64.zip' -Force"
cd ..
echo %GREEN%[OK] Built: %APP_NAME%-windows-amd64.exe%NC%
shift
goto :parse_args

:build_windows_arm64
echo %BLUE%[INFO] Building for Windows/arm64...%NC%
call :download_deps
set GOOS=windows
set GOARCH=arm64
set OUTPUT=%BUILD_DIR%\%APP_NAME%-windows-arm64.exe
go build -ldflags "-s -w -X main.Version=%VERSION%" -o "%OUTPUT%" .\cmd\adb-cleaner
cd "%BUILD_DIR%"
powershell -Command "Compress-Archive -Path '%APP_NAME%-windows-arm64.exe' -DestinationPath '..\%DIST_DIR%\%APP_NAME%-windows-arm64.zip' -Force"
cd ..
echo %GREEN%[OK] Built: %APP_NAME%-windows-arm64.exe%NC%
shift
goto :parse_args

:build_linux
echo %BLUE%[INFO] Building for Linux/amd64...%NC%
call :download_deps
set GOOS=linux
set GOARCH=amd64
set OUTPUT=%BUILD_DIR%\%APP_NAME%-linux-amd64
go build -ldflags "-s -w -X main.Version=%VERSION%" -o "%OUTPUT%" .\cmd\adb-cleaner
cd "%BUILD_DIR%"
tar -czf "..\%DIST_DIR%\%APP_NAME%-linux-amd64.tar.gz" "%APP_NAME%-linux-amd64"
cd ..
echo %GREEN%[OK] Built: %APP_NAME%-linux-amd64%NC%
shift
goto :parse_args

:build_linux_arm64
echo %BLUE%[INFO] Building for Linux/arm64...%NC%
call :download_deps
set GOOS=linux
set GOARCH=arm64
set OUTPUT=%BUILD_DIR%\%APP_NAME%-linux-arm64
go build -ldflags "-s -w -X main.Version=%VERSION%" -o "%OUTPUT%" .\cmd\adb-cleaner
cd "%BUILD_DIR%"
tar -czf "..\%DIST_DIR%\%APP_NAME%-linux-arm64.tar.gz" "%APP_NAME%-linux-arm64"
cd ..
echo %GREEN%[OK] Built: %APP_NAME%-linux-arm64%NC%
shift
goto :parse_args

:build_macos
echo %BLUE%[INFO] Building for macOS/amd64...%NC%
call :download_deps
set GOOS=darwin
set GOARCH=amd64
set OUTPUT=%BUILD_DIR%\%APP_NAME%-macos-amd64
go build -ldflags "-s -w -X main.Version=%VERSION%" -o "%OUTPUT%" .\cmd\adb-cleaner
cd "%BUILD_DIR%"
tar -czf "..\%DIST_DIR%\%APP_NAME%-macos-amd64.tar.gz" "%APP_NAME%-macos-amd64"
cd ..
echo %GREEN%[OK] Built: %APP_NAME%-macos-amd64%NC%
shift
goto :parse_args

:build_macos_arm64
echo %BLUE%[INFO] Building for macOS/arm64...%NC%
call :download_deps
set GOOS=darwin
set GOARCH=arm64
set OUTPUT=%BUILD_DIR%\%APP_NAME%-macos-arm64
go build -ldflags "-s -w -X main.Version=%VERSION%" -o "%OUTPUT%" .\cmd\adb-cleaner
cd "%BUILD_DIR%"
tar -czf "..\%DIST_DIR%\%APP_NAME%-macos-arm64.tar.gz" "%APP_NAME%-macos-arm64"
cd ..
echo %GREEN%[OK] Built: %APP_NAME%-macos-arm64%NC%
shift
goto :parse_args

:build_all
echo %BLUE%[INFO] Building for all platforms...%NC%
call :build_windows
call :build_windows_arm64
call :build_linux
call :build_linux_arm64
call :build_macos
call :build_macos_arm64
shift
goto :parse_args

:clean_build
echo %YELLOW%[INFO] Cleaning build directory...%NC%
if exist "%BUILD_DIR%" rmdir /s /q "%BUILD_DIR%"
if exist "%DIST_DIR%" rmdir /s /q "%DIST_DIR%"
echo %GREEN%[OK] Build directory cleaned%NC%
shift
goto :parse_args

:download_deps
echo %BLUE%[INFO] Downloading dependencies...%NC%
go mod download
go mod tidy
echo %GREEN%[OK] Dependencies downloaded%NC%
exit /b

:usage
echo Usage: %~nx0 [OPTIONS]
echo.
echo Options:
echo   --windows        Build for Windows (amd64)
echo   --windows-arm64  Build for Windows (arm64)
echo   --linux          Build for Linux (amd64)
echo   --linux-arm64    Build for Linux (arm64)
echo   --macos          Build for macOS (amd64)
echo   --macos-arm64    Build for macOS (arm64)
echo   --all            Build for all platforms
echo   --clean          Clean build directory
echo   --help           Show this help message
echo.
echo Examples:
echo   %~nx0 --windows
echo   %~nx0 --all
echo   %~nx0 --macos --windows
exit /b 0

:done
echo.
echo %CYAN%==========================================%NC%
echo %CYAN%           Build Summary%NC%
echo %CYAN%==========================================%NC%
echo.
echo Version: %VERSION%
echo Build directory: %BUILD_DIR%
echo Distribution directory: %DIST_DIR%
echo.

if exist "%DIST_DIR%" (
    echo %GREEN%Built artifacts:%NC%
    dir "%DIST_DIR%" /b
)
echo.
echo %GREEN%[DONE] Build completed!%NC%
pause
