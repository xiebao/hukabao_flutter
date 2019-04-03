import 'dart:async';
import 'package:flutter/material.dart';
import 'routers/application.dart';
import 'package:shared_preferences/shared_preferences.dart';
import './model/globle_model.dart';
import './utils/HttpUtils.dart';
import './utils/DialogUtils.dart';
import './utils/updateApp.dart';

class SplashPage extends StatefulWidget {
  @override
  SplashState createState() => new SplashState();
}

class SplashState extends State<SplashPage> {
  Timer timer;
  bool _isupdate = false;

  void _checkUpdateApp() async {
    if (await UpdateApp().checkDownloadApp) {
      await DialogUtils().showMyDialog(context, '有更新版本，是否马上更新?').then((rv) {
        _isupdate = rv ? true : false;
      }).whenComplete(() {
        if (!_isupdate) {
          timer = Timer(const Duration(milliseconds: 1500), () async {
            SharedPreferences prefs = await SharedPreferences.getInstance();
            var token = prefs.getString('token') ?? '';
            print('========get init token==$token');
            if (token == '')
              Application.run(context, "/login");
            else {
              final model = globleModel().of(context);
              print(
                  "--------welpage----------${model.token}--------------------------");
              await HttpUtils.apipost(context, 'User/userInfo', {},
                  (response) async {
                print('=================userInfo======================');
                print(response);
                if (response["error_code"].toString() == '1') {
                  await model
                      .setlogin(token, response["userinfo"])
                      .whenComplete(() {
                    Application.run(context, "/home");
                  });
                } else
                  Application.run(context, "/login");
              }).whenComplete(() {
                print('whenComplete');
              });
            }
          });
        } else {
          UpdateApp().webdownload(context);
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
    timer.cancel();
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
