#!/bin/bash
set -x

# Android打包脚本
# 用法: ./android_build.sh [release|debug]
# 无参数默认为debug

export basepath=$(
    cd "$(dirname "$0")"
    pwd
)
echo "[Android Build] basepath: $basepath"

# 设置Android项目路径
export android_project_path="$basepath/wordsearchpuzzlemasterandroid"
export output_path="$basepath/out_apk"

# 检查Android项目是否存在
if [ ! -d "$android_project_path" ]; then
    echo "[Android Build] Error: Android project not found at $android_project_path"
    exit 1
fi

# 创建输出目录
mkdir -p "$output_path"

# 获取构建类型参数，默认为debug
BUILD_TYPE=${1:-debug}
echo "[Android Build] Build type: $BUILD_TYPE"

# 验证构建类型
if [ "$BUILD_TYPE" != "debug" ] && [ "$BUILD_TYPE" != "release" ]; then
    echo "[Android Build] Error: Invalid build type. Use 'debug' or 'release'"
    exit 1
fi

# 进入Android项目目录
cd "$android_project_path"

# 清理之前的构建
echo "[Android Build] Cleaning previous build..."
./gradlew clean

# 执行构建
echo "[Android Build] Building $BUILD_TYPE APK..."
if [ "$BUILD_TYPE" == "release" ]; then
    ./gradlew assembleRelease
    BUILD_RESULT=$?
    APK_DIR="app/build/outputs/apk/release"
else
    ./gradlew assembleDebug
    BUILD_RESULT=$?
    APK_DIR="app/build/outputs/apk/debug"
fi

# 检查构建结果
if [ $BUILD_RESULT -eq 0 ]; then
    echo "[Android Build] Build successful!"
    
    # 查找生成的APK文件
    APK_FILE=$(find "$APK_DIR" -name "*.apk" | head -1)
    
    if [ -n "$APK_FILE" ] && [ -f "$APK_FILE" ]; then
        # 生成新的APK文件名：项目名_打包类型_日期_时间.apk
        PROJECT_NAME="wordalhoa"
        DATE=$(date +"%Y_%m_%d")
        TIME=$(date +"%H_%M")
        NEW_APK_NAME="${PROJECT_NAME}_${BUILD_TYPE}_${DATE}_${TIME}.apk"
        
        # 检查是否存在同名文件
        if [ -f "$output_path/$NEW_APK_NAME" ]; then
            echo "[Android Build] Warning: File $NEW_APK_NAME already exists, will be overwritten"
        fi
        
        # 复制APK到输出目录（覆盖同名文件）
        cp -f "$APK_FILE" "$output_path/$NEW_APK_NAME"
        
        echo "[Android Build] APK copied to: $output_path/$NEW_APK_NAME"
        echo "[Android Build] APK size: $(du -h "$output_path/$NEW_APK_NAME" | cut -f1)"
        
        # 显示APK信息
        echo "[Android Build] APK Info:"
        echo "  - File: $NEW_APK_NAME"
        echo "  - Build Type: $BUILD_TYPE"
        echo "  - Date: $DATE"
        echo "  - Location: $output_path/$NEW_APK_NAME"
        
    else
        echo "[Android Build] Error: APK file not found in $APK_DIR"
        exit 1
    fi
    
else
    echo "[Android Build] Build failed!"
    exit 1
fi

echo "[Android Build] Build completed at $(date)"
echo "----------------------------Android Build Success-------------------------"
