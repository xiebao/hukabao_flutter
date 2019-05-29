import 'dart:io';
import 'dart:async';
import 'dart:core';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:connectivity/connectivity.dart';
import 'package:package_info/package_info.dart';
import 'package:ota_update/ota_update.dart';
import '../globleConfig.dart';
import '../utils/updateApp.dart';
import '../utils/DialogUtils.dart';


class upgGradePage extends StatefulWidget {
  @override
  upgGradePageState createState() => new upgGradePageState();
}

class upgGradePageState extends State<upgGradePage> {
  String _loading = '0';
  String _packageInfovs, _packageInfobn;
  String _newVersioncontent;
  var _ostypename;

  String _latestAndroid =  "https://down.hukabao.com/andriod/app-release-flutter.apk";
  String _latestIOS = "https://down.hukabao.com/ios/hkb.ipa";
  Future<bool> checkInfo() async {
    print("<net---> download :");
    bool retslt = false;
    setState(() {
      _ostypename = UpdateApp.defaultTargetPlatform;
    });

    final packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      _packageInfovs = packageInfo.version; //1.0.0
      _packageInfobn = packageInfo.buildNumber; //1
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
      Dio dio = UpdateApp.createInstance();
      String url = GlobalConfig.base + 'Public/apkUpdate';
      if (_ostypename == TargetPlatform.android) {
        url = GlobalConfig.base + 'Public/apkUpdate';
      } else if (_ostypename == Platform.isIOS) {
        url = GlobalConfig.base + 'Public/iosUpdate';
      } else {
        DialogUtils().showMyDialog(context, "不支持此操作系统升级");
        return false;
      }

      await dio.get(url).then((Response response) async {
        print(response);
        statusCode = response.statusCode;
        if (statusCode < 0) {
          errorMsg = "网络请求错误,状态码:" + statusCode.toString();
          DialogUtils().showMyDialog(context, errorMsg);
        }
        if (response.data["update"] != null) {
          String newVersion = response.data["update"]['verCode'].toString();
          if (newVersion.compareTo(packageInfo.buildNumber) > 0) {
            print(newVersion + "|compareTo|" + packageInfo.buildNumber);

            setState(() {
              _newVersioncontent =
              "${response.data["update"]['ver']}(${newVersion}):${response.data["update"]['title']}:${response.data["update"]['content']} ";
            });

            if (_ostypename == TargetPlatform.android) {
              _latestAndroid =  response.data["update"]["url"];
            } else if (_ostypename == Platform.isIOS) {
              _latestIOS =response.data["update"]["url"];
            }

            retslt = true;
          }

        }
      });
    } catch (exception) {
      DialogUtils().showMyDialog(context, exception.toString());
    }
    return retslt;
  }

  Future _downApp() async {
    bool ischecked = await checkInfo();
    print("检查是否可以升级:$ischecked ");
    print(ischecked == true ? "yes" : "no");

    if (ischecked == false) return false;
    try {

      //"itms-services://?action=download-manifest&url=https:/down.hukabao.com/ios/hkb.plist";
/*
       *//*Flutter plugin implementing OTA update.
       On Android it downloads the file (with progress reporting) and triggers app installation intent.
       On iO*//*S it opens safari with specified ipa url. (not yet functioning)
    */
      if (Platform.isAndroid) {
        OtaUpdate().execute(_latestAndroid).listen((OtaEvent event) {
          print('EVENT: ${event.status} : ${event.value}');
          if(event.status ==OtaStatus.DOWNLOADING) {
            setState(() {
              _loading =event.value ;
            });
          }
        });
      } else if (Platform.isIOS) {
        OtaUpdate().execute(_latestIOS).listen((OtaEvent event) {
          print('EVENT: ${event.status} : ${event.value}');
          if(event.status ==OtaStatus.DOWNLOADING) {
            setState(() {
              _loading =event.value ;
            });
          }
        });
      }
    } catch (e) {
      print('OTA update. Details: $e');
      DialogUtils().showMyDialog(context, e);
    }

  }

  void initdown() async {
    await _downApp();
  }

  @override
  void initState() {
    super.initState();
    initdown();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        child: Scaffold(
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
                     child: Text(_loading == '0' ? "正在下载……，" : "已下载：$_loading%",style: TextStyle(color: Colors.red, fontSize: 14.0),)),
     /*           LinearProgressIndicator(
                    backgroundColor: Colors.blue,
                    value: _loading,
                    semanticsLabel: '正在下载新版本……',
                    valueColor: new AlwaysStoppedAnimation<Color>(Colors.red),
                  ),*/
                ],
              ),
            ),
          )),
        ),
        onWillPop: null);
  }

  @override
  void dispose() {
    super.dispose();
  }
}
