import 'package:flutter/material.dart';
import 'package:fluwx/fluwx.dart' as fluwx;

class ShareImagePage extends StatefulWidget {
  @override
  _ShareImagePageState createState() => _ShareImagePageState();
}

class _ShareImagePageState extends State<ShareImagePage> {
  fluwx.WeChatScene scene = fluwx.WeChatScene.SESSION;
  String _imagePath =
      "http://app.hukabao.com/Uploads/App/2019-01-15/5c3db0b171cf5.jpg";
  String _thumbnail = "assets://images/logo.png";

  String _response = "";

  _initFluwx() async {
    await fluwx.register(
        appId: "wx002f0547fa2ff202",
        doOnAndroid: true,
        doOnIOS: true,
        enableMTA: false);
    var result = await fluwx.isWeChatInstalled();
    print("is installed $result");
  }

  @override
  void initState() {
    super.initState();
    _initFluwx();
    fluwx.responseFromShare.listen((data) {
      print("======分享时的======");
      print(data);
      setState(() {
        _response = data.errCode.toString();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: AppBar(
        title: const Text("shareImage"),
        actions: <Widget>[
          IconButton(
              icon: Icon(
                Icons.share,
                color: Colors.white,
              ),
              onPressed: _shareImage)
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: <Widget>[
            TextField(
              decoration: InputDecoration(labelText: "图片地址"),
              controller: TextEditingController(
                  text:
                  "http://app.hukabao.com/Uploads/App/2019-01-15/5c3db0b171cf5.jpg"),
              onChanged: (value) {
                _imagePath = value;
              },
              keyboardType: TextInputType.multiline,
            ),
            TextField(
              decoration: InputDecoration(labelText: "缩略地址"),
              controller: TextEditingController(text: "assets://images/logo.png"),
              onChanged: (value) {
                _thumbnail = value;
              },
            ),
            new Row(
              children: <Widget>[
                const Text("分享至"),
                Row(
                  children: <Widget>[
                    new Radio<fluwx.WeChatScene>(
                        value: fluwx.WeChatScene.SESSION,
                        groupValue: scene,
                        onChanged: handleRadioValueChanged),
                    const Text("会话")
                  ],
                ),
                Row(
                  children: <Widget>[
                    new Radio<fluwx.WeChatScene>(
                        value: fluwx.WeChatScene.TIMELINE,
                        groupValue: scene,
                        onChanged: handleRadioValueChanged),
                    const Text("朋友圈")
                  ],
                ),
                Row(
                  children: <Widget>[
                    new Radio<fluwx.WeChatScene>(
                        value: fluwx.WeChatScene.FAVORITE,
                        groupValue: scene,
                        onChanged: handleRadioValueChanged),
                    const Text("收藏")
                  ],
                )
              ],
            ),
            Text(_response)
          ],
        ),
      ),
    );
  }

  void _shareImage() {
    fluwx.share(fluwx.WeChatShareImageModel(
        image: _imagePath,
        thumbnail: _thumbnail,
        transaction: _imagePath,
        scene: scene,
        description: "这是一张图"));
  }

  void handleRadioValueChanged(fluwx.WeChatScene scene) {
    setState(() {
      this.scene = scene;
    });
  }
}