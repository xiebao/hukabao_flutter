import 'book_cell.dart';

class MsgCell {
  String title;
  String id;
  String createtime;
  String content;
  String type;

  MsgCell({this.title, this.id, this.createtime, this.content, this.type});

  factory MsgCell.fromJson(Map<String, dynamic> json) {
    return MsgCell(
        title: json['title'] ?? '',
        createtime: json['create_time'] ?? '',
        id: json['id'] ?? '',
        content: json['content'] ?? '',
        type: json['type'] ?? '');
  }
}

class PicsCell {
  String title;
  String id;
  String imgurl;
  String url;
  String time;

  PicsCell({this.title, this.id, this.imgurl, this.url, this.time});

  factory PicsCell.fromJson(Map<String, dynamic> json) {
    return PicsCell(
      title: json['title'] ?? '',
      url: json['url'] ?? '',
      id: json['id'] ?? '',
      imgurl: json['image_url'] ?? '',
      time: json['create_time'] ?? '', // Util.getTimeDuration(json['create_time'])
    );
  }
}

class IndexCell {
  List<PicsCell> adList;
  List<BookCell> cardList;
  String cardStatus;
  String bond;
  String money;
  String message;

  IndexCell({
    this.adList,
    this.cardList,
    this.cardStatus,
    this.bond,
    this.money,
    this.message,
  });

  factory IndexCell.fromJson(Map<String, dynamic> json) {
    print('======================IndexCell.fromJson====================');
    print(json);
    List<PicsCell> pics;
    json['adList'].forEach((ele) {
//       print(ele);
      if (ele.isNotEmpty) {
        pics.add(PicsCell.fromJson(ele));
        print("----adList------");
      }
    });

    // pics = json['pictures'];_TypeError (type 'List<dynamic>' is not a subtype of type 'List<String>')
    List<BookCell> cardlist;
    json['cardList'].forEach((ele) {
      if (ele.isNotEmpty) {
        cardlist.add(BookCell.fromJson(ele));
      }
      print("----cardList------");
    });

    return IndexCell(
        adList: pics,
        cardList: cardlist,
        cardStatus: json['cardStatus'] ?? '',
        bond: json['bond'] ?? '',
        money: json['money'] ?? '',
        message: json['message'] ?? '');
  }
}
