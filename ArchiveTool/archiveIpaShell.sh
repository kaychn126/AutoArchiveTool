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
configuration=`/usr/libexec/PlistBuddy -c "print configuration" ${config_file}`
scheme_name=`/usr/libexec/PlistBuddy -c "print scheme_name" ${config_file}`
#进入工程目录
cd ..

#log日志文件
log_path="ArchiveTool/ArchivePackage/archiveLog.log"

#检查日志文件是否存在
if [ ! -f "$log_path" ]; then
  touch "$log_path"
fi

#时间戳
buildTime=$(date +%Y%m%d%H%M)
echo "\r\r$(date +%Y年%m月%d日%H时%M分)：${ipa_name}开始打包" >> $log_path

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
xctool -workspace ${project_name}.xcworkspace -scheme ${scheme_name} -configuration ${configuration} clean

#打包
xctool -workspace ${project_name}.xcworkspace -scheme ${scheme_name} -configuration ${configuration} archive -archivePath ${buildPath}

if [ ! -f "$buildPath" ]; then
  echo "\r$(date +%Y年%m月%d日%H时%M分)：打包Archive失败" >> $log_path
else
  echo "\r$(date +%Y年%m月%d日%H时%M分)：打包Archive完成，开始导出ipa包" >> $log_path
  #导出ipa包
  xcrun xcodebuild -exportArchive -exportOptionsPlist ${exportPlistName} -archivePath ${buildPath} -exportPath ${ipaDirPath}
  CODE_SIGN_IDENTITY=${certificate_name}
  PROVISIONING_PROFILE=${provisioning_profile} >> $log_path

  #上传包到蒲公英
  ipaFullPath=$(cd "$(dirname "$0")";pwd)/${ipaDirPath}/${ipa_name}.ipa

  if [ ! -f "$ipaFullPath" ]; then
    echo "\r$(date +%Y年%m月%d日%H时%M分)：导出ipa包失败" >> $log_path
  else
    echo "\r$(date +%Y年%m月%d日%H时%M分)：ipa包上传蒲公英，蒲公英返回值为：" >> $log_path
    curl -F "file=@${ipaFullPath}" -F "uKey=${pgyer_ukey}" -F "_api_key=${pgyer_apikey}" http://www.pgyer.com/apiv1/app/upload >> $log_path
  fi
fi
