import 'dart:async'; //timer
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/HttpUtils.dart';
import '../utils/DialogUtils.dart';
import '../utils/comUtil.dart';
import '../routers/application.dart';

import '../globleConfig.dart';
import '../views/webViewnew.dart';

class register extends StatefulWidget {
  @override
  registerState createState() => new registerState();
}

class registerState extends State<register> {
  GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  final GlobalKey<FormFieldState<String>> _passwordFieldKey =
      GlobalKey<FormFieldState<String>>();

  String _phoneNo;
  String _password = '';
  String _inviteCode;
  bool _termsChecked = true;
  bool _passwordre = false;

  bool _obscureText = true;

  int _seconds = 0;
  String _verifyStr = '获取验证码';
  String _verifyCode;
  Timer _timer;

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('注册'),
      ),
      body: new Center(
        child: Container(
            margin: EdgeInsets.all(20.0),
            color: Colors.white,
            child: Form(
              //绑定状态属性
              key: _formKey,
//              autovalidate: true,
              child: ListView(
                children: [
                  _buildPhoneText(),
                  _buildVerifyCodeEdit(),
                  _buidPassword(),
                  _buidRePassword(),
                  _buildFromCodeText(),
                  _buideRegtxt(),
                  FlatButton(
                    color: GlobalConfig.mainColor,
                    child: Padding(
                      padding: EdgeInsets.all(10.0),
                      child: Text(
                        '确定',
                        style:
                            new TextStyle(color: Colors.white, fontSize: 14.0),
                      ),
                    ),
                    onPressed: () {
                      _termsChecked ?
                      _forSubmitted():null;
                    },
                  ),
                ],
//                      child: RaisedButton(
//                          child: Text('添加'), onPressed: _forSubmitted),
//                    ),
              ),
            )),
      ),
    );
  }

  void _getsmsCode() async {
    final form = _formKey.currentState;
    if (form.validate()) {
      form.save();
      Map<String, String> params = {
        "phone": _phoneNo,
        "type": '1',
      };

      print("---Public/smsSend---");
      print(params);
      HttpUtils.apipost(context, "Public/smsSend", params, (response) {
        print(response);
        DialogUtils.showToastDialog(context, text: response['message']);
        if (response['error_code'] == 1) {
          setState(() {
            _startTimer();
          });
        }
      });
    }
  }

  _startTimer() {
    _seconds = 60;
    _timer = new Timer.periodic(new Duration(seconds: 1), (timer) {
      if (_seconds == 0) {
        _cancelTimer();
        return;
      }

      _seconds--;
      _verifyStr = '$_seconds(s)';
      setState(() {});
      if (_seconds == 0) {
        _verifyStr = '重新发送';
      }
    });
  }

  _cancelTimer() {
    _timer?.cancel();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  void _forSubmitted() {
    final form = _formKey.currentState;
    if (form.validate() && _verifyCode != '') {
      form.save();
      Map<String, String> params = {
        "phone": _phoneNo,
        "password": _password,
        "inviteCode": _inviteCode,
        "code": _verifyCode
      };
      print(params);
      HttpUtils.apipost(context, "Public/register", params, (response) {
        DialogUtils.showToastDialog(context, text: response['message']);
        print(response);
        if (response['error_code'] == '1') Navigator.pop(context, "1");
//        关闭当前页面并返回添加成功通知
      });
    }
  }

  Widget _buideRegtxt() {
    return new CheckboxListTile(
        title: Row(
          children: <Widget>[
            new Text(
              '注册表示同意',
              style: TextStyle(fontSize: 12),
            ),
            InkWell(
              onTap: () {
                Application.run(context, "/web",url: '${GlobalConfig.base}/Public/regText',title: '注册协议',withToken: false);
              },
              child: new Text(
                '注册协议',
                style: TextStyle(fontSize: 12, color: Colors.blue),
              ),
            )
          ],
        ),
        controlAffinity: ListTileControlAffinity.leading,
        value: _termsChecked,
        onChanged: (bool value) => setState(() => _termsChecked = value));
  }

  Widget _buidPassword() {
    return TextFormField(
      obscureText: _obscureText,
      validator: (String value) {
        if (value.isEmpty || value.trim().length <= 6) {
          return '密码过短';
        }
      },
      onFieldSubmitted: (String value) {
        setState(() {
          _password = value;
        });
      },
      onSaved: (String value) {
        setState(() {
          _password = value;
        });
      },
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(vertical: 10.0),
        filled: true,
        hintText: "请输入密码",
        helperText: "请输入至少6位密码",
        helperStyle: TextStyle(fontSize: 8),
        icon: Icon(Icons.lock) ,
        hintStyle: TextStyle(fontSize: 10),
        fillColor: Colors.white,
        errorStyle: TextStyle(fontSize: 8),
        suffixIcon: GestureDetector(
//          dragStartBehavior: DragStartBehavior.down,
          onTap: () {
            setState(() {
              _obscureText = !_obscureText;
            });
          },
          child: Icon(
            _obscureText ? Icons.visibility : Icons.visibility_off,
            semanticLabel: _obscureText ? 'show password' : 'hide password',
          ),
        ),
      ),
    );
  }

  Widget _buidRePassword() {
    return TextFormField(
//      enabled: _password != '' && _password.isNotEmpty,
      obscureText: true,
      decoration: const InputDecoration(
        contentPadding: const EdgeInsets.symmetric(vertical: 10.0),
        hintText: "密码确认",
        helperText: "请再一次输入密码",
        helperStyle: TextStyle(fontSize: 8),
        icon: Icon(Icons.lock) ,
        hintStyle: TextStyle(fontSize: 10),
        filled: true,
        fillColor: Colors.white,
        errorStyle: TextStyle(fontSize: 8),
      ),

//      validator: (String value) {return _validatePassword(value);},
      validator: (String value) {
        _passwordre = false;
        if (_password == '') return "";
        if (_password != value)
          return "";
        else
          _passwordre = true;
      },
    );
  }

  Widget _buildFromCodeText() {
    return TextFormField(
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(vertical: 10.0),
        helperText: '选填，为空为平台邀请',
        helperStyle: TextStyle(fontSize: 8),
        filled: true,
        icon: Icon(Icons.camera_front) ,

        hintStyle: TextStyle(fontSize: 10),
        fillColor: Colors.white,
        errorStyle: TextStyle(fontSize: 8),
      ),
      autovalidate: true,
      style: new TextStyle(fontSize: GlobalConfig.formfontSize),
      validator: (String value) {},
      onSaved: (String value) {
        _inviteCode = value.trim();
      },
    );
  }

  Widget _buildPhoneText() {
    var node = new FocusNode();
    return TextFormField(
//      autovalidate: true,
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(vertical: 10.0),
        icon: Icon(Icons.phone) ,
        hintText:  "请输入手机号码",
        hintStyle: TextStyle(fontSize: 10),
        filled: true,
        fillColor: Colors.white,
        errorStyle: TextStyle(fontSize: 8),
      ),
//      style: Theme.of(context).textTheme.headline,
      style: new TextStyle(fontSize: GlobalConfig.formfontSize),
      maxLines: 1,
      maxLength: 11,
      //键盘展示为号码
      keyboardType: TextInputType.phone,
      //只能输入数字
      inputFormatters: <TextInputFormatter>[
        WhitelistingTextInputFormatter.digitsOnly,
      ],
      validator: (String value) {
        if (value.isEmpty) {
          return '';
        } else {
          if (!ComFunUtil.isChinaPhoneLegal(value.trim())) return '号码有误';
        }
      },
      onSaved: (String value) {
        _phoneNo = value.trim();
      },
      onFieldSubmitted: (text) {
        FocusScope.of(context).reparentIfNeeded(node);
      },
    );
  }

  Widget _buildVerifyCodeEdit() {
    var node = new FocusNode();
    Widget verifyCodeEdit = new TextFormField(
//      autovalidate: true,
      style: new TextStyle(fontSize: GlobalConfig.formfontSize),
      decoration: new InputDecoration(
        contentPadding: const EdgeInsets.symmetric(vertical: 10.0),
        icon: Icon(Icons.assignment_late) ,
        hintText:  "请输入验证码",
        hintStyle: TextStyle(fontSize: 10),
        filled: true,
        fillColor: Colors.white,
        errorStyle: TextStyle(fontSize: 8),
      ),
      maxLines: 1,
      maxLength: 6,
      //键盘展示为数字
      keyboardType: TextInputType.number,
      //只能输入数字
      inputFormatters: <TextInputFormatter>[
        WhitelistingTextInputFormatter.digitsOnly,
      ],

      validator: (String value) {
        if (value.isEmpty) {
          return '';
        }
      },
      onSaved: (String value) {
        _verifyCode = value.trim();
      },

      onEditingComplete: () {
        FocusScope.of(context).reparentIfNeeded(node);
      },
    );
    Widget verifyCodeBtn = new InkWell(
      onTap: (_seconds == 0) ? _getsmsCode : null,
      child: new Container(
       alignment: Alignment.center,
        width: 80.0,
        height: 26.0,
        padding: EdgeInsets.fromLTRB(5.0, 5.0, 5.0, 5.0),
        decoration: BoxDecoration(
            border: new Border.all(
              width: 1.0,
              color: Colors.grey,
            )
        ),
        child: Text(
          '$_verifyStr',
          style: new TextStyle(fontSize: 11),
        ),
      ),
    );

    return new Padding(
      padding: const EdgeInsets.only(
        left: 0,
        right: 0,
        top: 5.0,
      ),
      child: new Stack(
        children: <Widget>[
          verifyCodeEdit,
          new Align(
            alignment: Alignment.topRight,
            child: verifyCodeBtn,
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  void didUpdateWidget(register oldWidget) {
    // TODO: implement didUpdateWidget
    super.didUpdateWidget(oldWidget);
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
  }
}
