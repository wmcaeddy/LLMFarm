@echo off
echo LLM Chat Flutter Demo Launcher
echo ================================
echo.
echo Choose your platform:
echo 1. Web (Chrome)
echo 2. Windows Desktop
echo 3. Build Web Version
echo 4. Run Tests
echo.
set /p choice="Enter your choice (1-4): "

if "%choice%"=="1" (
    echo Launching on Chrome...
    flutter run -d chrome
) else if "%choice%"=="2" (
    echo Launching on Windows Desktop...
    flutter run -d windows
) else if "%choice%"=="3" (
    echo Building Web Version...
    flutter build web
    echo Web build completed! Check build/web folder.
) else if "%choice%"=="4" (
    echo Running Tests...
    flutter test
) else (
    echo Invalid choice. Please run the script again.
)

pause 