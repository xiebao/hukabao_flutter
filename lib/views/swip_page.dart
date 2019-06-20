import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import '../routers/application.dart';
import '../model/index_model.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../components/loading_gif.dart';


class RectSwiperPaginationBuilder extends SwiperPlugin {
  ///color when current index,if set null , will be Theme.of(context).primaryColor
  final Color activeColor;

  ///,if set null , will be Theme.of(context).scaffoldBackgroundColor
  final Color color;

  ///Size of the rect when activate
  final Size activeSize;

  ///Size of the rect
  final Size size;

  /// Space between rects
  final double space;

  final Key key;

  const RectSwiperPaginationBuilder(
      {this.activeColor,
        this.color,
        this.key,
        this.size: const Size(10.0, 2.0),
        this.activeSize: const Size(10.0, 2.0),
        this.space: 3.0});

  @override
  Widget build(BuildContext context, SwiperPluginConfig config) {
    List<Widget> list = [];

    int itemCount = config.itemCount;
    int activeIndex = config.activeIndex;

    for (int i = 0; i < itemCount; ++i) {
      bool active = i == activeIndex;
      Size size = active ? this.activeSize : this.size;
      list.add(Container(
        width: size.width,
        height: size.height,
        color: active ? activeColor : color,
        key: Key("pagination_$i"),
        margin: EdgeInsets.all(space),
      ));
    }

    return new Row(
      key: key,
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: list,
    );
  }
}

class SwipPage extends StatelessWidget {
  final List<PicsCell> picList;
  final double nheight;
  SwipPage(this.picList,{this.nheight=0.0});

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height =this.nheight==0.0 ? 210.0:this.nheight;
    return Container(
      width: width,
      height: height,
      child: this.picList == null || this.picList == []
          ? Text('没有显示的')
          : Swiper(
        itemBuilder: (BuildContext context, index) {
          return  CachedNetworkImage(
            placeholder: (context, url) => Loading(color: Colors.deepOrange,),
            imageUrl:  this.picList[index].imgurl,
            height: height,
            width: width,
            fit: BoxFit.fill,
          );
        },
        itemCount: this.picList.length,
        //viewportFraction: 0.9,
        pagination: new SwiperPagination(
            alignment: Alignment.bottomRight,
            builder: RectSwiperPaginationBuilder(
                color: Color(0xFF999999),
                activeColor: Colors.white,
                size: Size(5.0, 2),
                activeSize: Size(5, 5))),
        scrollDirection: Axis.horizontal,
        autoplay: true,
        onTap: (index) {
          if (this.picList[index].url.isNotEmpty) {
            Application.run(context, "/web",
                url: this.picList[index].url,
                title: this.picList[index].title ?? '护卡宝');
          }
        },
      ),
    );
  }
}


class SwipPageold extends StatelessWidget {
  List<PicsCell> picList;
  SwipPageold(List<PicsCell> picst) {
    this.picList = picst;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(0),
      width: MediaQuery.of(context).size.width,
//        color: Colors.blue,
      height: 210,
      child: picList == null || picList == []
          ? Text('没有显示的')
          : Swiper(
              itemCount: picList.length,
              itemBuilder: (BuildContext context, int index) {
                return CachedNetworkImage(
                  placeholder: (context, url) => SizedBox(
                        width: 50.0,
                        height: 50.0,
                        child: CircularProgressIndicator(
                          backgroundColor: Color(0xffff0000),
                        ),
                      ), // new Text('欢迎来到护卡宝'),
                  imageUrl: picList[index].imgurl,
                  width: MediaQuery.of(context).size.width,
                  height: 200,
                  fit: BoxFit.fill,
                );
              },
              pagination: SwiperPagination(
                  alignment: Alignment.bottomCenter,
                  margin: const EdgeInsets.fromLTRB(0, 0, 10, 10),
                  builder: DotSwiperPaginationBuilder(
                      color: Colors.black54, activeColor: Colors.white)),
              scrollDirection: Axis.horizontal,
              autoplay: true,
              onTap: (index) {
                if (picList[index].url.isNotEmpty) {
                  Application.run(context, "/web",
                      url: picList[index].url,
                      title: picList[index].title ?? '护卡宝');
                }
              },
            ),
    );
  }
}
