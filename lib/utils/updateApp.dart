import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:connectivity/connectivity.dart';
import 'package:path_provider/path_provider.dart';
import 'package:package_info/package_info.dart';
//import 'package:simple_permissions/simple_permissions.dart';
import 'package:permission_handler/permission_handler.dart';
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
//      dio.options.receiveTimeout = 5000;
//      dio.options.contentType=ContentType.binary.
    }

    return dio;
  }

  static clear() {
    dio = null;
  }

  // 获取安装地址
  Future<String> get apkLocalPath async {
    final directory = await getExternalStorageDirectory();
    return directory.path;
  }

  static TargetPlatform get defaultTargetPlatform {
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
  Future<bool> checkPermission() async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      PermissionStatus permission = await PermissionHandler()
          .checkPermissionStatus(PermissionGroup.storage);
      if (permission != PermissionStatus.granted) {
        Map<PermissionGroup, PermissionStatus> permissions =
        await PermissionHandler()
            .requestPermissions([PermissionGroup.storage]);
        if (permissions[PermissionGroup.storage] == PermissionStatus.granted) {
          return true;
        }
      } else {
        return true;
      }
    } else {
      return true;
    }
    return false;
  }

  /*
//  simple_permissions: ^0.1.9
  //打开权限
  Future<PermissionStatus> requestPermission() async {
    print('requestPermission');
    return SimplePermissions.requestPermission(Permission.WriteExternalStorage);
  }

  //是否有权限
  Future<bool> checkPermission() async {
    print('checkPermission');
    *//* await SimplePermissions.requestPermission(Permission.ReadExternalStorage);
    await SimplePermissions.requestPermission(Permission.WriteExternalStorage);

    bool isReadPermissionGranted = await SimplePermissions.checkPermission(Permission.ReadExternalStorage);*//*
    bool res = await SimplePermissions.checkPermission(
        Permission.WriteExternalStorage);
    print(res);
    return res;
  }
*/
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
      Dio dio = createInstance();
      String url = GlobalConfig.base + 'Public/apkUpdate';
      if (defaultTargetPlatform == TargetPlatform.android) {
        url = GlobalConfig.base + 'Public/apkUpdate';
      } else if (defaultTargetPlatform == Platform.isIOS) {
        url = GlobalConfig.base + 'Public/iosUpdate';
      } else {
        return false;
      }

      await dio.get(url).then((Response response) async {
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
//          await SimplePermissions.requestPermission(  Permission.WriteExternalStorage);

//          if (await SimplePermissions.checkPermission(Permission.WriteExternalStorage)) {
        if(await checkPermission()){
            if (newVersion.compareTo(packageInfo.version) > 0) {
              isupdate = true;
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

  Future checkdownloadApp(context) async {
    print("<net---> download :");
    String errorMsg = "";
    int statusCode;
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
  /*        await SimplePermissions.requestPermission(
              Permission.WriteExternalStorage);

          if (await SimplePermissions.checkPermission(
              Permission.WriteExternalStorage)) {*/
          if(await checkPermission()){
            if (newVersion.compareTo(packageInfo.version) > 0) {
              DialogUtils().showMyDialog(context, '有更新版本，是否马上更新?').then((rv) {
                return rv ? downloadApp(context) : false;
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

  Future<bool> downloadApp(context) async {
    Dio dio = createInstance();
    final path = await apkLocalPath;
    Response downresponse;
    print('准备下载……到：'+path);

    String url,savePath;
    var nowTime = DateTime.now();
    String fileround=nowTime.year.toString()+nowTime.day.toString()+nowTime.hour.toString()+nowTime.minute.toString()+nowTime.microsecond.toString();
    if (defaultTargetPlatform == TargetPlatform.android) {
      url= "https://down.hukabao.com/andriod/app-release-flutter.apk";
      savePath="${path}/hukabao${fileround}.apk";
    } else if (defaultTargetPlatform == Platform.isIOS) {
      print('ios down!');
      url=  "itms-services://?action=download-manifest&url=https:/down.hukabao.com/ios/hkb.plist'";
      savePath="$path/hukabao${fileround}.ipa";
    }

    downresponse =
        await dio.download(url, savePath, onReceiveProgress: (received, total) {
      _downloading(context, received, total);
    });
    /*
//      分块续传
    await downloadWithChunks(url, savePath, onReceiveProgress: (received, total) {
      if (total != -1) {
        print("${(received / total * 100).floor()}%");
         DialogUtils.showProgressIndicator(context, received / total);
      }
    });*/

    print('下载结束完成了');
    await installApk(savePath);
    return true;
  }

  void _downloading(context, int received, int total) {
    if (total != -1) {
      print("正在下载……");
      print((received / total * 100).toStringAsFixed(0) + "%");
    }
  }

  // 安装
  Future<Null> installApk(String file) async {
    const platform = const MethodChannel('com.hukabao.flutter.xiebaoxin');
//    final path = await _apkLocalPath;
    await apkLocalPath.then((path) async {
      try {
        print('正在准备安装……');


        if (defaultTargetPlatform == TargetPlatform.android) {
           platform.invokeMethod('install', {'path':file});
        } else if (defaultTargetPlatform == Platform.isIOS) {
           platform.invokeMethod('install', {'path': file});
        }
        print('安装完了？？？……');

        SystemChannels.platform.invokeMethod('SystemNavigator.pop'); //关闭App
      } on PlatformException catch (_) {
        print('安装出问题了');
      }
    });
  }

//以下分快续传
  /// Downloading by spiting as file in chunks
  Future downloadWithChunks(
    url,
    savePath, {
    ProgressCallback onReceiveProgress,
  }) async {
    const firstChunkSize = 102;
    const maxChunk = 3;

    int total = 0;
    var dio = Dio();
    var progress = <int>[];

    createCallback(no) {
      return (int received, _) {
        progress[no] = received;
        if (onReceiveProgress != null && total != 0) {
          onReceiveProgress(progress.reduce((a, b) => a + b), total);
        }
      };
    }

    Future<Response> downloadChunk(url, start, end, no) async {
      progress.add(0);
      --end;
      return dio.download(
        url,
        savePath + "temp$no",
        onReceiveProgress: createCallback(no),
        options: Options(
          headers: {"range": "bytes=$start-$end"},
        ),
      );
    }

    Future mergeTempFiles(chunk) async {
      File f = File(savePath + "temp0");
      IOSink ioSink = f.openWrite(mode: FileMode.writeOnlyAppend);
      for (int i = 1; i < chunk; ++i) {
        File _f = File(savePath + "temp$i");
        await ioSink.addStream(_f.openRead());
        await _f.delete();
      }
      await ioSink.close();
      await f.rename(savePath);
    }

    Response response = await downloadChunk(url, 0, firstChunkSize, 0);
    if (response.statusCode == 206) {
      total = int.parse(response.headers
          .value(HttpHeaders.contentRangeHeader)
          .split("/")
          .last);
      int reserved = total -
          int.parse(response.headers.value(HttpHeaders.contentLengthHeader));
      int chunk = (reserved / firstChunkSize).ceil() + 1;
      if (chunk > 1) {
        int chunkSize = firstChunkSize;
        if (chunk > maxChunk + 1) {
          chunk = maxChunk + 1;
          chunkSize = (reserved / maxChunk).ceil();
        }
        var futures = <Future>[];
        for (int i = 0; i < maxChunk; ++i) {
          int start = firstChunkSize + i * chunkSize;
          futures.add(downloadChunk(url, start, start + chunkSize, i + 1));
        }
        await Future.wait(futures);
      }
      await mergeTempFiles(chunk);
    }
  }
}
