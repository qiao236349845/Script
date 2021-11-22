#!/bin/bash

# 指定打包存放目录
targetPath="app/build/bakApk"

apkPath=""

# 获取版本号方法
prop(){
    grep "${1}" version.properties | cut -d'=' -f2 | sed 's/\r//'
}

versionName=$(prop "version.name")
build=$(prop "build.code")

function findApk(){
    echo "查找此目录是否有aar以及pom"
    targetDir=$(ls $1)
    for fileName in $targetDir
    do
          if [[ -d $1"/"$fileName ]]; then
              # 判断是否是目录，是继续递归
              findApk $1"/"$fileName
          else
              if [[ ${fileName} =~ '.apk' ]]; then
                  apkPath=$1"/"$fileName
          fi
    done
}

findAARPom $targetPath

echo "====================find apk==============================="
echo $apkPath


# Get API Token from http://fir.im/apps
API_TOKEN="20f853316a2a7f5d3b1e7ad18af9e366"
# ios or android
TYPE="android"
# App 的 bundleId
BUNDLE_ID="com.zjport.liumayunli"


# Get upload_url
credential=$(curl -X "POST" "http://api.bq04.com/apps" \
-H "Content-Type: application/json" \
-d "{\"type\":\"${TYPE}\", \"bundle_id\":\"${BUNDLE_ID}\", \"api_token\":\"${API_TOKEN}\"}" \
2>/dev/null)
binary_response=$(echo ${credential} | grep -o "binary[^}]*")
KEY=$(echo ${binary_response} | awk -F '"' '{print $5}')
TOKEN=$(echo ${binary_response} | awk -F '"' '{print $9}')
UPLOAD_URL=$(echo ${binary_response} | awk -F '"' '{print $13}')

# Upload package
echo "========================upload==========================="
echo $build
echo $versionName

response=$(curl -F "key=${KEY}" \
-F "token=${TOKEN}" \
-F "file=@${apkPath}" \
-F "x:build=${build}" \
-F "x:name=骝马运力测试" \
-F "x:version=$versionName" \
${UPLOAD_URL}
)
echo $response;
