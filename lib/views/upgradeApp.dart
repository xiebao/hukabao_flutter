import 'dart:io';
import 'dart:async';
import 'dart:core';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:connectivity/connectivity.dart';
import 'package:package_info/package_info.dart';
import '../globleConfig.dart';
import '../utils/updateApp.dart';
import '../utils/DialogUtils.dart';

import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:open_file/open_file.dart';


class upgGradePage extends StatefulWidget {
  @override
  upgGradePageState createState() => new upgGradePageState();
}


class upgGradePageState extends State<upgGradePage> {

  double _loading = 0.0;
  String _packageInfovs,_packageInfobn;
  String _newVersioncontent;
  var _ostypename;

  Future<bool> checkInfo() async {
    print("<net---> download :");
    bool retslt=false;
    // 获取此时版本

    setState(() {
      _ostypename=UpdateApp.defaultTargetPlatform;
    });

    final packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      _packageInfovs=packageInfo.version;//1.0.0
      _packageInfobn=packageInfo.buildNumber;//1
    });

    String errorMsg = "";
    int statusCode;
    var connectivityResult = await (new Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile) {
    } else if (connectivityResult == ConnectivityResult.wifi) {
    } else if (connectivityResult == ConnectivityResult.none) {
      errorMsg = "请检查网络";
      print("请检查网络");
     DialogUtils().showMyDialog(context, errorMsg);
    }

    try {
      Dio dio =UpdateApp.createInstance();
      String url= GlobalConfig.base + 'Public/apkUpdate';
      if (_ostypename == TargetPlatform.android) {
         url= GlobalConfig.base + 'Public/apkUpdate';
      }
      else if (_ostypename == Platform.isIOS) {
         url= GlobalConfig.base + 'Public/iosUpdate';
      }
      else
        {
          DialogUtils().showMyDialog(context, "不支持此操作系统升级");
          return false;
        }

      await dio
          .get(url)
          .then((Response response) async {
        print(response);
        statusCode = response.statusCode;
        if (statusCode < 0) {
          errorMsg = "网络请求错误,状态码:" + statusCode.toString();
          DialogUtils().showMyDialog(context, errorMsg);
        }
        if (response.data["update"] != null) {
          String newVersion = response.data["update"]['verCode'].toString();
          setState(() {
            _newVersioncontent="${response.data["update"]['ver']}(${newVersion}):${response.data["update"]['title']}:${response.data["update"]['content']} ";
          });


          if (await UpdateApp().checkPermission()) {

            if (newVersion.compareTo(packageInfo.buildNumber) > 0) {
                print(newVersion+"|compareTo|"+packageInfo.buildNumber);
                retslt=true;
            }
          } else {
            print('权限不容许');
          }
        }
      });
    } catch (exception) {
      DialogUtils().showMyDialog(context,exception.toString());
    }
    return retslt;
  }

  Future _downApp() async {
    bool ischecked= await checkInfo();
    print("检查是否可以升级:$ischecked ");
    print(ischecked==true?"yes":"no");

    if(ischecked==false)  return false;


    String _finalApkPath = await UpdateApp().apkLocalPath;
    String fileName = 'app-release.apk';
    String url;
     if (_ostypename == TargetPlatform.android) {
      url= "https://down.hukabao.com/andriod/app-release-flutter.apk";
      fileName="app-release-flutter.apk";
    } else if (_ostypename == Platform.isIOS) {
      print('ios down!');
      url=  "itms-services://?action=download-manifest&url=https:/down.hukabao.com/ios/hkb.plist'";
      fileName="hukaba-oflu.ipa";
    }

    final taskId = await FlutterDownloader.enqueue(
      url:url,
      savedDir: _finalApkPath,
      fileName: fileName,
      showNotification:
      true, // show download progress in status bar (for Android)
      openFileFromNotification:
      true, // click on notification to open downloaded file (for Android)
    );
    await FlutterDownloader.loadTasks();
    print(taskId);
    FlutterDownloader.registerCallback((id, status, progress) async{
      if(taskId == id ){
        setState(() {
          _loading=progress/100;
        });
//      Download task (15611644-4733-4e1e-904e-049bef296db4) is in status (DownloadTaskStatus(3)) and process (100) status DownloadTaskStatus(3) _finalApkPath=/storage/emulated/0
        print(
            'Download task ($id) is in status ($status) and process ($progress) status ${DownloadTaskStatus.complete} _finalApkPath=$_finalApkPath');
        if (status == DownloadTaskStatus.complete) {
        await  OpenFile.open(_finalApkPath+"/"+fileName);
        await  FlutterDownloader.open(taskId: id);
          //  Navigator.pop(context);
       SystemChannels.platform.invokeMethod('SystemNavigator.pop'); //关闭App

        }
      }

    });
  }

  @override
  void initState() {
    super.initState();
    _downApp();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(child: Scaffold(
    body: Center(
    child: AlertDialog(
      title: Text("${GlobalConfig.appName}温馨提示"),
      content: Container(
        padding: const EdgeInsets.all(10.0),
        alignment: Alignment.center,
        height: 300,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            Text("当前版本:$_packageInfovs($_packageInfobn)"),
            Text("新版本信息:$_newVersioncontent"),
            Align(
                alignment: Alignment.centerLeft,
                child: Text(_loading > 0.8
                    ? "App准备退出进行安装……，稍后请重启App！"
                    : "已下载：${(_loading * 100).toStringAsFixed(0)}%")),
            LinearProgressIndicator(
              backgroundColor: Colors.blue,
              value: _loading,
              semanticsLabel: '正在下载新版本……',
              valueColor: new AlwaysStoppedAnimation<Color>(Colors.red),
            ),
          ],
        ),
      ),
    )
    ),
    ), onWillPop: null);
  }
}