# AutoArchiveTool
使用xctool自动打包成ipa文件并上传蒲公英。用于Xcode工程的持续集成。

###使用方法
 * 安装xctool，具体见[这里](http://lengmolehongyan.github.io/blog/2016/01/14/facebook-xctool-de-shi-yong/)。
 * 下载ArchiveTool文件夹放到工程根目录，和youProject.xcworkspace文件同级。  
 * 修改ArchiveConfig文件夹下两个配置文件，config.plist和exportOptions.plist。  
 * 修改完之后运行`sh archiveIpaShell.sh`
 
###配置文件中各字段的意义
 
####config.plist  
 >
 > 1. certificate_name：证书的名字。例如：iPhone Developer: Shugang Li (G3BV9E076T)。  
 > 2. provisioning_profile：签名文件的uuid，可以用文本编辑器打开签名文件搜索UUID。例如：146ca015-1ikg-78hb-45gd-4f7588255cc7。  
 > 3. configuration：有Release,Debug,AdHoc等几个选项。  
 > 4. app_name：app的名字。  
 > 5. project_name：工程的名字，就是根目录里面的yourproject.xcodeproj去掉.xcodeproj。  
 > 6. pgyer_ukey：蒲公英的uKey。  
 > 7. pgyer_apikey：蒲公英的apiKey。  
 > 8. scheme_name：Scheme 名称
 
####exportOptions.plist文件中各字段的意义：
 
 > 1. method：可选值有app-store, package, ad-hoc, enterprise, development,和developer-id。
 > 2. teamId：开发者账号的teamId。
