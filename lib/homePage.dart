import 'package:flutter/services.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import './views/cardsManager.dart';
import './views/index_page.dart';
import './views/MyInfoPage.dart';
import './model/index_model.dart';
import './utils/HttpUtils.dart';

class homePage extends StatefulWidget {
  @override
  homePageState createState() => new homePageState();
}

class homePageState extends State<homePage>
    with  SingleTickerProviderStateMixin ,AutomaticKeepAliveClientMixin{
  AnimationController _controller;

  @override
  bool get wantKeepAlive => true;

  bool _login=true;
  // 默认索引第一个tab
  int _tabIndex = 0;

  // 正常情况的字体样式
  final tabTextStyleNormal = new TextStyle(color: const Color(0xff969696));

  // 选中情况的字体样式
  final tabTextStyleSelect = new TextStyle(color: const Color(0xff63ca6c));

  // 底部菜单栏图标数组
  var tabImages;

  // 页面内容
  var _pages;

  // 菜单文案
  var tabTitles = ['首页', '卡片', '我的'];

  // 生成image组件
  Image getTabImage(path) {
    return new Image.asset(path, width: 20.0, height: 20.0);
  }
  List<PicsCell> _picList = [];

  void _initPicList() async {
    await HttpUtils.apipost(context,'Index/cardIndex',{},(response) {
      print("----------------adList--------------------");

      PicsCell dd;
      print(response['data']['adList']);
      setState(() {
        response['data']['adList'].forEach((ele) {
          dd = PicsCell(
              imgurl: ele['image_url'], title: ele['title'], url: ele['url']);
          _picList.add(dd);
        });
      });
    });
  }

  void initData() {
    if (tabImages == null) {
      tabImages = [
        [
          getTabImage('images/sysicon/icon_home_n.png'),
          getTabImage('images/sysicon/icon_home_s.png')
        ],
        [
          getTabImage('images/sysicon/icon_card_n.png'),
          getTabImage('images/sysicon/icon_card_s.png')
        ],
        [

          getTabImage('images/sysicon/icon_my_n.png'),
          getTabImage('images/sysicon/icon_my_s.png')
        ]
      ];
    }

    _pages = [
      IndexPage(_picList), cardLists(true), MyInfoPage(),
    ];
  }
    //获取菜单栏字体样式
    TextStyle getTabTextStyle (int curIndex) {
      if (curIndex == _tabIndex) {
        return tabTextStyleSelect;
      } else {
        return tabTextStyleNormal;
      }
    }

    // 获取图标
    Image getTabIcon (int curIndex) {
      if (curIndex == _tabIndex) {
        return tabImages[curIndex][1];
      }
      return tabImages[curIndex][0];
    }

    // 获取标题文本
    Text getTabTitle (int curIndex) {
      return new Text(
        tabTitles[curIndex],
        style: getTabTextStyle(curIndex),
      );
    }

    // 获取BottomNavigationBarItem
    List<BottomNavigationBarItem> getBottomNavigationBarItem () {
      List<BottomNavigationBarItem> list = new List();
      for (int i = 0; i <3; i++) {
        list.add(new BottomNavigationBarItem(
            icon: getTabIcon(i), title: getTabTitle(i)));
      }
      return list;
    }

    @override
    Widget build (BuildContext context) {
      initData();
      return WillPopScope(
        onWillPop: _doubleExit,//(){return Future.value(_onWillPop());},
        child:_login?
        Scaffold(
          body:  IndexedStack(
            children: _pages,
            index: _tabIndex,
          ),
          bottomNavigationBar: new CupertinoTabBar(
            items: getBottomNavigationBarItem(),
            currentIndex: _tabIndex,
            onTap: (index) {
              setState(() {
                _tabIndex = index;
              });
            },
          ),
          ):Text('请退出登录')
      );
/*
      return new CupertinoApp(
        title: "护卡宝",
        theme: new CupertinoThemeData(
          primaryColor: CupertinoColors.darkBackgroundGray,
        ),
        routes: _routes,
        home: new CupertinoTabScaffold(
          tabBar: CupertinoTabBar(
            items: getBottomNavigationBarItem(),
            currentIndex: _tabIndex,
            onTap: (index) {
              setState(() {
                _tabIndex = index;
              });
            },
          ),
          tabBuilder: (BuildContext context, int index) {
            return CupertinoTabView(
              builder: (BuildContext context) {
                return CupertinoPageScaffold(
                  child: _pages[index],
                  // navigationBar: CupertinoNavigationBar(
                  //   middle: Text(tabTitles[index]),
                  //   trailing: _trailingButtons[index],
                  // ),
                );
              },
            );
          },
        ),
      );*/
    }


  Future<bool> _onWillPop() {
    return showDialog(
      context: context,
      builder: (context) => new AlertDialog(
        title: new Text('您确定要退出吗?'),
        content: new Text('确定将退出app'),
        actions: <Widget>[
          new FlatButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: new Text('取消'),
          ),
          new FlatButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: new Text('确定'),
          ),
        ],
      ),
    ) ?? false;
  }

  int _lastClickTime = 0;
  Future<bool> _doubleExit() async{
    int nowTime = new DateTime.now().microsecondsSinceEpoch;
    if (_lastClickTime != 0 && nowTime - _lastClickTime > 1500) {
      return await _onWillPop().then((rv){
         rv ? _exitApp():  new Future.value(false);
      });
      return new Future.value(true);
    } else {
      _lastClickTime = new DateTime.now().microsecondsSinceEpoch;
      new Future.delayed(const Duration(milliseconds: 1500), () {
        _lastClickTime = 0;
      });
      return await _onWillPop().then((rv){
         rv ? _exitApp():  new Future.value(false);
      });
      return new Future.value(true);
    }
  }


  static Future<void> _exitApp() async {
    await SystemChannels.platform.invokeMethod('SystemNavigator.pop');
  }


  @override
  void initState() {
    _initPicList();
    super.initState();
    _controller = new AnimationController( vsync: this, duration: const Duration(seconds: 3));
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }


}