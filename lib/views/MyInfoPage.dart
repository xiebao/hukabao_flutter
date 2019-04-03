import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../model/globle_model.dart';
import '../utils/DialogUtils.dart';
import '../routers/application.dart';
import '../globleConfig.dart';

import 'webViewnew.dart';
import 'Detail.dart';
import 'login.dart';

class MyInfoPage extends StatefulWidget {
  @override
  MyInfoPageState createState() => new MyInfoPageState();
}

class MyInfoPageState extends State<MyInfoPage> {
/*  with  AutomaticKeepAliveClientMixin
@override
bool get wantKeepAlive => true;*/

String _token;
  static const double IMAGE_ICON_WIDTH = 30.0;
  static const double ARROW_ICON_WIDTH = 16.0;

  var titles = ["","VIP支付", "我的邀请码", "我的推荐", "我的收益", "分享一下","关于我们", "退出"];
  List icons = [
    Icons.all_inclusive,
    Icons.supervisor_account,
    Icons.assignment,
    Icons.email,
    Icons.share,
    Icons.add_call,
    Icons.exit_to_app
  ];

  var rightArrowIcon =Icon(Icons.chevron_right, color: GlobalConfig.mainColor);
   String _userName;
   String _userAvatar;
   String _userPhone;

  @override
  Widget build(BuildContext context) {
      var listView = ListView.builder(
      itemCount: titles.length,
      itemBuilder: (context, i) => renderRow(i),
    );

      return listView;
  }


  Widget getIconImage(path) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 0.0, 10.0, 0.0),
      child: Image.asset(path,
          width: IMAGE_ICON_WIDTH, height: IMAGE_ICON_WIDTH),
    );
  }

  renderRow(i) {
    if (i == 0) {
      var avatarContainer = new Container(
        color: GlobalConfig.mainColor,//new Color.fromARGB(255, 0, 215, 198),
        height: 200.0,
        child: new Center(
          child:  Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              _userAvatar == null
                  ? new Image.asset(
                "images/logo.png",
                width: 60.0,
              )
                  : new Container(
                width: 60.0,
                height: 60.0,
                decoration: new BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.transparent,
                  image: new DecorationImage(
                      image: new NetworkImage(_userAvatar),
                      fit: BoxFit.cover),
                  border: new Border.all(
                    color: Colors.white,
                    width: 2.0,
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.fromLTRB(0.0, 5.0, 0.0, 0.0),
                child: Text(_userName??_userPhone,
                  style: new TextStyle(color: Colors.white, fontSize: 16.0),
                ),
              ),
            ],
          )),
      );
      return new GestureDetector(
        onTap: () {
          Navigator.push(context,
              new MaterialPageRoute(builder: (context) => LoginPage()));
        },
        child: avatarContainer,
      );
    }

    return new InkWell(
      child: Column(
        children: <Widget>[
          new Padding(
            padding: const EdgeInsets.fromLTRB(10.0, 15.0, 10.0, 15.0),
            child: new Row(
              children: <Widget>[
                Container(
                  child: Icon(icons[i - 1]),
                  margin: EdgeInsets.fromLTRB(0.0, 0.0, 10.0, 0.0),
                ),
                new Expanded(
                    child: new Text(
                      titles[i],
                      style: new TextStyle(fontSize: 16.0),
                    )),
                rightArrowIcon
              ],
            ),
          ),
          Divider(
            height: 1.0,
          )
        ],
      ),
      onTap: () {
        _handleListItemClick(i);
      },
    );
  }

  _handleListItemClick(int index) {
    switch (index) {
      case 1:
        String h5_url = "${GlobalConfig.webbase}/WebPay/vipPay/token/";
        Application.run(context, "/web?url=${Uri.encodeComponent(h5_url)}&title=${Uri.encodeComponent('VIP支付')}");
        return;
//        String h5_url = "${GlobalConfig.webbase}/WebPay/payCode/?uid=663&money=100&token=";
        Navigator.push(
            context,
            new MaterialPageRoute(
                builder: (context) => new WebView('VIP支付',h5_url )));
        break;
      case 2:
//        是一张图来的
                String h5_url = "${GlobalConfig.webbase}CreditCard/myqrCode/token/";
        print(h5_url);
        Application.run(context, "/web?url=${Uri.encodeComponent(h5_url)}&title=${Uri.encodeComponent('我的邀请码')}");

        break;
      case 3:
        String h5_url = "${GlobalConfig.webbase}CreditCard/shareProfit/token/$_token";
        Navigator.push(
            context,
            new MaterialPageRoute(
                builder: (context) => new WebView('我的推荐',h5_url)));
        break;
       /* Navigator.push(context,
            new MaterialPageRoute(builder: (context) => new Detail('88')));
        break;*/
      case 4:
        String h5_url = "${GlobalConfig.webbase}/CreditCard/myMoneyBag/token/$_token";
        Navigator.push(
            context,
            new MaterialPageRoute(
                builder: (context) => new WebView('我的钱包',h5_url)));
        break;
      case 5:
        DialogUtils.close2Logout(context);
     /*
        String h5_url = "https://github.com/zhibuyu/Flutter_Stocks/issues";
        Navigator.push(
            context,
            new MaterialPageRoute(
                builder: (context) => new WebView( '意见反馈',h5_url)));*/
        break;
      case 6:
        Application.router.navigateTo(context, "/share");
        break;
      case 7:
        DialogUtils.close2Logout(context);
        break;

    }
  }


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    final model = globleModel().of(context);
    print("----------------------${model.token}-------------------------------------");
    print(model.token) ;
    if(model.token=='') {
      DialogUtils.close2Logout(context);
    }
    else
      {
        setState(() {
          _token=model.token;
        _userName=model.userinfo.name;
        _userAvatar=model.userinfo.avtar;
        _userPhone=model.userinfo.phone;
        });
      }

  }
/*
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  void didUpdateWidget(MyInfoPage oldWidget) {
    // TODO: implement didUpdateWidget
    super.didUpdateWidget(oldWidget);
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
  }*/
}