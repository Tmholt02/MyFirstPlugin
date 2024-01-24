@echo off
setlocal enableDelayedExpansion

REM Set the base extraction path here
set "BASE_EXTRACT_PATH=c:\Users\tmhol\AppData\Roaming\Thunderstore Mod Manager\DataFolder\LethalCompany\profiles\dev\BepInEx\plugins"
set "TOML_FILE=thunderstore.toml"
set "KEY=outdir"

REM Find the outdir line and extract the value
for /f "tokens=*" %%a in ('findstr /b /c:"%KEY% = " "%TOML_FILE%"') do (
    set "LINE=%%a"
)

REM Extract the path, removing 'outdir = ' and trimming quotes
for /f "tokens=2 delims==" %%b in ("!LINE!") do (
    set "OUTDIR=%%b"
)
set OUTDIR=!OUTDIR:"=!
set OUTDIR=!OUTDIR: =!

REM Check if the directory exists
if not exist "!OUTDIR!" (
    echo Directory not found: !OUTDIR!
    exit /b 1
)

cd !OUTDIR!

REM Check for any zip file in the directory
for %%f in (*.zip) do (
    REM Extract the filename without extension
    set "FILENAME=%%~nf"
    REM Call another block to use the updated variable
    call :extract "%%f"
    exit /b 1
)

REM If we reach this point, no zip files were found
echo No zip files found in .\build directory. Halting script.
exit /b 1

:extract
REM Create a new extraction path with the (devdeploy) suffix
set "EXTRACT_PATH=%BASE_EXTRACT_PATH%\!FILENAME!(devdeploy)"

REM Delete existing directories ending with (devdeploy)
for /d %%d in ("%BASE_EXTRACT_PATH%\*(devdeploy)") do (
    echo Deleting existing dev deployment...
    rmdir /s /q "%%d"
)

REM Make the new directory
mkdir "!EXTRACT_PATH!"

REM Extract the zip file using PowerShell
powershell -command "& { Add-Type -A 'System.IO.Compression.FileSystem'; [IO.Compression.ZipFile]::ExtractToDirectory('%~1', '!EXTRACT_PATH!'); }"
if !ERRORLEVEL! neq 0 (
    echo Failed to extract %~1.
    exit /b !ERRORLEVEL!
) else (
    echo Extraction of build %~1 successful.
    exit /b 0
)
