@echo off
setlocal enabledelayedexpansion

:: ===============================
:: Function: Show usage/help
:: ===============================
if "%~1"=="" goto :show_help
if /I "%~1"=="--help" goto :show_help
if /I "%~1"=="-h" goto :show_help

goto :main

:show_help
echo.
echo ============================================
echo MKV Mux Tool - Automated Video Muxing Script
echo ============================================
echo.
echo Usage:
echo     %~n0 [files...]
echo.
echo Description:
echo     This script combines video, audio, subtitle, and chapter files
echo     into a single MKV file using MKVToolNix tools (mkvmerge, mkvextract).
echo.
echo Supported file types:
echo     Video:    mkv, mp4, avi, mov, avc, hevc, h264
echo     Audio:    aac, eac3, flac, m4a, ac3
echo     Subtitles: srt, ass, vtt
echo     Chapters: xml
echo     Attachments: zip (contents extracted automatically)
echo.
echo Example:
echo     %~n0 video.mkv audio.flac subs.srt chapters.xml fonts.zip
echo.
echo Notes:
echo     - If the video is MKV and no audio is provided, the script will
echo       extract the first audio track automatically.
echo     - Attachments inside ZIP files will be added to the final MKV.
echo.
pause
exit /b

:main
:: ===============================
:: Check if mkvmerge and mkvextract are installed
:: ===============================
where mkvmerge >nul 2>&1
if errorlevel 1 (
    echo ERROR: mkvmerge not found. Please install MKVToolNix and try again.
    pause
    exit /b
)
where mkvextract >nul 2>&1
if errorlevel 1 (
    echo ERROR: mkvextract not found. Please install MKVToolNix and try again.
    pause
    exit /b
)

:: ===============================
:: Initialize variables
:: ===============================
set "VIDEO="
set "AUDIO="
set "SUB="
set "CHAPTERS="
set "TMPFOLDERS="

:: ===============================
:: Process input arguments
:: ===============================
for %%F in (%*) do (
    set "FILE=%%~F"
    set "EXT=%%~xF"
    set "EXT=!EXT:~1!"  :: Remove leading dot

    :: Detect video files
    if /I "!EXT!"=="mkv"  set "VIDEO=!FILE!"
    if /I "!EXT!"=="mp4"  set "VIDEO=!FILE!"
    if /I "!EXT!"=="avi"  set "VIDEO=!FILE!"
    if /I "!EXT!"=="mov"  set "VIDEO=!FILE!"
    if /I "!EXT!"=="avc"  set "VIDEO=!FILE!"
    if /I "!EXT!"=="hevc" set "VIDEO=!FILE!"
    if /I "!EXT!"=="h264" set "VIDEO=!FILE!"

    :: Detect audio files
    if /I "!EXT!"=="aac"  set "AUDIO=!FILE!"
    if /I "!EXT!"=="eac3" set "AUDIO=!FILE!"
    if /I "!EXT!"=="flac" set "AUDIO=!FILE!"
    if /I "!EXT!"=="m4a"  set "AUDIO=!FILE!"
    if /I "!EXT!"=="ac3"  set "AUDIO=!FILE!"

    :: Detect subtitle files
    if /I "!EXT!"=="srt"  set "SUB=!FILE!"
    if /I "!EXT!"=="ass"  set "SUB=!FILE!"
    if /I "!EXT!"=="vtt"  set "SUB=!FILE!"

    :: Detect chapters
    if /I "!EXT!"=="xml"  set "CHAPTERS=!FILE!"

    :: Detect ZIP (for attachments)
    if /I "!EXT!"=="zip" (
        :: Create temporary folder
        set "TMP=!TEMP!\mux_temp_%%~nF"
        mkdir "!TMP!" >nul 2>&1
        powershell -Command "Expand-Archive -Force -LiteralPath '!FILE!' -DestinationPath '!TMP!'"
        :: Store temp folder for later cleanup
        set "TMPFOLDERS=!TMPFOLDERS! !TMP!"
    )
)

:: ===============================
:: If VIDEO is MKV and no AUDIO provided, extract audio and video without audio
:: ===============================
if "!VIDEO!" neq "" if /I "!AUDIO!"=="" (
    for %%V in ("!VIDEO!") do set "VIDNAME=%%~nV"
    set "AUDIO=!TEMP!\!VIDNAME!_audio.mka"
    set "VIDEO_NOAUDIO=!TEMP!\!VIDNAME!_video.mkv"

    echo Extracting audio from !VIDEO!...
    mkvextract tracks "!VIDEO!" 1:"!AUDIO!"
    if errorlevel 1 (
        echo ERROR: Failed to extract audio.
        pause
        exit /b
    )

    echo Remuxing video without audio...
    mkvmerge -o "!VIDEO_NOAUDIO!" --no-audio "!VIDEO!"
    if errorlevel 1 (
        echo ERROR: Failed to remove audio from video.
        pause
        exit /b
    )

    set "VIDEO=!VIDEO_NOAUDIO!"
)

:: ===============================
:: Check required files
:: ===============================
set "ERROR_FLAG=0"
if "!VIDEO!"=="" (
    echo ERROR: Video file not provided!
    set "ERROR_FLAG=1"
)
if "!AUDIO!"=="" (
    echo ERROR: Audio file not provided!
    set "ERROR_FLAG=1"
)
if "!SUB!"=="" (
    echo ERROR: Subtitle file not provided!
    set "ERROR_FLAG=1"
)
if "!ERROR_FLAG!"=="1" (
    echo.
    echo Please fix the missing files and try again.
    pause
    exit /b
)

:: ===============================
:: Output filename based on video
:: ===============================
for %%A in ("!VIDEO!") do set "FILENAME=%%~nA_output.mkv"

:: ===============================
:: Build mkvmerge command
:: ===============================
set "CMD=mkvmerge -o "!FILENAME!"" 
set "CMD=!CMD! "!VIDEO!"" 
set "CMD=!CMD! --language 0:ja "!AUDIO!"" 
set "CMD=!CMD! --language 0:pt --default-track 0:yes "!SUB!"" 
if not "!CHAPTERS!"=="" set "CMD=!CMD! --chapters "!CHAPTERS!"" 

:: ===============================
:: Add attachments from temporary folders
:: ===============================
for %%D in (!TMPFOLDERS!) do (
    for %%F in ("%%D\*") do (
        set "CMD=!CMD! --attachment-mime-type application/octet-stream --attach-file "%%F""
    )
)

:: ===============================
:: Display command for confirmation
:: ===============================
echo.
echo ===============================
echo Command to be executed:
echo !CMD!
echo ===============================
echo.

:: ===============================
:: Execute and check for errors
:: ===============================
!CMD!
if errorlevel 1 echo ERROR: mkvmerge encountered a problem.

:: ===============================
:: Cleanup temporary folders and files
:: ===============================
for %%D in (!TMPFOLDERS!) do (
    rmdir /s /q "%%D"
)
if defined AUDIO if exist "!TEMP!\!VIDNAME!_audio.mka" del "!TEMP!\!VIDNAME!_audio.mka"
if defined VIDEO_NOAUDIO if exist "!VIDEO_NOAUDIO!" del "!VIDEO_NOAUDIO!"

:: ===============================
:: Done
:: ===============================
echo.
echo Done! Output file created: !FILENAME!
pause
