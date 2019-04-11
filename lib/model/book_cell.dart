
class Page {
  Page({this.label});
  final String label;
  String get id => label[0];
  @override
  String toString() => '$runtimeType("$label")';
}

class BookCell {
  String id;
  String name;
  String cardName; //"中国建设银行"
  String idCardNo; //640221197608265714
  String cardNo; //***************2584
  String cardType; //
  String certType;
  String phoneNo; //
  String bankCode; //1051000
  String bankAbbr; //
  String cardIcon; //http://app.hukabao.com/
  String bankBill; //
  String bankRepayDate; //
  String dfault; //
  String planBanged; //
  String planChannel; //
  String singleQuota; //
  String dayQuota; //

  BookCell(
      {this.id,
      this.name,
      this.cardName,
      this.idCardNo,
      this.cardNo,
      this.cardType,
      this.certType,
      this.phoneNo,
      this.bankCode,
      this.bankAbbr,
      this.cardIcon,
      this.bankBill,
      this.bankRepayDate,
      this.planBanged,
      this.planChannel,
        this.singleQuota,
        this.dayQuota,
      this.dfault});

  factory BookCell.fromJson(Map<String, dynamic> json) {
    return BookCell(
        id: json['id']??'',
        name: json['name']??'',
        cardName: json['cardName']??'',
        idCardNo: json['idCardNo']??'',
        cardNo: json['cardNo']??'',
        cardType: json['cardType']??'1',
        certType: json['certType']??'1',
        phoneNo: json['phoneNo']??'',
        bankCode: json['bankCode']??'',
        bankAbbr: json['bankAbbr']??'',
        cardIcon: json['bankAbbr'].toString().toLowerCase() ?? '',
        planBanged: json['payNoBangd'].toString()??"1",
        planChannel: json['channel'].toString()??"1",
        bankBill: json['bankBill']??'',
        bankRepayDate: json['bankRepayDate']??'',
        dayQuota: json['day_quota'].toString()??"未知",
        singleQuota: json['single_quota'].toString()??"未知",
        dfault: json['default']??'0');
  }

}
