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

class upgGradePage extends StatefulWidget {
  @override
  upgGradePageState createState() => new upgGradePageState();
}

class upgGradePageState extends State<upgGradePage> {

  double _loading = 0.0;
  String _packageInfovs,_packageInfobn;
  String _newVersioncontent;

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

  Future<bool> checkInfo() async {
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

    // 获取此时版本
    final packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      _packageInfovs=packageInfo.version;
      _packageInfobn=packageInfo.buildNumber;
    });
    /*     print(packageInfo.version); //1.0.0
          print(packageInfo.packageName);
          print(packageInfo.buildNumber); //1
          print(packageInfo.appName);
          print(defaultTargetPlatform);*/

    try {
//      Dio dio = new Dio();
      Dio dio = createInstance();
      String url= GlobalConfig.base + 'Public/apkUpdate';
      if (defaultTargetPlatform == TargetPlatform.android) {
         url= GlobalConfig.base + 'Public/apkUpdate';
      }
      else if (defaultTargetPlatform == Platform.isIOS) {
         url= GlobalConfig.base + 'Public/iosUpdate';
      }
      else
        {
          _handError("不支持此操作系统升级");
          return false;
        }

      await dio
          .get(url)
          .then((Response response) async {
        print(response);
        statusCode = response.statusCode;
        if (statusCode < 0) {
          errorMsg = "网络请求错误,状态码:" + statusCode.toString();
          _handError(errorMsg);
        }
        if (response.data["update"] != null) {
          final newVersion = response.data["update"]['verCode'];

          setState(() {
            _newVersioncontent="${response.data["update"]['ver']}(${newVersion}):${response.data["update"]['title']}:${response.data["update"]['content']} ";
          });

          await SimplePermissions.requestPermission(
              Permission.WriteExternalStorage);

          if (await SimplePermissions.checkPermission(
              Permission.WriteExternalStorage)) {
            if (newVersion.compareTo(packageInfo.version) > 0) {
                return true;
            }
          } else {
            print('权限不容许');
            return false;
          }
        }
        return false;

      });
    } catch (exception) {
      _handError(exception.toString());
      return false;
    }
  }

  Future webdownload() async {
   bool ischecked= await checkInfo();
   print("检查是否可以升级:");
   print(ischecked?"yes":"no");

   if(ischecked==false)  return false;

    Dio dio = createInstance();
    final path = await _apkLocalPath;
    Response downresponse;
    print('准备下载。');
    String url,savePath;
    if (defaultTargetPlatform == TargetPlatform.android) {
      url= "https://down.hukabao.com/andriod/app-release-flutter.apk";
      savePath="$path/hukabao.apk";
    } else if (defaultTargetPlatform == Platform.isIOS) {
      print('ios down!');
      url=  "itms-services://?action=download-manifest&url=https:/down.hukabao.com/ios/hkb.plist'";
      savePath="$path/hukabao.ipa";
    }

    downresponse = await dio.download(url,savePath,onReceiveProgress: (received, total) {
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
    Navigator.of(context).pop();
    await _installApk();

  }

  void _downloading(context, int received, int total){
    if (total != -1) {
      print("正在下载……");
      print((received / total * 100).toStringAsFixed(0) + "%");
      setState(() {
        _loading=received / total;
      });

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
      IOSink ioSink= f.openWrite(mode: FileMode.writeOnlyAppend);
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
      total = int.parse(
          response.headers.value(HttpHeaders.contentRangeHeader).split("/").last);
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


  @override
  void initState() {
    super.initState();
    webdownload();
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
//        showDowningIndocator(label: _loading),
    ),
    ), onWillPop: null);
  }
}