import 'package:scoped_model/scoped_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'userinfo.dart';
import 'dart:core';

class globleModel extends Model {

  bool _loginStatus = false;
  String _token = '';
  Userinfo _userinfo;

  bool get loginStatus => _loginStatus;
  String get token => _token;
  Userinfo get userinfo => _userinfo;

  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  globleModel of(context) => ScopedModel.of(context);

  Future setlogin(token, Map<String, dynamic> userinfo) async {
    print('+++++++++++++++setlogin+++++++++++++++');
    SharedPreferences sp = await _prefs;
    sp.setString("token", token);

    _token = token;
    _loginStatus = true;
    _userinfo = Userinfo.fromJson(userinfo);
    print(_userinfo.phone);
    // 通知所有的 listener
    notifyListeners();
  }

  Future setlogout() async {
    SharedPreferences prefs = await _prefs;
    prefs.remove('token');
    prefs.clear(); //清空键值对
    _token = null;
    _loginStatus = false;
    _userinfo = null;
    print('setlogout');
    notifyListeners();
  }

}
