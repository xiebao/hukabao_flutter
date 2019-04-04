import 'package:flutter/material.dart';
import 'dart:core';
import 'package:flutter_swiper/flutter_swiper.dart';
import '../components/wxshare.dart';
import '../utils/comUtil.dart';
import '../utils/HttpUtils.dart';
import '../model/index_model.dart';
import '../model/globle_model.dart';
import '../globleConfig.dart';
import 'package:fluwx/fluwx.dart' as fluwx;

class sharePage extends StatefulWidget {
  @override
  sharePageState createState() => new sharePageState();
}

class sharePageState extends State<sharePage> {
  int _curindex = 0;
  int _defindex = 0;
  List<PicsCell> _picList = List();
  bool _isRequesting = false;
  String _userid, _userName;

  void _initPicList() async {
//    if (_isRequesting) return;
    final model = globleModel().of(context);
    _userid = model.userinfo.id;
    _userName = model.userinfo.name;

    HttpUtils.request('Share/getWxShareImgs', data: {}, method: 'post')
        .then((response) {
      print("----------------Share/getWxShareImgs--------------------");
      print(response['data']);
      print(response);

      print(response['index'] ?? '0'); // response['index']是动态变量 --当前默认的序号
//      _defindex=int.parse(response['index'].toString()??'1') ?? 0;//======bug?????????????????
      PicsCell dd;
      response['data'].forEach((ele) {
        print(ele['imgurl']);
        dd = PicsCell(imgurl: ele['imgurl']);
        _picList.add(dd);
      });
//        _isRequesting = true;
      setState(() {});
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
//                  img: 'http://app.hukabao.com/Uploads/App/2019-01-15/5c3db0b171cf5.jpg',
//                  String img_url = "${GlobalConfig.webbase}CreditCard/myqrCode/token/";
                  img: _picList[_curindex].imgurl,
                  url:
                      'http://app.hukabao.com/index.php/Api/Public/Share?fromtoken=$_userid',
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
    if (_picList == null || _picList == [])
      Text('没有发现分享图片');
    else {
      _picList.length == 1
          ? Image.network(
              _picList[0].imgurl,
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
              index: _defindex,
              outer: false,
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
  }

  @override
  void initState() {
    super.initState();
    _initPicList();
    fluwx.responseFromShare.listen((data) {
      print(data);
      print("微信分享回调:${data.errCode.toString()}");
//      setState(() { });
    });
  }

  // TODO: implement initState
}
