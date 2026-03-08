@echo off
:: 支持中文文件名及版权符号 ©
chcp 65001 >nul
setlocal enabledelayedexpansion

:: --- 1. 配置信息 ---
set "ET_PATH=C:\ExifTool\exiftool.exe"
set "CP=Anjieda.com All Rights Reserved Since 1992."
set "URL=www.Anjieda.com"
set "AU=Hangzhou Anjieda Machinery Tools Factory"

:: --- 2. 环境检查 ---
if not exist "!ET_PATH!" exit /b

:: --- 3. 参数输入 ---
set /p "FMT=Format (jpg/webp/png) [Default: jpg]: "
if "%FMT%"=="" set "FMT=jpg"
set /p "WDS=Widths (e.g. 800 1080) [Default: 1080]: "
if "%WDS%"=="" set "WDS=1080"

echo.
echo Starting...
echo ---------------------------------------------------

:: --- 4. 核心逻辑：处理所有拖入的对象 ---
if "%~1"=="" (
    call :ScanDir "%cd%"
) else (
    :LoopArgs
    if "%~1"=="" goto :EndLoop
    set "TARGET=%~1"
    if exist "!TARGET!\" (
        call :ScanDir "!TARGET!"
    ) else (
        call :ProcessFile "!TARGET!"
    )
    shift
    goto :LoopArgs
)

:EndLoop
echo ---------------------------------------------------
echo SUCCESS: All tasks completed.
pause
exit /b

:: --- 子程序：扫描文件夹 ---
:ScanDir
for /f "delims=" %%F in ('dir /b /s /a-d "%~1\*.jpg" "%~1\*.jpeg" "%~1\*.png" "%~1\*.webp" "%~1\*.bmp" 2^>nul') do (
    call :ProcessFile "%%F"
)
goto :eof

:: --- 子程序：处理单张图片 ---
:ProcessFile
set "FULL_PATH=%~1"
set "DIR_ONLY=%~dp1"
set "FILE_NAME=%~nx1"

:: 【防套娃】检查路径中是否已包含输出文件夹标识
for %%w in (%WDS%) do (
    set "CHECK=\%%w_!FMT!\"
    echo "!FULL_PATH!" | findstr /i /c:"!CHECK!" /c:"Output_" >nul && goto :eof
)

:: 仅显示文件名，不显示路径
echo Processing: "!FILE_NAME!"

for %%w in (%WDS%) do (
    set "OUT_DIR=!DIR_ONLY!%%w_!FMT!"
    if not exist "!OUT_DIR!" mkdir "!OUT_DIR!" >nul 2>&1
    set "OUT_FILE=!OUT_DIR!\%~n1.!FMT!"

    :: A. 图像压缩优化
    if /I "!FMT!"=="jpg" (
        magick "%~1" -resize %%w -strip -interlace Plane -sampling-factor 4:2:0 -quality 85 "!OUT_FILE!" >nul 2>&1
    ) else (
        magick "%~1" -resize %%w -strip -quality 85 "!OUT_FILE!" >nul 2>&1
    )

    :: B. 元数据注入
    if exist "!OUT_FILE!" (
        "!ET_PATH!" -overwrite_original -Copyright="!CP!" -Artist="!AU!" -WebStatement="!URL!" -UsageTerms="!CP!" "!OUT_FILE!" >nul 2>&1
    )
)
goto :eof