#!/bin/bash
set -x
##检查getopt版本, 返回码是4的才是gnu-getopt，否则是mac自带的getopt命令
#export PATH="/usr/local/opt/gnu-getopt/bin:$PATH"
#getopt --test
#if [[ $? -ne 4 ]]; then
#    echo "Please install gnu-getopt command"
#    echo "Using HomeBrew: http://macappstore.org/gnu-getopt/"
#    echo "brew install gnu-getopt"
#    echo "Using MacPorts: sudo port install getopt"
#    echo "替换路径"
#    exit 1
#fi

export basepath=$(
    cd "$(dirname "$0")"
    pwd
)
echo "[BS] basepath: "$basepath

export rootpath=$(
    cd "../$(dirname "$0")"
    pwd
)
echo "[BS] rootpath: "$rootpath

MY_SAVEIFS=$IFS
#IFS=$(echo -en "\n\b")
IFS=$'\n'

CocosBuild() {
    echo "[BS] CocosBuild @ "$(date)

    #先删除build目录
    #判断$basepath/build是否存在,存在删除
    if [ -d "$basepath/build/jsb-default" ]; then
        rm -rf $basepath/build/jsb-default
    fi

    CocosBin=/Applications/Cocos/Creator/2.4.15/CocosCreator.app/Contents/MacOS/CocosCreator

    # 如果第一个参数是release，则build release版本
    echo "[第一个参数是 = ] $1"
    if [ "$1" == "release" ]; then
        echo "[BS] build release version"
        $CocosBin --path $basepath --build "platform=android;debug=false;encryptJs=true;optimizeHotUpdate=true;"
    else
        echo "[BS] build debug version"
        $CocosBin --path $basepath --build "platform=android;debug=true;encryptJs=false;"
    fi

    # 如果build成功，则复制android文件
    if [ $? -eq 0 ]; then
        echo "[BS] build success"
        CopyAndroidFiles
    else
        echo "[BS] build failed"
    fi
}

CopyAndroidFiles() {
    echo "[BS] CopyAndroidFiles"
    targetAndroidProjPath=$basepath/wordsearchpuzzlemasterandroid/app/src/main/assets
    sourceAndroidProjPath=$basepath/build/jsb-default
    #  #判断$basepath/build是否存在,存在删除
    if [ -d "$targetAndroidProjPath" ]; then
        rm -rf $targetAndroidProjPath
    fi

    # 创建目标目录
    mkdir -p $targetAndroidProjPath

    cp -rv $sourceAndroidProjPath/assets $targetAndroidProjPath/
    cp -rv $sourceAndroidProjPath/src $targetAndroidProjPath/
    cp -rv $sourceAndroidProjPath/jsb-adapter $targetAndroidProjPath/
    cp -rv $sourceAndroidProjPath/main.js $targetAndroidProjPath/
    cp -rv $sourceAndroidProjPath/project.json $targetAndroidProjPath/
}

CocosBuild "$1"

et=$(date)
echo -e "[BS] "$et
echo "----------------------------Build Success-------------------------"
