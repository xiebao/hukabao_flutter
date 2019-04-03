import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:core';
import '../components/ToastDialog.dart';
import '../components/LoadingDialog.dart';
import '../routers/application.dart';
import '../model/globle_model.dart';
import '../globleConfig.dart';

class DialogUtils {
  /// 显示文字对话框
  static showToastDialog(context, {text, duration}) {
    showDialog<Null>(
        context: context, // BuildContext对象
        barrierDismissible: false,
        builder: (BuildContext context) {
          return ToastDialog(
            // 调用对话框
            text: text ?? '操作成功',
          );
        });
    // 定时器关闭对话框
    new Timer(new Duration(milliseconds: duration ?? 1500), () {
      closeLoadingDialog(context);
    });
  }

  // 显示加载对话框
  static showLoadingDialog(context, {text}) {
    showDialog<Null>(
        context: context, // BuildContext对象
        barrierDismissible: false,
        builder: (BuildContext context) {
          return LoadingDialog(
            // 调用对话框
            text: text ?? '加载中...',
          );
        });
  }

  // 关闭加载对话框
  static closeLoadingDialog(context) {
    Navigator.pop(context);
  }

  static close2Logout(context) async {
    showDialog<Null>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
            title: new Text(
              '账户过期',
              style: new TextStyle(
                color: Colors.black54,
                fontSize: 18.0,
              ),
            ),
            content: new Text('请重新登录！'),
            actions: <Widget>[
              new FlatButton(
                  onPressed: () async {
                    final model = globleModel().of(context);
                    await model.setlogout().then((_) {
                      print('正在退出……');
                    }).whenComplete(() {
                      print(" logout, 重新登录");
                      Navigator.of(context).pop();
                      /* Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(
                    builder: (BuildContext context) => LoginPage()), ( //跳转到主页
                    Route route) => route == null);*/
                      Application.run(context, "/login");
                    });
                  },
                  child: new Text('确定')),
            ],
          ),
    );
  }

  Future<bool> showMyDialog(context, String text) {
    return showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => new AlertDialog(
                    title: new Text("温馨提示"),
                    content: new Text(text),
                    actions: <Widget>[
                      new FlatButton(
                        child: new Text("取消"),
                        onPressed: () {
                          Navigator.of(context).pop(false);
                        },
                      ),
                      new FlatButton(
                        child: new Text("确定"),
                        onPressed: () {
                          Navigator.of(context).pop(true);
                        },
                      )
                    ])) ??
        false;
  }

  // 显示加载对话框
  static showProgressIndicator(context, vl) {
    showDialog<Null>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
            title: Text("${GlobalConfig.appName}温馨提示"),
            content: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                children: <Widget>[
                  Align(
                      alignment: Alignment.centerLeft,
                      child: Text(vl > 0.8
                          ? "App准备退出，稍后请重启App！安装……，"
                          : "已下载：${(vl * 100).toStringAsFixed(0)}%")),
                  LinearProgressIndicator(
                    backgroundColor: Colors.blue,
                    value: vl,
                    semanticsLabel: '正在下载新版本……',
                    valueColor: new AlwaysStoppedAnimation<Color>(Colors.red),
                  ),
                ],
              ),
            ),
          ),
    );
  }
}
