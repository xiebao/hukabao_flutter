import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import '../routers/application.dart';
import '../model/index_model.dart';
import 'package:cached_network_image/cached_network_image.dart';

class SwipPage extends StatelessWidget {
  List<PicsCell> picList;
  SwipPage(List<PicsCell> picst) {
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
            :
        Swiper(
        itemCount: picList.length,
        itemBuilder: (BuildContext context, int index) {
          return InkWell(
            child:CachedNetworkImage(
              placeholder: (context, url) =>CircularProgressIndicator(),// new Text('欢迎来到护卡宝'),
              imageUrl: picList[index].imgurl,
              width:  MediaQuery.of(context).size.width,
              height: 200,
              fit: BoxFit.fill,
            ),
            onTap: () {
              if (picList[index].url.isNotEmpty) {
                Application.run(context, "/web",url: picList[index].url,title:picList[index].title ?? '护卡宝');
              }
            },
          );
        },
          pagination: SwiperPagination(
              alignment: Alignment.bottomCenter,
              margin: const EdgeInsets.fromLTRB(0, 0, 10, 10),
              builder: DotSwiperPaginationBuilder(
                  color: Colors.black54, activeColor: Colors.white)),

          outer: false,
          autoplay: true,
//          loop: false,
//          scale: 0.8,
//        autoplayDisableOnInteraction: false,
      ),

    );
  }
}
