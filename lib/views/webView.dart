import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import '../utils/HttpUtils.dart';
import '../components/loading_gif.dart';

class WebView extends StatelessWidget {
  String title;
  String url;
  BuildContext context;
  WebView(String title, String url) {
    this.title = title;
    this.url = url;
  }

  Future<bool> _requestPop() {
    Navigator.of(context).pop(100);
    ///弹出页面并传回int值100，用于上一个界面的回调
    return new Future.value(false);
  }
  @override
  Widget build(BuildContext context) {
    return new WillPopScope(
        child: webpage(title, url),
        onWillPop: _requestPop);

  }
/*    return new WillPopScope(
        child: new WebviewScaffold(
          url: url,
          appBar: new AppBar(
            iconTheme: IconThemeData(color: Colors.white),
            backgroundColor: Colors.deepOrangeAccent,
//              backgroundColor: Color.fromARGB(255, 41, 58, 144),
            title: new Text(
              title,
              style: new TextStyle(color: Colors.white),
            ),
          ),

          withLocalStorage: true,
        ),
        onWillPop: _requestPop);
  }*/
}

class webpage extends StatefulWidget {
  webpage(this.title, this.url);
  final String url;
  final String title;

  @override
  webpageState createState() => new webpageState();
}

class webpageState extends State<webpage> {
  String _token;
  @override
  Widget build(BuildContext context) {
//    if(_token!='')
//      {
        return WebviewScaffold(
          url: widget.url,
          appBar: new AppBar(
            iconTheme: IconThemeData(color: Colors.white),
            backgroundColor: Colors.deepOrangeAccent,
            title: new Text( widget.title,
              style: new TextStyle(color: Colors.white),
            ),
          ),

//          withLocalStorage: true,
        );
//      }
   /*   else
        {
        return Center(
       child: Loading(color: Color(0xFFC9A063), size: 56.0),
    );
        }*/

  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
      setState(() async{
        _token =await HttpUtils().theToken;
      });


  }

}

