import 'package:flutter/material.dart';

import 'package:flutter_swiper/flutter_swiper.dart';
import '../components/wxshare.dart';
import '../utils/comUtil.dart';
import '../utils/HttpUtils.dart';
import '../model/index_model.dart';
import '../globleConfig.dart';
import 'package:fluwx/fluwx.dart' as fluwx;

class sharePage extends StatefulWidget {
  @override
  sharePageState createState() => new sharePageState();
}

class sharePageState extends State<sharePage> {
  int _curindex=0;
  List<PicsCell> _picList = List();
  bool _isRequesting=false;

  void _initPicList() async {
    if (_isRequesting) return;
    HttpUtils.request('Public/getWxShareImgs', data: {}, method: 'post')
        .then((response) {
      print("----------------Public/getWxShareImgs--------------------");
      print(response['data']);
      PicsCell dd;
      setState(() {
        response['data'].forEach((ele) {
          print(ele['imgurl']);
          dd = PicsCell(imgurl: ele['imgurl']);
          _picList.add(dd);
        });
        _isRequesting = true;
        print(_picList.length);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('分享'),
        actions: <Widget>[
          // 非隐藏的菜单
          IconButton(
            icon: Icon(Icons.share),
            tooltip: '分享',
            onPressed: () {
              ComFunUtil().showSnackDialog(
                context: context,
                child: wxShareDialog(
                  title: Text('微信分享'),
                  content: Text('微信分享详细'),
                  img: 'http://app.hukabao.com/Uploads/App/2019-01-15/5c3db0b171cf5.jpg',
                  //img: _picList[_curindex].imgurl,
                  url: 'http://sz.hukabao.com',
                ),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Container(child: _initSwiper()),
      ),
    );
  }

  Widget _initSwiper() {
    return  Image.network(
      'http://app.hukabao.com/Uploads/App/2019-01-15/5c3db0b171cf5.jpg',
      fit: BoxFit.fill,
    );
    return _picList == null || _picList == []
        ?
    Image.network(
      'http://app.hukabao.com/Uploads/App/2019-01-15/5c3db0b171cf5.jpg',
      fit: BoxFit.fill,
    )
        : Swiper(
            scrollDirection: Axis.horizontal,
            itemBuilder: (BuildContext context, int index) {
              return Image.network(
                _picList[index].imgurl,
                fit: BoxFit.fill,
              );
            },
            itemCount: _picList.length,
            scale: 0.8,
            index: 2,/*
      duration: 9000,
//        loop: false,
      autoplayDelay:90000,*/
      outer:false,
      autoplay: false,
            onIndexChanged: (index) {
              _curindex = index;
              print(_curindex);
            },
            pagination: SwiperPagination(
                alignment: Alignment.bottomCenter,
                margin: const EdgeInsets.fromLTRB(0, 0, 10, 10),
                builder: DotSwiperPaginationBuilder(
                    color: Colors.black54, activeColor: Colors.white)),
//            onTap: (index) {},
          );
  }
/*
  _initFluwx() async{
    await fluwx.register(appId: GlobalConfig.wxAppId, doOnAndroid: true, doOnIOS: true, enableMTA: false);
    var result = await fluwx.isWeChatInstalled();
    print("is installed $result");
  }*/

  @override
  void initState() {
    super.initState();
    _initPicList();
//    _initFluwx(); //homapage页统一初始化了
    fluwx.responseFromShare.listen((data) {
      print(data);
      setState(() {
        print( "微信分享回调${data.errCode.toString()}");
      });
    });

  }

  // TODO: implement initState
}
