# Android 打包脚本使用说明

## 脚本功能
`android_build.sh` 是一个用于构建Android APK的自动化脚本，支持debug和release两种构建模式。

## 使用方法

### 基本用法
```bash
# 构建debug版本（默认）
./android_build.sh

# 构建debug版本（显式指定）
./android_build.sh debug

# 构建release版本
./android_build.sh release
```

## 功能特性

1. **自动构建**: 支持debug和release两种构建模式
2. **版本管理**: APK文件名自动包含项目名、打包类型、日期和时间
3. **输出管理**: 所有APK文件统一输出到 `out_apk/` 目录
4. **文件覆盖**: 如果存在同名APK文件，新文件会自动覆盖旧文件
5. **错误处理**: 完整的错误检查和提示
6. **构建清理**: 每次构建前自动清理之前的构建文件

## 输出文件命名规则

APK文件命名格式：`{项目名}_{打包类型}_{日期}_{时间}.apk`

示例：
- `wordalhoa_debug_2025_01_23_14_30.apk` (debug版本)
- `wordalhoa_release_2025_01_23_14_30.apk` (release版本)

## 目录结构

```
WordAlhoa/
├── android_build.sh          # Android打包脚本
├── out_apk/                  # APK输出目录
│   └── *.apk                # 生成的APK文件
└── wordalhoaandroid/         # Android项目目录
    ├── app/
    ├── build.gradle
    └── ...
```

## 构建流程

1. 检查Android项目目录是否存在
2. 创建输出目录 `out_apk/`
3. 清理之前的构建文件
4. 执行Gradle构建命令
5. 查找生成的APK文件
6. 复制APK到输出目录并重命名（添加时间戳）
7. 显示构建结果和APK信息

## 注意事项

- 确保Android项目目录 `wordalhoaandroid/` 存在
- 确保已安装Android SDK和Gradle
- 脚本会自动处理权限问题
- 每次构建都会清理之前的构建文件
- **同名APK文件会被自动覆盖**，无需手动删除旧文件

## 错误处理

脚本包含完整的错误检查：
- 检查Android项目目录是否存在
- 验证构建类型参数
- 检查构建是否成功
- 检查APK文件是否生成
- 提供详细的错误信息

## 示例输出

```
[Android Build] basepath: /Users/zhangqiang/Desktop/work/WordAlhoa
[Android Build] Build type: debug
[Android Build] Cleaning previous build...
[Android Build] Building debug APK...
[Android Build] Build successful!
[Android Build] APK copied to: /Users/zhangqiang/Desktop/work/WordAlhoa/out_apk/wordalhoa_debug_2025_01_23_14_30.apk
[Android Build] APK size: 25M
[Android Build] APK Info:
  - File: wordalhoa_debug_2025_01_23_14_30.apk
  - Build Type: debug
  - Date: 2025_01_23
  - Time: 14_30
  - Location: /Users/zhangqiang/Desktop/work/WordAlhoa/out_apk/wordalhoa_debug_2025_01_23_14_30.apk
[Android Build] Build completed at Mon Dec  1 14:30:22 CST 2024
----------------------------Android Build Success-------------------------
```
