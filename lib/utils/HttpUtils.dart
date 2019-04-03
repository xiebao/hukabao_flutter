import 'dart:io';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity/connectivity.dart';
import '../globleConfig.dart';
import '../utils/DialogUtils.dart';
import '../routers/application.dart';
class HttpUtils {
  /// global dio object
  static Dio dio;

  /// default options
  static const String API_PREFIX = 'http://app.hukabao.com/index.php/Api/';
  static const int CONNECT_TIMEOUT = 10000;
  static const int RECEIVE_TIMEOUT = 5000;
  static const CONTENT_TYPE_JSON = "application/json";
  static const CONTENT_TYPE_FORM = "application/x-www-form-urlencoded";

  /// http request methods
  static const String GET = 'get';
  static const String POST = 'post';
  static const String PUT = 'put';
  static const String PATCH = 'patch';
  static const String DELETE = 'delete';

  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  Options options;

  /// 创建 dio 实例对象 context
  static Dio createInstance() {
    if (dio == null) {
      dio = new Dio();
      dio.options.baseUrl = GlobalConfig.base;
      dio.options.connectTimeout = CONNECT_TIMEOUT;
      dio.options.receiveTimeout = RECEIVE_TIMEOUT;
/*
      dio.interceptors
          .add(InterceptorsWrapper(onRequest: (RequestOptions options) async {
        // 在请求被发送之前做一些事情
        String token =await HttpUtils().theToken;
          options.headers = {
            'access-token': token,
//          'Authorization': 'Bearer ' + token,
          };

        return options; //continue
        // 如果你想完成请求并返回一些自定义数据，可以返回一个`Response`对象或返回`dio.resolve(data)`。
        // 这样请求将会被终止，上层then会被调用，then中返回的数据将是你的自定义数据data.
        //
        // 如果你想终止请求并触发一个错误,你可以返回一个`DioError`对象，或返回`dio.reject(errMsg)`，
        // 这样请求将被中止并触发异常，上层catchError会被调用。
      }, onResponse: (Response response) {
        // 在返回响应数据之前做一些预处理
        return response; // continue
      }, onError: (DioError e) {
        // 当请求失败时做一些预处理
        return e; //continue
      }));*/
    }
    return dio;
  }

  static clear() {
    dio = null;
  }

  // 获取安装地址
  Future<String> get theToken async {
    final SharedPreferences prefs  = await _prefs;
    var token = prefs.getString('token') ?? '';
    return token;
  }

  /*
  Future<String> getToken() async {
    final SharedPreferences prefs  = await _prefs;
    var token = prefs.getString('token') ?? '';
    return token;
  }
*/

  /// request method
  static Future<Map> request(String url, {data, method, context}) async {
    data = data ?? {};
//    method = method ?? 'GET';

    if (method == GET) {
      //组合GET请求的参数
      if (data != null && data.isNotEmpty) {
        StringBuffer sb = new StringBuffer("?");
        data.forEach((key, value) {
          sb.write("$key" + "=" + "$value" + "&");
        });
        String paramStr = sb.toString();
        paramStr = paramStr.substring(0, paramStr.length - 1);
        url += paramStr;
      }
/*
    /// restful 请求处理
    /// /gysw/search/hist/:user_id        user_id=27
    /// 最终生成 url 为     /gysw/search/hist/27
    data.forEach((key, value) {
      if (url.indexOf(key) != -1) {
        url = url.replaceAll(':$key', value.toString());
      }
    });
*/
    } else {
      if (data != null && data.isNotEmpty) {
        data = FormData.from(data);
      } else {
        data = FormData.from({});
      }
    }

    /// 打印请求相关信息：请求地址、请求方式、请求参数
    print('请求地址：【' + method + '  ' + url + '】');
    print('请求参数：' + data.toString());

    Dio dio = createInstance();

    var token = await HttpUtils().theToken;
    dio.options.headers = {
      'access-token': token,
    };

    var result;
    try {
      Response response = await dio.request(GlobalConfig.base + url,
          data: data, options: new Options(method: method));

      var statusCode = response.statusCode;
      //处理错误部分
      if (statusCode < 0) {
        var errorMsg = "网络请求错误,状态码:" + statusCode.toString();
        print(errorMsg);
//        _handError(errorCallBack, errorMsg);

      }

      result = response.data;

      /// 打印响应相关信息
      print('响应数据：' + response.toString());
      if (response.data["error_code"] == '-2' && context) {
        print('error_code==-2,重新登录1');
        DialogUtils.close2Logout(context);
      }
    } on DioError catch (e) {
      /// 打印请求失败相关信息
      print('请求出错：' + e.toString());
    }

    return result;
  }

  //get请求
  void get(String url, Function callBack,
      {Map<String, String> params, Function errorCallBack}) async {
    _request(url, callBack,
        method: GET, params: params, errorCallBack: errorCallBack);
  }

  //post请求
  void post(String url, Function callBack,
      {Map<String, String> params, Function errorCallBack}) async {
    _request(url, callBack,
        method: POST, params: params, errorCallBack: errorCallBack);
  }

  //post请求
  static Future<Map> apipost(BuildContext context, String url,
      Map<String, String> params, Function callBack) async {
    _request(url, callBack, method: POST, params: params, context: context);
  }

  //具体的还是要看返回数据的基本结构
  static void _request(String url, Function callBack,
      {String method,
      Map<String, String> params,
      Function errorCallBack,
      BuildContext context}) async {
    print("<net---> url :<" + method + ">" + url);

    if (params != null && params.isNotEmpty) {
      print("<net> params :" + params.toString());
    }

    String errorMsg = "";
    int statusCode;

    var connectivityResult = await (new Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile) {
    } else if (connectivityResult == ConnectivityResult.wifi) {
    } else if (connectivityResult == ConnectivityResult.none) {
      errorMsg = "请检查网络";
      print("请检查网络");
      _handError(errorMsg, errorCallback: errorCallBack, context: context);
    }

    try {
      dio = createInstance();
      String token =    await HttpUtils().theToken;
      dio.options.headers = {
        'access-token': token,
      };

      print("---_request-ing---");
      if (method == GET) {
        //组合GET请求的参数
        if (params != null && params.isNotEmpty) {
          /// restful 请求处理
          params.forEach((key, value) {
            if (url.indexOf(key) != -1) {
              url = url.replaceAll(':$key', value.toString());
            }
          });
        }
      }

      if (params == null || params.isEmpty) {
        params = {};
      }

      Response response = await dio.request(GlobalConfig.base + url,
          data: FormData.from(params), options: new Options(method: method));
      statusCode = response.statusCode;

      //处理错误部分
      if (statusCode < 0 && errorCallBack != null) {
        errorMsg = "网络请求错误,状态码:" + statusCode.toString();
        _handError(errorMsg, errorCallback: errorCallBack, context: context);
      }

      if (response.data["error_code"].toString() =='-2') {
        print('error_code==-2,重新登录2');
        DialogUtils.close2Logout(context);
      }

      if (callBack != null) {
        callBack(response.data);
      }
      else{
        DialogUtils.showToastDialog('请求成功');
      }

    } catch (exception) {
      if (errorCallBack != null)
        _handError(exception.toString(),
            errorCallback: errorCallBack, context: context);
    }
  }

  //处理异常
  static void _handError(String errorMsg,
      {BuildContext context, Function errorCallback}) {
    print("<net> errorMsg :" + errorMsg);
    if (errorCallback != null) {
      DialogUtils.showToastDialog(context);
//      errorCallback(errorMsg);
    }
  }

}
