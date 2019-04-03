import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:connectivity/connectivity.dart';
import 'package:path_provider/path_provider.dart';
import 'package:package_info/package_info.dart';
import 'package:simple_permissions/simple_permissions.dart';
import '../globleConfig.dart';
import '../utils/DialogUtils.dart';

class UpdateApp {
  static Dio dio;

  Options options;

  /// 创建 dio 实例对象 context
  static Dio createInstance() {
    if (dio == null) {
      dio = new Dio();
      dio.options.baseUrl = GlobalConfig.base;
      dio.options.connectTimeout = 10000;
      dio.options.receiveTimeout = 5000;
    }
    return dio;
  }

  static clear() {
    dio = null;
  }

  // 获取安装地址
  Future<String> get _apkLocalPath async {
    final directory = await getExternalStorageDirectory();
    return directory.path;
  }

  TargetPlatform get defaultTargetPlatform {
    TargetPlatform result;
    //这里根据平台来赋值，但是只有iOS、Android、Fuchsia，没有PC
    if (Platform.isIOS) {
      result = TargetPlatform.iOS;
    } else if (Platform.isAndroid) {
      result = TargetPlatform.android;
    } else if (Platform.isFuchsia) {
      result = TargetPlatform.fuchsia;
    }
    assert(() {
      if (Platform.environment.containsKey('FLUTTER_TEST'))
        result = TargetPlatform.android;
      return true;
    }());
    //这里判断debugDefaultTargetPlatformOverride有没有值，有值的话，就赋值给result
//    'package:flutter/foundation.dart';
    if (debugDefaultTargetPlatformOverride != null)
      result = debugDefaultTargetPlatformOverride;

    //如果到这一步，还没有取到 TargetPlatform 的值，就会抛异常
    if (result == null) {
      throw FlutterError('Unknown platform.\n'
          '${Platform.operatingSystem} was not recognized as a target platform. '
          'Consider updating the list of TargetPlatforms to include this platform.');
    }
    return result;
  }

  //打开权限
  Future<PermissionStatus> requestPermission() async {
    print('requestPermission');
    return SimplePermissions.requestPermission(Permission.WriteExternalStorage);
  }

  //是否有权限
  Future<bool> checkPermission() async {
    print('checkPermission');
    /* await SimplePermissions.requestPermission(Permission.ReadExternalStorage);
    await SimplePermissions.requestPermission(Permission.WriteExternalStorage);

    bool isReadPermissionGranted = await SimplePermissions.checkPermission(Permission.ReadExternalStorage);*/
    bool res = await SimplePermissions.checkPermission(
        Permission.WriteExternalStorage);
    print(res);
    return res;
  }

  //处理异常
  static void _handError(String errorMsg, {BuildContext context}) {
    print("<net> errorMsg :" + errorMsg);
//      DialogUtils.showToastDialog(context);
  }


  //具体的还是要看返回数据的基本结构
  Future<bool> get checkDownloadApp async {
    print("<net---> download :");
    String errorMsg = "";
    int statusCode;
    bool isupdate = false;
    var connectivityResult = await (new Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile) {
    } else if (connectivityResult == ConnectivityResult.wifi) {
    } else if (connectivityResult == ConnectivityResult.none) {
      errorMsg = "请检查网络";
      print("请检查网络");
      _handError(errorMsg);
    }

    try {
//      Dio dio = new Dio();
      Dio dio = createInstance();
      await dio
          .get(GlobalConfig.base + 'Public/apkUpdate')
          .then((Response response) async {
        print(response);
        statusCode = response.statusCode;
        if (statusCode < 0) {
          errorMsg = "网络请求错误,状态码:" + statusCode.toString();
          _handError(errorMsg);
        }
        if (response.data["update"] != null) {
          final newVersion = response.data["update"]['verCode'];

          // 获取此时版本
          final packageInfo = await PackageInfo.fromPlatform();
          /* print(packageInfo.version); //1.0.0
          print(packageInfo.packageName);
          print(packageInfo.buildNumber); //1
          print(packageInfo.appName);
          print(defaultTargetPlatform);*/
          await SimplePermissions.requestPermission(
              Permission.WriteExternalStorage);

          if (await SimplePermissions.checkPermission(
              Permission.WriteExternalStorage)) {
            if (newVersion.compareTo(packageInfo.version) > 0) {
              isupdate= true;
            }
          } else {
            print('权限不容许');
          }
        }
      });
    } catch (exception) {
      _handError(exception.toString());
    }
    return isupdate;
  }

 Future downloadApp(context) async {
    print("<net---> download :");
    String errorMsg = "";
    int statusCode;
    bool isupdate = false;
    var connectivityResult = await (new Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile) {
    } else if (connectivityResult == ConnectivityResult.wifi) {
    } else if (connectivityResult == ConnectivityResult.none) {
      errorMsg = "请检查网络";
      print("请检查网络");
      _handError(errorMsg);
    }

    try {
//      Dio dio = new Dio();
      Dio dio = createInstance();
      await dio
          .get(GlobalConfig.base + 'Public/apkUpdate')
          .then((Response response) async {
        print(response);
        statusCode = response.statusCode;
        if (statusCode < 0) {
          errorMsg = "网络请求错误,状态码:" + statusCode.toString();
          _handError(errorMsg);
        }
        if (response.data["update"] != null) {
          final newVersion = response.data["update"]['verCode'];

          // 获取此时版本
          final packageInfo = await PackageInfo.fromPlatform();
          /* print(packageInfo.version); //1.0.0
          print(packageInfo.packageName);
          print(packageInfo.buildNumber); //1
          print(packageInfo.appName);
          print(defaultTargetPlatform);*/
          await SimplePermissions.requestPermission(
              Permission.WriteExternalStorage);

          if (await SimplePermissions.checkPermission(
              Permission.WriteExternalStorage)) {
            if (newVersion.compareTo(packageInfo.version) > 0) {
              DialogUtils().showMyDialog(context, '有更新版本，是否马上更新?').then((rv) {
                isupdate = rv;
                return rv ? webdownload(context) : false;
              });
            }
          } else {
            print('权限不容许');
            return;
          }
        }
      });
    } catch (exception) {
      _handError(exception.toString());
    }
  }

  Future<bool> webdownload(context) async {
    Dio dio = createInstance();
    final path = await _apkLocalPath;
    Response downresponse;
    print('准备下载。');
    if (defaultTargetPlatform == TargetPlatform.android) {
      print('android down!');
      downresponse = await dio.download(
          "https://down.hukabao.com/andriod/hkb.apk", "$path/hukabao.apk",
          onProgress: (received, total) {
        _downloading(context, received, total);
      }).whenComplete(() async{
          print('下载结束完成了');
          Navigator.of(context).pop();
          await _installApk();
      });
    } else if (defaultTargetPlatform == Platform.isIOS) {
      print('ios down!');
      downresponse = await dio.download(
          "itms-services://?action=download-manifest&url=https:/down.hukabao.com/ios/hkb.plist'",
          "$path/hukabao.ipa", onProgress: (received, total) {
        _downloading(context, received, total);
      }).whenComplete(() async{
        Navigator.of(context).pop();
        print('下载结束完成了');
        await _installApk();
      });
    }
    print(downresponse);
    print(downresponse.statusCode);
    return downresponse.statusCode == 200 ? true : false;
  }

  void _downloading(context, int received, int total) {
    if (total != -1) {
      print("正在下载……");
      print((received / total * 100).toStringAsFixed(0) + "%");
      DialogUtils.showProgressIndicator(context, received / total);
    }
  }

  // 安装
  Future<Null> _installApk() async {
    const platform = const MethodChannel('com.hukabao.flutter.xiebaoxin');
//    final path = await _apkLocalPath;
    await _apkLocalPath.then((path) async {
      try {
        print('正在准备安装……');
        await SystemChannels.platform
            .invokeMethod('SystemNavigator.pop'); //关闭App
        if (defaultTargetPlatform == TargetPlatform.android) {
          // 可以安装了
          await platform
              .invokeMethod('install', {'path': path + '/hukabao.apk'});
        } else if (defaultTargetPlatform == Platform.isIOS) {
          await platform
              .invokeMethod('install', {'path': path + '/hukabao.ipa'});
        }
      } on PlatformException catch (_) {
        print('安装出问题了');
      }
    });
  }
}
