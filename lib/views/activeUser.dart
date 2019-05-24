import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
//import 'package:qrcode_reader/qrcode_reader.dart';
import '../utils/HttpUtils.dart';
import '../utils/DialogUtils.dart';
import '../routers/application.dart';
import '../model/globle_model.dart';

class activeUser extends StatefulWidget {
  @override
  activeUserState createState() => new activeUserState();
}

class activeUserState extends State<activeUser> {
  bool _autovalidate = false;
  String _qrcode="";

  final GlobalKey<FormState> _formKey1 = GlobalKey<FormState>();

  TextEditingController _codeCtrl = TextEditingController();


  void _handleSubmitted() async{
    final FormState form = _formKey1.currentState;
    if (form.validate()){
      form.save();
      _qrcode = _codeCtrl.text.trim();
      if (_qrcode == '') return;
      final model =globleModel().of(context);
      String token= model.token;
      if (token == '')
        DialogUtils.close2Logout(context);

      List<String> coda = _qrcode.split(",");
      Map<String, String> params = {
        "cardno": coda[0], //10 位	卡号
        "code": coda[1], //32 位	激活码
        "token":token
      };
      print(params);
     await HttpUtils.apipost(context, "Public/userActive", params, (response) async {
        print(response);
        await DialogUtils.showToastDialog(context,response['message']);
        if (response['error_code'] == '1') {
          Application.router.navigateTo(context, "/");
        }
      });
    }
  }

  Future scan() async {
    print("-=-=-=-=-=-=-=-=-=--");
    try {
      /*    _qrcode =await QRCodeReader()
//       .setAutoFocusIntervalInMs(200) // default 5000
//        .setForceAutoFocus(true) // default false
//        .setTorchEnabled(true) // default false
//        .setHandlePermissions(true) // default true
//        .setExecuteAfterPermissionGranted(true) // default true
        .scan();*/
      print(_qrcode);
    }
    on PlatformException catch (e) {
        _qrcode= "相机权限错误: $e";
    } on FormatException{
      _qrcode="null (User returned using the  back -button before scanning anything. Result)";

    } catch (e) {
    _qrcode=e.toString();
    }
    setState(() {_codeCtrl.text=_qrcode; });
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
                              helperText: '输入激活码.',
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
