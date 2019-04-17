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
    return Center(
      child: Container(
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
        width: MediaQuery.of(context).size.width,
        height: 210,
        child: picList == null || picList == []
            ? Text('没有显示的')
            : Swiper(
                itemBuilder: (BuildContext context, int index) {
                  return  CachedNetworkImage(
                    placeholder: (context, url) =>Text('欢迎来到护卡宝'),// new CircularProgressIndicator(),
                    imageUrl: picList[index].imgurl,
                  );
//                  return new Image.network(
//                    picList[index].imgurl,
//                    fit: BoxFit.fitWidth,
//                    width: MediaQuery.of(context).size.width,
//                  );
                },
                loop: false,
                itemCount: picList.length,
                scale: 0.8,
                pagination: SwiperPagination(
                    alignment: Alignment.bottomCenter,
                    margin: const EdgeInsets.fromLTRB(0, 0, 10, 10),
                    builder: DotSwiperPaginationBuilder(
                        color: Colors.black54, activeColor: Colors.white)),
                index: 0,
                autoplay: false,
                autoplayDisableOnInteraction: false,
                onTap: (index) {
                  if (picList[index].url.isNotEmpty) {
                    Application.run(context, "/web",url: picList[index].url,title:picList[index].title ?? '护卡宝');
                  }
                },
              ),
      ),
    );
  }
}
