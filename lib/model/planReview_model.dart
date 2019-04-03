class PlanCell {
  String cardNo;
  String planinfo;
  String planID;

  PlanCell({
    this.cardNo,
    this.planinfo,
    this.planID,
  });
}

class PlanViewCell {
  String cardNo;
  String planBond;
  String planMoney;
  String planTest;
  String planFee;
  String planTime;
  String status;

  PlanViewCell({
    this.cardNo,
    this.planMoney,
    this.planBond,
    this.planTest,
    this.planTime,
    this.planFee,
    this.status,
  });

  factory PlanViewCell.fromJson(Map<String, dynamic> json) {
//    print("~~~~~${json['plan_test']}~~~~");
    return PlanViewCell(
        cardNo: json['card_id'].toString(),
        planMoney: json['plan_money'].toString(),
        planBond: json['plan_bond'].toString(),
        planTest: json['plan_test'].toString(),
        planFee: json['plan_bond_per'].toString(),
        planTime: json['plan_time'].toString(),
        status: json['status'].toString());
  }
}
