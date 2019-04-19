import 'dart:core';
import 'package:scoped_model/scoped_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'userinfo.dart';

class globleModel extends Model {
  bool _loginStatus = false;
  String _token = '';
  Userinfo _userinfo;

  bool get loginStatus => _loginStatus;
  String get token => _token;
  Userinfo get userinfo => _userinfo;

  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  globleModel of(context) => ScopedModel.of(context);

  Future setlogin(String token, Map<String, dynamic> userinfo) async {
    await setToken(token);
    _userinfo = Userinfo.fromJson(userinfo);
    print(_userinfo.phone+"=====");
    // 通知所有的 listener
    notifyListeners();
  }

  Future setToken(String token) async {
    SharedPreferences prefs = await _prefs;
    await prefs.setString("token", token);
    print("++++++++setlogin:$token ++++");
    print("===SharedPreferences getString :${prefs.getString("token")}---");
    _token = token;
    _loginStatus = true;

    notifyListeners();
  }

  Future setlogout() async {
    SharedPreferences prefs = await _prefs;
   await prefs.remove('token');
   await prefs.clear(); //清空键值对-有其他参数保留
    _token = null;
    _loginStatus = false;
    _userinfo = null;
    print('setlogout');
    notifyListeners();
  }

}
