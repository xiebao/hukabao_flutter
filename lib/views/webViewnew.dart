import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import '../utils/HttpUtils.dart';
import '../components/loading_gif.dart';
import '../globleConfig.dart';

class WebView extends StatefulWidget {
  final String articleUrl;
  final String title;

  WebView(this.title, this.articleUrl);

  @override
  _ArticleDetailState createState() => _ArticleDetailState();
}

class _ArticleDetailState extends State<WebView> {
  bool hasLoaded = false;
  final flutterWebViewPlugin = new FlutterWebviewPlugin();
  String _token;
  void _gettoken()async{
    await HttpUtils().theToken.then((v){ setState(() {_token= v; });});
  }
  @override
  void initState() {
    super.initState();
    _gettoken();
    flutterWebViewPlugin.onStateChanged.listen((state) {
      if (state.type == WebViewState.finishLoad) {
        //有掘金web版本详情页的finished触发时间实在太长，所以这里就省略了hasLoaded的处理,其实也就是为了界面更友好
        setState(() {
          print(state.type);
          hasLoaded = true;
        print("========2222========");
        });
      }
    });

  }

  Future<bool> _requestPop() {
    Navigator.of(context).pop(100);
    ///弹出页面并传回int值100，用于上一个界面的回调
    return new Future.value(false);
  }

  @override
  Widget build(BuildContext context) {
    print(_token);
      return new WillPopScope(
          child: new WebviewScaffold(
            url: widget.articleUrl + _token,
            appBar: new AppBar(
//              iconTheme: IconThemeData(color: Colors.white),
              backgroundColor: GlobalConfig.mainColor,
              title: new Text(
                widget.title,
                style: new TextStyle(color: Colors.white),
              ),
            ),
            withZoom: false,
            withLocalStorage: true,
            withJavascript: true,
            initialChild: Container(
              color: Colors.white,
              child: const Center(
//                child: Text('Waiting.....'),
                child: Loading(color: Color(0xFFC9A063), size: 56.0),
              ),
            ),
          ),
          onWillPop: _requestPop);
  }
}
