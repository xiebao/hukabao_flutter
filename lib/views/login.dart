import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../model/globle_model.dart';
import 'package:fluwx/fluwx.dart' as fluwx;
import '../globleConfig.dart';
import '../utils/DialogUtils.dart';
import '../utils/HttpUtils.dart';
import '../utils/comUtil.dart';
import 'activeUser.dart';
import 'register.dart';
import 'fogetpwd.dart';

class LoginPage extends StatefulWidget {
  LoginPage({Key key, this.title}) : super(key: key);

  final String title;
  @override
  LoginPageState createState() => new LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  bool _phoneState, _pwdState = false;
  String _checkStr = '', _wechaName, _unionId, _openid, _avatar;
  TextEditingController _phonecontroller = new TextEditingController();
  TextEditingController _pwdcontroller = new TextEditingController();
  Map<String, dynamic> _wxuserInfo;
  final FocusNode _focusNode = FocusNode();
  bool _loading = false;
  // 显示加载进度条
  void showLoadingDialog() {
    setState(() {
      _loading = true;
    });
    print('showLoadingDialog=============');
    DialogUtils.showLoadingDialog(context);
  }

  // 隐藏加载进度条
  hideLoadingDialog() {
    if (_loading) {
      print("------------hideLoadingDialog-----------");
      Navigator.of(context).pop();
      setState(() {
        _loading = false;
      });
    }
  }

  Future _userWxInfo(String code) async {
    try {
      Map<String, String> params = {
        "code": code,
      };
      showLoadingDialog();
      await HttpUtils.post(context, 'WxAuth/userWxInfo', (response) async {
        print("----------------get userWxInfo--------------------");
        print(response['data']);
        if (response['data']['unionid'].toString() != '') {
          print(response['data']['unionid']);
          _wechaName = response['data']['nickname'];
          _unionId = response['data']['unionid'];
          _openid = response['data']['openid'];
          _avatar = response['data']['avatar'];
          _wxuserInfo = response['data'];

          await _checkWxlogin(_unionId, response['data']['nickname']);
        } else {
          _alertmag("微信认证失败!");
        }
        /*
        *{openid: oEJBM1crLLjW1lGFM5aoGs6id0ok, nickname: 努力吧, sex: 0, language: zh_CN, city: , province: , country: , headimgurl: http://thirdwx.qlogo.cn/mmopen/vi_32/666ZxTwTYHUu57JWG5trN0vMjt7icY9WrByHPL9Vtjic3S77k8yOHBswkVGZ0jhBUeAWFYNlIfMsSXKd3khEZKpQ/132, privilege: [], unionid: omxDS1GXNd_q74TIAsdblxFSDw4s}
        * */
      }, params: params);
    } catch (e) {
      print(e);
      await _alertmag('网络连接错误');
    } finally {
      hideLoadingDialog();
    }
  }

  @override
  void initState() {
    super.initState();
    fluwx.responseFromAuth.listen((response) {
      print('微信登录回调');
      print(response.errCode);
      if (response.errCode == 0) {
        print(response.code);
        _userWxInfo(response.code);
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _loading = null;
    _phoneState = null;
    _pwdState = null;
    _phonecontroller = null;
    _pwdcontroller = null;
    _wxuserInfo = null;
  }

  void _login() async {
    var _phone = _phonecontroller.text.trim();
    var _pwd = _pwdcontroller.text.trim();
    var pdata = {
      "phone": _phone,
      "password": _pwd,
      "unionid": _unionId,
      "openid": _openid,
      "nickname": _wechaName,
      "avatar": _avatar,
      "wxinfo": jsonEncode(_wxuserInfo),
    };
    try {
      showLoadingDialog();
      print(pdata);
      await HttpUtils.post(context, "Public/Login", (response) async {
        print(response);
        hideLoadingDialog();
        if (response["error_code"] == 1) {
          String token = response["userinfo"]["token"];
          print(response["userinfo"]);
          if (token != null && token.trim() != "") {
            await _loginok(token, response["userinfo"]);
          } else {
            _alertmag("登录失败)");
          }
        } else {
          _alertmag("账号或密码错误");
        }
      }, params: pdata);
    } catch (e) {
      print(e);
      await _alertmag('网络连接错误');
      hideLoadingDialog();
    }
  }

  void _checkWxlogin(String unionId, String ncname) async {
    try {
      if (unionId == '' || unionId == null) return;
      var pdata = {
        "unionid": unionId,
      };
      await HttpUtils.post(context, "Public/checkWx", (response) async {
        print(response);
        if (response["error_code"] == 1) {
          await _loginok(response["userinfo"]["token"], response["userinfo"]);
        } else {
          _alertmag("未绑定，请输入账户登录绑定");
          setState(() {
            _loading = false;
            _wechaName = ncname;
          });
        }
      }, params: pdata);
    } catch (e) {
      print(e);
      await _alertmag('微信认证异常，请重试');
    }
  }

  void _loginok(String token, Map<String, dynamic> userinfo) async {
    final model = globleModel().of(context);
    await model.setlogin(token, userinfo);
    print('正在登录到指定位置');
    //    Navigator.of(context).pop();
    if (userinfo['userActive'] == '0') {
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => activeUser(),
          ));
    } else
//        Application.run(context, "/home");
      Navigator.pushNamedAndRemoveUntil(
          context, '/home', (Route router) => false);
  }

  void _checkPhone() {
    if (_phonecontroller.text != null &&
        _phonecontroller.text.trim().length == 11 &&
        ComFunUtil.isChinaPhoneLegal(_phonecontroller.text.trim())) {
      _phoneState = true;
    } else {
      _phoneState = false;
    }
  }

  void _checkPwd() {
    if (_pwdcontroller.text != null &&
        _pwdcontroller.text.trim().length >= 6 &&
        _pwdcontroller.text.trim().length <= 10) {
      _pwdState = true;
    } else {
      _pwdState = false;
    }
  }

  void _alertmag(String msg) async {
    await DialogUtils.showToastDialog(context, msg);
  }

  void _checkSub() {
    _checkPhone();
    _checkPwd();
    if (_phoneState && _pwdState) {
      _checkStr = '';
    } else {
      if (!_phoneState) {
        _checkStr = '请输入11位手机号！';
      } else if (!_pwdState) {
        _checkStr = '请输入6-10位密码！';
      }
    }
    print(_checkStr);
    if (_checkStr == '') {
      _login();
    } else {
      _alertmag(_checkStr);
    }
  }

  Widget _buildotherTips() {
    return Padding(
      padding: new EdgeInsets.fromLTRB(20.0, 30.0, 20.0, 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween, //子组件的排列方式为主轴两端对齐
        children: <Widget>[
          InkWell(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => register(),
                  ));
            },
            child: Text(
              "注册",
              style: new TextStyle(fontSize: 14.0),
            ),
          ),
          InkWell(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => fogetpwdPage(),
                  ));
            },
            child: Text(
              "忘记密码",
              style: new TextStyle(fontSize: 14.0),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeinxinButtonField() {
    return Padding(
        padding: new EdgeInsets.all(10.0),
        child: IconButton(
            icon: Image.asset(
              "images/sysicon/icon_wechat.png",
              fit: BoxFit.fill,
            ),
            onPressed: () {
              fluwx.sendAuth(
                  scope: "snsapi_userinfo", state: "wechat_sdk_demo_test");
              /*        .then((data) {
                print('授权登录结果');
                print(data);
              });*/
            }));
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        child: Scaffold(
          /*     appBar: AppBar(
        title: new Text('登录'),
        centerTitle: true,
      ),*/
          body: SingleChildScrollView(
            child: new Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.all(10),
                  child: Container(
                    height: 10,
                    child: Text(''),
                  ),
                ),
                new Padding(
                    padding: new EdgeInsets.all(30.0),
                    child: Image.asset(
                      'images/logo.png',
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    )),
                Text(_loading ? "正在登录中……" : ''),
                Text(_wechaName != null ? "您好，$_wechaName，首次登录请先绑定账户!" : ''),
                new Padding(
                  padding: new EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 15.0),
                  child: new Stack(
                    alignment: new Alignment(1.0, 1.0),
                    //statck
                    children: <Widget>[
                      new Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            new Padding(
                                padding:
                                    new EdgeInsets.fromLTRB(0.0, 0.0, 5.0, 0.0),
                                child: Icon(Icons.person,
                                    color: GlobalConfig.mainColor)),
                            new Expanded(
                              child: new TextField(
                                controller: _phonecontroller,
                                cursorColor: GlobalConfig.mainColor,
                                keyboardType: TextInputType.phone,
                                //光标切换到指定的输入框
                                onEditingComplete: () => FocusScope.of(context)
                                    .requestFocus(_focusNode),
                                decoration: new InputDecoration(
                                  hintText: '请输入手机号码',
                                  contentPadding: EdgeInsets.all(10.0),
                                ),
                              ),
                            ),
                          ]),
                      new IconButton(
                        icon: new Icon(Icons.clear, color: Colors.black45),
                        onPressed: () {
                          _phonecontroller.clear();
                        },
                      ),
                    ],
                  ),
                ),
                new Padding(
                  padding: new EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 40.0),
                  child: new Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        new Padding(
                            padding:
                                new EdgeInsets.fromLTRB(0.0, 0.0, 5.0, 0.0),
                            child: Icon(
                              Icons.lock,
                              color: GlobalConfig.mainColor,
                            )
                            /*   new Image.asset(
                            'images/icon_password.png',
                            width: 40.0,
                            height: 40.0,
                            fit: BoxFit.fill,
                          ),*/
                            ),
                        new Expanded(
                          child: new TextField(
                            controller: _pwdcontroller,
                            // 光标颜色
                            cursorColor: GlobalConfig.mainColor,
                            focusNode: _focusNode,
                            decoration: new InputDecoration(
                              hintText: '请输入密码',
                              contentPadding: EdgeInsets.all(10.0),
                              suffixIcon: new IconButton(
                                icon: new Icon(Icons.clear,
                                    color: GlobalConfig.mainColor),
                                onPressed: () {
                                  _pwdcontroller.clear();
                                },
                              ),
                            ),
                            obscureText: true,
                          ),
                        ),
                      ]),
                ),
                new Container(
                  width: 340.0,
                  child: new Card(
                    color: GlobalConfig.mainColor,
                    elevation: 16.0,
                    child: FlatButton(
                      disabledColor: _loading ? Colors.grey : null,
                      child: Padding(
                        padding: EdgeInsets.all(10.0),
                        child: Text(
                          '登录',
                          style: new TextStyle(
                              color: Colors.white, fontSize: 16.0),
                        ),
                      ),
                      onPressed: () {
                        _checkSub();
                      },
                    ),
                  ),
                ),
                _buildotherTips(),
                _buildWeinxinButtonField(),
              ],
            ),
          ),
/*      floatingActionButton: FloatingActionButton.extended(
        icon: Icon(Icons.unarchive),
        label: Text("测试"),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => activeUser(),
            ));
        },
      ),*/
        ),
        onWillPop: _doubleExit);
  }

  int _lastClickTime = 0;
  Future<bool> _doubleExit() {
    int nowTime = new DateTime.now().microsecondsSinceEpoch;
    if (_lastClickTime != 0 && nowTime - _lastClickTime > 1500) {
      return showDialog(
        context: context,
        builder: (context) => new AlertDialog(
              title: new Text('退出' + GlobalConfig.appName),
              content: new Text('确定要退出App吗'),
              actions: <Widget>[
                new FlatButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    return Future.value(false);
                  },
                  child: new Text('取消'),
                ),
                new FlatButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    SystemChannels.platform.invokeMethod('SystemNavigator.pop');
                    return Future.value(true);
                  },
                  child: new Text('确定'),
                ),
              ],
            ),
      );
      //Future.value(true);
    } else {
      _lastClickTime = new DateTime.now().microsecondsSinceEpoch;
      new Future.delayed(const Duration(milliseconds: 1500), () {
        _lastClickTime = 0;
      });
      return new Future.value(false);
    }
  }
}
