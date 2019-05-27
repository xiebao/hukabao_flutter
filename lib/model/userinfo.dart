class Userinfo {
  String name;
  String id;
  String nickname;
  String avtar;
  String phone;
  String level;
  String money;
  String levelname;
  String childs;

  Userinfo({this.phone, this.id, this.name,this.nickname,this.avtar,this.level,this.levelname,this.money,this.childs});

  factory Userinfo.fromJson(Map<String, dynamic> json) {
    return Userinfo(
        phone: json['phone']??'',
        name: json['username']??'',
        id: json['id'],
        nickname: json['nickname']??'',
        avtar: json['avatar']??'',
        level: json['level']??'',
        money: json['money']??'0',
        childs:json['childs']==0?'0':json['childs'].toString(),
        levelname: json['levelname']??''
    );

  }
}
