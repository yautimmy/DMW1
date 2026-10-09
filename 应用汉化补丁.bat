@echo off
chcp 65001 >nul
setlocal EnableExtensions EnableDelayedExpansion
cd /d "%~dp0"

if "%~1"=="" (
  set "SOURCE=%~dp0DigimonWorld (Japan).bin"
) else (
  set "SOURCE=%~1"
)
set "PATCH=%~dp0DigimonWorld-CN-v214.xdelta"
set "OUTPUT=%~dp0DigimonWorld CN.bin"
set "EXPECTED_SOURCE=A99CE1CF5C3524B866603FE29F412C956131E7A2D48807E2508D9304BA6F20CD"
set "EXPECTED_OUTPUT=3664DC430D3FC10AA571AAE46DFF4C43012F39E2069A8F9F40021B2231CBEC5F"

if not exist "%SOURCE%" (
  echo ERROR: Japanese source BIN not found.
  echo Drag the original BIN onto this BAT, or name it DigimonWorld ^(Japan^).bin.
  pause
  exit /b 1
)
if not exist "%PATCH%" (
  echo ERROR: DigimonWorld-CN-v214.xdelta not found.
  pause
  exit /b 1
)
if not exist "%~dp0xdelta3.exe" (
  echo ERROR: xdelta3.exe not found.
  pause
  exit /b 1
)
if exist "%OUTPUT%" (
  echo ERROR: DigimonWorld CN.bin already exists.
  echo Move or rename it before running the patch again.
  pause
  exit /b 1
)

echo Checking the Japanese source BIN...
call :GetSHA256 "%SOURCE%" SOURCE_HASH
if errorlevel 1 (
  echo ERROR: Windows SHA-256 checker is unavailable.
  pause
  exit /b 1
)
if /I not "%SOURCE_HASH%"=="%EXPECTED_SOURCE%" (
  echo ERROR: Japanese source BIN SHA-256 mismatch.
  echo Actual:  %SOURCE_HASH%
  echo Expected: %EXPECTED_SOURCE%
  pause
  exit /b 1
)

echo Applying the v214 Chinese patch...
"%~dp0xdelta3.exe" -d -s "%SOURCE%" "%PATCH%" "%OUTPUT%"
if errorlevel 1 (
  echo ERROR: Patch application failed.
  pause
  exit /b 1
)

echo Checking the patched BIN...
call :GetSHA256 "%OUTPUT%" OUTPUT_HASH
if errorlevel 1 (
  echo ERROR: Windows SHA-256 checker is unavailable.
  pause
  exit /b 1
)
if /I not "%OUTPUT_HASH%"=="%EXPECTED_OUTPUT%" (
  echo ERROR: Patched BIN SHA-256 mismatch.
  echo Actual:  %OUTPUT_HASH%
  echo Expected: %EXPECTED_OUTPUT%
  pause
  exit /b 1
)

echo COMPLETE: DigimonWorld CN.bin
echo Start the game with DigimonWorld CN.cue
pause
exit /b 0

:GetSHA256
setlocal EnableDelayedExpansion
set "HASH_RESULT="
where powershell.exe >nul 2>nul
if not errorlevel 1 (
  for /f "usebackq delims=" %%H in (`powershell.exe -NoProfile -Command "try { (Get-FileHash -LiteralPath $args[0] -Algorithm SHA256).Hash } catch { exit 1 }" "%~1" 2^>nul`) do set "HASH_RESULT=%%H"
)
if not defined HASH_RESULT (
  where certutil.exe >nul 2>nul
  if not errorlevel 1 (
    for /f "skip=1 tokens=* delims=" %%H in ('certutil.exe -hashfile "%~1" SHA256 2^>nul') do if not defined HASH_RESULT set "HASH_RESULT=%%H"
    set "HASH_RESULT=!HASH_RESULT: =!"
  )
)
if not defined HASH_RESULT exit /b 1
for %%H in (!HASH_RESULT!) do set "HASH_RESULT=%%H"
endlocal & set "%~2=%HASH_RESULT%"
exit /b 0
