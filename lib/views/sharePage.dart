import 'package:flutter/material.dart';
import 'dart:core';
import 'package:flutter_swiper/flutter_swiper.dart';
import '../components/wxshare.dart';
import '../utils/comUtil.dart';
import '../utils/HttpUtils.dart';
import '../utils/DialogUtils.dart';
import '../model/index_model.dart';
import '../model/globle_model.dart';
import 'package:fluwx/fluwx.dart' as fluwx;
import 'package:cached_network_image/cached_network_image.dart';

class sharePage extends StatefulWidget {
  @override
  sharePageState createState() => new sharePageState();
}

class sharePageState extends State<sharePage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  int _curindex = 0;
  int _defindex = 0;
  List<PicsCell> _picList = List();
  bool _isRequesting = false;
  String _userid, _userName;

  void _initPicList() async {
    if (_isRequesting) return;
    final model = globleModel().of(context);
    _userid = model.userinfo.id;
    _userName = model.userinfo.name;

    await HttpUtils.apipost(context, 'Share/getWxShareImgs', {}, (response) {
      print("----------------Share/getWxShareImgs--------------------");
      print(response['data']);
      if (response['data'].isNotEmpty) {
//        setState(() {
//          _defindex = response['index'].toInteger();
//        });
        PicsCell dd;
        response['data'].forEach((ele) {
          if (ele.isNotEmpty) {
            print(ele['imgurl']);
//            _picList.add(PicsCell.fromJson(ele));
            dd = PicsCell(imgurl: ele['imgurl']);
            _picList.add(dd);
          }
        });
      }
      setState(() {
        _isRequesting = true;
      });

    });
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
        child: Container(
            child: _isRequesting
                ? _initSwiper()
                :DialogUtils.uircularProgress()),
      ),
    );
  }

  Widget _initSwiper() {
    if (_picList == null || _picList == [])
      return Text('没有发现分享图片');
    else {
      return _picList.length == 1
          ? Image.network(
              _picList[0].imgurl,
              fit: BoxFit.fill,
            )
          : Swiper(
              scrollDirection: Axis.horizontal,
              itemBuilder: (BuildContext context, int index) {
//                return Image(image: new CachedNetworkImageProvider(_picList[index].imgurl));
                return  CachedNetworkImage(
                  placeholder: (context, url) => new CircularProgressIndicator(),
                  imageUrl: _picList[index].imgurl,
                );
              /*  return Image.network(
                  _picList[index].imgurl,
                  fit: BoxFit.fill,
                );*/
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
}
