class PlanCell {
  String id;
  String orderNo;
  String orderName;
  String orderMoney;
  String orderBond; //保证金
  String orderTime;
  String status; //状态,订单状态状态,0=未执行,1=入账,2=消费,3入账成功，4消费成功

  PlanCell({
    this.id,
    this.orderNo,
    this.orderMoney,
    this.orderName,
    this.orderBond,
    this.orderTime,
    this.status,
  });

  factory PlanCell.fromJson(Map<String, dynamic> json) {

    var statlist={'0':'未执行','1':'计划入账（+）','2':'计划消费（-）','3':'已入账(+)成功','4':'已消费(-)成功'};

    return PlanCell(
      id: json['id'] ?? '',
      orderNo: json['cardNo'] ?? '',
      orderMoney: json['planMoney'] ?? '',
      orderName: json['cardNo'] ?? '',
      orderBond: json['planBond'] ?? '',
      orderTime: json['planTime'] ?? '',
      status:statlist[json['status']]??'异常',
    );
  }
}
