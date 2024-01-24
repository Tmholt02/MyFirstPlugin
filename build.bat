dotnet build

@echo off
if %ERRORLEVEL% neq 0 (
    exit /b %ERRORLEVEL%
)

setlocal enabledelayedexpansion

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
if exist "!OUTDIR!" (
    echo Directory not found: !OUTDIR!
    REM Rename all files in the directory by appending .old
    for %%f in ("!OUTDIR!\*") do (
        ren "%%f" "%%~nxf.old"
    )
)

echo Renaming complete.

@echo on
tcli build
@echo off

REM Delete all .old files in the directory
for /f "delims=" %%x in ('dir "!OUTDIR!\*.old" /b /a-d 2^>nul') do (
    del /f /q "!OUTDIR!\%%x"
)

echo Finished building successfuly! (build.bat)