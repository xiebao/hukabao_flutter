class Userinfo {
  String name;
  String id;
  String nickname;
  String avtar;
  String phone;

  Userinfo({this.phone, this.id, this.name,this.nickname,this.avtar});

  factory Userinfo.fromJson(Map<String, dynamic> json) {
    return Userinfo(phone: json['phone']??'', name: json['username']??'', id: json['id'], nickname: json['nickname']??'', avtar: json['avatar']??'');
  }
}
