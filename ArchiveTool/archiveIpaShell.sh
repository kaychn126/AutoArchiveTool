#!/bin/sh

#从plist文件中读取配置
config_file="./ArchiveConfig/config.plist"
project_name=`/usr/libexec/PlistBuddy -c "print project_name" ${config_file}`
ipa_name=`/usr/libexec/PlistBuddy -c "print app_name" ${config_file}`
provisioning_profile=`/usr/libexec/PlistBuddy -c "print provisioning_profile" ${config_file}`
certificate_name=`/usr/libexec/PlistBuddy -c "print certificate_name" ${config_file}`
export_plist=`/usr/libexec/PlistBuddy -c "print export_plist" ${config_file}`
pgyer_ukey=`/usr/libexec/PlistBuddy -c "print pgyer_ukey" ${config_file}`
pgyer_apikey=`/usr/libexec/PlistBuddy -c "print pgyer_apikey" ${config_file}`
buildConfiguration=`/usr/libexec/PlistBuddy -c "print configuration" ${config_file}`
#进入工程目录
cd ..

#用时间戳命名文件夹名字
buildTime=$(date +%Y%m%d%H%M)

if [ ! -d "ArchiveTool/ArchivePackage" ];
then
    mkdir ArchiveTool/ArchivePackage
fi

#文件夹不存在则创建，存在则删除文件夹中所有内容及文件夹并创建
if [ ! -d "ArchiveTool/ArchivePackage/Xcarchive" ];
then
    mkdir ArchiveTool/ArchivePackage/Xcarchive
else
    rm -drf ArchiveTool/ArchivePackage/Xcarchive
    mkdir ArchiveTool/ArchivePackage/Xcarchive
fi

#文件夹不存在则创建，存在则删除文件夹中所有内容及文件夹并创建
if [ ! -d "ArchiveTool/ArchivePackage/Ipa" ];
then
    mkdir ArchiveTool/ArchivePackage/Ipa
else
    rm -drf ArchiveTool/ArchivePackage/Ipa
    mkdir ArchiveTool/ArchivePackage/Ipa
fi

buildPath="ArchiveTool/ArchivePackage/Xcarchive/${ipa_name}_${buildTime}.xcarchive"
ipaDirPath="ArchiveTool/ArchivePackage/Ipa/${ipa_name}_${buildTime}"
exportPlistName="ArchiveTool/ArchiveConfig/${export_plist}"

#clean
xctool -workspace $project_name.xcworkspace -scheme $project_name -configuration ${buildConfiguration} clean

#打包
xctool -workspace $project_name.xcworkspace -scheme $project_name -configuration ${buildConfiguration} archive -archivePath ${buildPath}

#导出ipa包
xcrun xcodebuild -exportArchive -exportOptionsPlist ${exportPlistName} -archivePath ${buildPath} -exportPath ${ipaDirPath}
CODE_SIGN_IDENTITY=${certificate_name}
PROVISIONING_PROFILE=${provisioning_profile}

#上传包到蒲公英
ipaFullPath=$(cd "$(dirname "$0")";pwd)/${ipaDirPath}/${ipa_name}.ipa
echo "IPA包上传到蒲公英：${ipaFullPath}"

curl -F "file=@${ipaFullPath}" -F "uKey=$pgyer_ukey" -F "_api_key=$pgyer_apikey" http://www.pgyer.com/apiv1/app/upload
