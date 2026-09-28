@echo off
setlocal
pushd "%~dp0.."
if exist ".local\flutter\bin\flutter.bat" (
  set "PUB_CACHE=%CD%\.local\pub-cache"
  call ".local\flutter\bin\flutter.bat" %*
) else (
  call flutter %*
)
set "flutterExitCode=%ERRORLEVEL%"
popd
exit /b %flutterExitCode%
