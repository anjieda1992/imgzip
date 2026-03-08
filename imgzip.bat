@echo off
:: 支持中文路径、文件名及版权符号 ©
chcp 65001 >nul
setlocal enabledelayedexpansion

echo ===================================================
echo   Anjieda.com IMGZIP ENGINE - VERSION 1.1
echo ===================================================

:: --- 1. 核心程序路径配置 ---
:: 这里直接指向你指定的 ExifTool 地址
set "ET_PATH=C:\ExifTool\exiftool.exe"

:: --- 2. 预设企业元数据 ---
set "CP=Anjieda.com All Rights Reserved Since 1992."
set "URL=www.anjieda.com"
set "AU=Hangzhou Anjieda Machinery Tools Factory"

:: --- 3. 环境检查 ---
if not exist "!ET_PATH!" (
    echo [ERROR] ExifTool not found at: !ET_PATH!
    echo Please check the path and try again.
    pause
    exit /b
)

:: --- 4. 用户交互输入 ---
set /p "FMT=Target Format (jpg/webp/png) [Default: jpg]: "
if "%FMT%"=="" set "FMT=jpg"
set /p "WDS=Target Widths (e.g., 800 1080) [Default: 1080]: "
if "%WDS%"=="" set "WDS=1080"

echo.
echo Processing images for Anjieda SEO Matrix...
echo ---------------------------------------------------

for %%f in (*.jpg *.jpeg *.png *.webp *.bmp) do (
    echo Processing: "%%f"
    
    for %%w in (%WDS%) do (
        set "T_DIR=%%w_!FMT!"
        if not exist "!T_DIR!" mkdir "!T_DIR!"
        set "O_PATH=!T_DIR!\%%~nf.!FMT!"

        :: A. ImageMagick 图像压缩处理
        if /I "!FMT!"=="jpg" (
            magick "%%f" -resize %%w -strip -interlace Plane -sampling-factor 4:2:0 -quality 85 "!O_PATH!" >nul 2>&1
        ) else (
            magick "%%f" -resize %%w -strip -quality 85 "!O_PATH!" >nul 2>&1
        )

        :: B. ExifTool 注入企业版权信息
        if exist "!O_PATH!" (
            "!ET_PATH!" -overwrite_original -Copyright="!CP!" -Artist="!AU!" -WebStatement="!URL!" -UsageTerms="!CP!" "!O_PATH!" >nul 2>&1
            echo    - [SUCCESS] Width: %%w ^| Format: !FMT! ^| DONE.
        ) else (
            echo    - [ERROR] Failed to process %%f
        )
    )
)

echo ---------------------------------------------------
echo ALL DONE.
pause