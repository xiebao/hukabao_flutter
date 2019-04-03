import 'package:flutter/material.dart';
import '../utils/HttpUtils.dart';
import '../utils/DialogUtils.dart';
import '../routers/application.dart';
import 'package:barcode_scan/barcode_scan.dart';
import 'dart:async';
import 'package:flutter/services.dart';

//https://juejin.im/post/5b700d2d6fb9a0098b251462


class activeUser extends StatefulWidget {
  @override
  activeUserState createState() => new activeUserState();
}

class activeUserState extends State<activeUser> {
  bool _autovalidate = false;

  final GlobalKey<FormState> _formKey1 = GlobalKey<FormState>();

  TextEditingController _codeCtrl = TextEditingController();


  void _handleSubmitted() {
    final FormState form = _formKey1.currentState;
    if (form.validate()) {
      form.save();
      String codestr = _codeCtrl.text.trim();
      if (codestr == '') return;

      List<String> coda = codestr.split(",");
      Map<String, String> params = {
        "cardno": coda[0], //10 位	卡号
        "code": coda[1], //32 位	激活码
      };
      print(params);
      HttpUtils.apipost(context, "Public/userActive", params, (response) {
        print(response);
        DialogUtils.showToastDialog(context, text: response['message']);
        if (response['error_code'] == 1) {
          Application.router.navigateTo(context, "/");
        }
      });
    }
  }

  Future scan() async {
    try {
      String barcode = await BarcodeScanner.scan();
      setState(() {
         _codeCtrl.text = barcode;
      });
    } on PlatformException catch (e) {
      if (e.code == BarcodeScanner.CameraAccessDenied) {
        DialogUtils.showToastDialog(context, text:"请打开相机权限!");
      } else {
        DialogUtils.showToastDialog(context, text: "位置错误: $e");
      }
    } on FormatException{
      DialogUtils.showToastDialog(context, text:"null (User returned using the  back -button before scanning anything. Result)");

    } catch (e) {
      DialogUtils.showToastDialog(context, text:e);

    }
  }


  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
            title: new Text('用户激活'),
            leading: IconButton(icon: Icon(Icons.arrow_back), onPressed: null),
            actions: <Widget>[
              FlatButton(
                  child: Text('激活'),
                  onPressed: () {
                    _handleSubmitted();
                  })
            ]),
        body: Center(
            child: Form(
                key: _formKey1,
                autovalidate: _autovalidate,
                child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          const SizedBox(height: 24.0),
                          TextFormField(
                            controller: _codeCtrl,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: '请输入激活码',
                              helperText: '请输入激活码.',
                              labelText: '激活码',
                            ),
                            maxLines: 3,
                            validator: (String value) {
                              if (value.isEmpty) {
                                return '请填写激活码';
                              }
                            },
                          ),
                          const SizedBox(height: 24.0),
                     FloatingActionButton.extended(
                      icon: Icon(Icons.aspect_ratio),
                      label: Text("扫码输入"),
                      onPressed: scan,
                    )
                        ])))));
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  void didUpdateWidget(activeUser oldWidget) {
    // TODO: implement didUpdateWidget
    super.didUpdateWidget(oldWidget);
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
  }
}
