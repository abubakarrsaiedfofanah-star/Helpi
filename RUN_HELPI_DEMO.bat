@echo off
setlocal
cd /d "%~dp0frontend"
echo Starting Helpi App Preview...
where flutter >nul 2>nul
if errorlevel 1 (
  echo Flutter was not found in PATH.
  echo Open this folder in Android Studio and configure Flutter first.
  pause
  exit /b 1
)
flutter pub get
if errorlevel 1 (
  echo Flutter dependencies could not be installed.
  pause
  exit /b 1
)
flutter run --dart-define=HELPI_DEMO=true
