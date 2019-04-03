import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:scoped_model/scoped_model.dart';
import '../model/globle_model.dart';
import '../utils/HttpUtils.dart';
import '../components/loginButton.dart';
import '../views/Detail.dart';
import '../views/webViewnew.dart';

class firstPage extends StatefulWidget {
  @override
  firstPageState createState() => firstPageState();
}

class firstPageState extends State<firstPage> {

  String _userName = '未登录';
  String _userPic = '';

   _tablink(globleModel model) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('token') ?? '';
    print("***** $token");

    HttpUtils.apipost(context,'User/cardList', {}, (response) async {
      print(response);
//      model.setlogin({'token':'dfsafdsaf3333333','id':'323'});

      print(response.data.toString());
      print(response.data["error_code"]);
    });

/*
    Navigator.push(context,
        new MaterialPageRoute(builder: (BuildContext context) {
      return Detail('45');
    }));
*/

/*    Navigator.of(context).push(PageRouteBuilder(
        opaque: false,
        pageBuilder: (BuildContext context, _, __) {
//          return Detail('45');
        return WebView('45', 'http://www.baidu.com');
        },
        transitionsBuilder:
            (___, Animation<double> animation, ____, Widget child) {
          return FadeTransition(
            opacity: animation,
            child: RotationTransition(
              turns: Tween<double>(begin: 0.5, end: 1.0).animate(animation),
              child: child,
            ),
          );
        })
    );*/
  }

  @override
  Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          leading: Image.asset(
            'images/logo.png',
          ),
          backgroundColor: Colors.white,
          title: Text('护卡宝'),
          actions: <Widget>[
      /*      LoginButton(
              userName: _userName,
              userPic: _userPic,
            ),*/
            ScopedModelDescendant<globleModel>(
              builder: (context, child, model) {
                return LoginButton(
                  userName:model.token,
                  userPic: _userPic,
                );
              },
            )
          ],
        ),
        body: Center(
//          child: Text('首页内容'),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
//              Text('你都点击'),
              ScopedModelDescendant<globleModel>(
                builder: (context, child, model) {
                  return Text(model.token);
                },
              )
            ],
          ),
        ),
/*        floatingActionButton: FloatingActionButton(
          onPressed: _tablink,
          tooltip: '++',
          child: Icon(Icons.add),
        ),*/
      /*  floatingActionButton: ScopedModelDescendant<globleModel>(
          builder: (context,child,model){
            return FloatingActionButton(
              onPressed: model.getlist(),
              tooltip: 'add',
              child: Icon(Icons.add),
            );
          },
        ),*/
      );
  }
}
