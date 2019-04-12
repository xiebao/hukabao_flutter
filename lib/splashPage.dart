import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'routers/application.dart';
import 'package:shared_preferences/shared_preferences.dart';
import './model/globle_model.dart';
import './utils/HttpUtils.dart';
import './utils/DialogUtils.dart';
import './utils/updateApp.dart';
import './views/upgradeApp.dart';
import 'package:package_info/package_info.dart';

class SplashPage extends StatefulWidget {
  @override
  SplashState createState() => new SplashState();
}

class SplashState extends State<SplashPage> {
  Timer timer;
  bool _isupdate = false;
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  String _packageInfoversion,_packageInfobuildNumber;
  void getNowVersion() async {
    // 获取此时版本
   var packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      _packageInfoversion=packageInfo.version;
      _packageInfobuildNumber=packageInfo.buildNumber;
    });
  }

  void _checkUpdateApp() async {
    await getNowVersion();
    SharedPreferences prefs = await _prefs;
    String isupdate ='';//prefs.getString('update') ?? '';
    print("_checkUpdateApp---"+isupdate);
    if (isupdate == '') {
      if (await UpdateApp().checkDownloadApp) {
        _isupdate = await DialogUtils().showMyDialog(context, '有更新版本，是否马上更新?');
        print(_isupdate);
        if (!_isupdate) {
          prefs.setString("update", 'no');
        } else {
          prefs.remove('update');
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => upgGradePage()),
              (Route router) => false);
        }
      }
    }

    if (prefs.getString('update') == 'no') {
      timer = Timer(const Duration(milliseconds: 1500), () async {
        String token = prefs.getString('token') ?? '';
        print("--spalshpage--prefs--------$token---------------");
        if (token == '')
          Application.run(context, "/login");
        else {
          final model = globleModel().of(context);
          await model.setToken(token);
          await HttpUtils.apipost(context, 'User/userInfo', {},
              (response) async {
            print(response);
            if (response["error_code"].toString() == '1') {
              await model.setlogin(token, response["userinfo"]);
                Application.run(context, "/home");
            } else
              Application.run(context, "/login");
          });
        }
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _checkUpdateApp();
  }

  @override
  void dispose() {
    if(timer!=null) timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _splashWegit();
  }

  Widget _splashWegit() {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Material(
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.only(
              top: 120.0,
            ),
            child: new Column(
              children: <Widget>[
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Image.asset(
                      'images/logo.png',
                      width: 100,
                      height: 100,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Text(
                    "护卡宝欢迎您",
                    style: new TextStyle(
                        color: Colors.deepOrangeAccent,
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text("版本${_packageInfoversion}(${_packageInfobuildNumber})"),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
/*

import 'package:path_provider/path_provider.dart';
  Future<File> get _getLocalFile async {
    // get the path to the document directory.
    String dir = (await getTemporaryDirectory()).path;
//    String dir = (await getApplicationDocumentsDirectory()).path;
    print(dir);
    return new File('$dir/test.txt');
  }

  localPath() async {
    File fil = await _getLocalFile;

    //列出所有文件，不包括链接和子文件夹
    Stream<FileSystemEntity> entityList =
        fil.parent.list(recursive: false, followLinks: false);
    await for (FileSystemEntity entity in entityList) {
      //文件、目录和链接都继承自FileSystemEntity
      //FileSystemEntity.type静态函数返回值为FileSystemEntityType
      //FileSystemEntityType有三个常量：
      //Directory、FILE、LINK、NOT_FOUND
      //FileSystemEntity.isFile .isLink .isDerectory可用于判断类型
      print(entity.path);
    }

    print(fil);
    var dirbool = await fil.exists(); //返回真假
    print(dirbool);
  }*/
}
