import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../model/globle_model.dart';
import '../utils/DialogUtils.dart';
import '../routers/application.dart';
import '../globleConfig.dart';
import '../utils/HttpUtils.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:hukabao/components/ImageCropPage.dart';
import '../utils/dataUtils.dart';
import 'login.dart';

class MyInfoPage extends StatefulWidget {
  @override
  MyInfoPageState createState() => new MyInfoPageState();
}

class MyInfoPageState extends State<MyInfoPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  String _token;
  static const double IMAGE_ICON_WIDTH = 30.0;
  static const double ARROW_ICON_WIDTH = 16.0;

//  var titles = ["","VIP支付", "我的邀请码", "我的推荐", "我的收益", "关于我们","分享一下", "退出"];
  var titles = [
    "",
    "我的卡片",
    "我的计划订单",
    "我的付款记录",
    "权益升级",
    "我的收益",
    "我的团队",
    "分享一下",
    "关于我们",
    "退出"
  ];
  List icons = [
    Icons.credit_card,
    Icons.library_books,
    Icons.assignment,
    Icons.unarchive,
    Icons.monetization_on,
    Icons.group,
    Icons.share,
    Icons.add_call,
    Icons.exit_to_app
  ];

  var rightArrowIcon = Icon(Icons.chevron_right, color: GlobalConfig.mainColor);
  String _userName, _userAvatar, _usermoney, _chileds;
  String _userPhone, _userlevel, _userlevelname;

  GlobalKey<RefreshHeaderState> _headerKey =
      new GlobalKey<RefreshHeaderState>();
  GlobalKey<RefreshFooterState> _footerKey =
      new GlobalKey<RefreshFooterState>();

  @override
  Widget build(BuildContext context) {
    var listView = ListView.builder(
      itemCount: titles.length,
      itemBuilder: (context, i) => renderRow(i),
    );

    return Scaffold(
        body: Center(
            child: EasyRefresh(
      behavior: ScrollOverBehavior(),
      refreshHeader: ClassicsHeader(
        key: _headerKey,
        refreshText: "下拉刷新",
        refreshReadyText: "释放更新",
        refreshingText: "获取新数据...",
        refreshedText: "更新完成",
        moreInfo: "更新中",
        bgColor: GlobalConfig.mainColor,
        textColor: Colors.white,
        moreInfoColor: Colors.white,
//            showMore:false,
      ),
      refreshFooter: ClassicsFooter(
        key: _footerKey,
        bgColor: GlobalConfig.mainColor,
        textColor: Colors.white,
        moreInfoColor: Colors.white,
        showMore: false, //true,
        moreInfo: '加载中',
        noMoreText: '没有更多', // Provide.value<ChildCategory>(context).noMoreText,
        loadReadyText: '上拉加载',
      ),
      child: listView,
      onRefresh: () async {
        await DataUtils.freshUserinfo(context);
        setState(() {
          initinfo();
        });
      },
      loadMore: () async {
        ;
      },
    )));
  }

  Widget getIconImage(path) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 0.0, 10.0, 0.0),
      child:
          Image.asset(path, width: IMAGE_ICON_WIDTH, height: IMAGE_ICON_WIDTH),
    );
  }

  renderRow(i) {
    if (i == 0) {
      return _topHead();
    }
    String texti = '';
    switch (i) {
      case 5:
        texti = _usermoney;
        break;
      case 6:
        texti = _chileds;
        break;
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
                Text(texti),
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

  Widget _topHead() {
    return Container(
      color: GlobalConfig.mainColor, //new Color.fromARGB(255, 0, 215, 198),
      height: 200.0,
      child: new Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          InkWell(
            child: _userAvatar == null
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
                      border: null,
                    ),
                  ),
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ImageCropperPage(),
                  ))
                  .then((r) async {
                  await DataUtils.freshUserinfo(context);
                  setState(() {
                    initinfo();
                  });

              });
            },
          ),
          Container(
            margin: EdgeInsets.fromLTRB(0.0, 5.0, 0.0, 0.0),
            child: Text(
              (_userName ?? _userPhone) + "[$_userlevelname]",
              style: new TextStyle(color: Colors.white, fontSize: 16.0),
            ),
          ),
          Container(
            margin: EdgeInsets.fromLTRB(0.0, 5.0, 0.0, 0.0),
            child: Text(
              "余额：$_usermoney 元",
              style: new TextStyle(color: Colors.white70, fontSize: 14.0),
            ),
          ),
        ],
      )),
    );
  }

  _handleListItemClick(int index) {
    switch (index) {
      case 1:
        Application.router.navigateTo(context, "/cardadmin");
        break;
      case 2:
        Application.router.navigateTo(context, "/order");
        break;
      case 3:
        Application.router.navigateTo(context, "/paylog");
        break;
      case 4:
        Application.run(context, "/web",
            url: "${GlobalConfig.webbase}/WebPay/vip2pay/app/1/token/",
            title: '权益升级');

        break;
      case 5:
        Application.run(context, "/web",
            url: "${GlobalConfig.webbase}/CreditCard/shareProfit/app/1/token/",
            title: '我的收益');

        break;
      case 6:
        Application.run(context, "/web",
            url: "${GlobalConfig.webbase}/Index/myshareuser/app/1/token/",
            title: '我的团队');
        break;
      case 7:
        Application.router.navigateTo(context, "/share");
        break;
      case 8:
        Application.run(context, "/web",
            url: "${GlobalConfig.base}/Public/helpText",
            title: '联系我们',
            withToken: false);
        break;
      case 9:
        DialogUtils.close2Logout(context, cancel: true);
        break;
    }
  }

  initinfo() {
    final model = globleModel().of(context);
    _token = model.token;
    if (_token == '') {
      DialogUtils.close2Logout(context);
    } else {
      _userName = model.userinfo.name;
      _userAvatar = model.userinfo.avtar;
      _userPhone = model.userinfo.phone;
      _userlevel = model.userinfo.level;
      _userlevelname = model.userinfo.levelname;
      _usermoney = model.userinfo.money;
      _chileds = model.userinfo.childs;
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initinfo();
  }
}
