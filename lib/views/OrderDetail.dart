import 'package:flutter/material.dart';
import '../model/oder_model.dart';
import 'orderPlanLog.dart';

class orderDetail extends StatelessWidget {
  final OrderCell order;
  orderDetail(this.order);

  @override
  Widget build(BuildContext context) {
    Color _bticon = Colors.deepOrange;
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('计划任务信息'),
          actions: <Widget>[
            FlatButton(
                child: Text('详细'),
                onPressed: () {
//                  销毁当前页面
                  Navigator.pushAndRemoveUntil(context,new MaterialPageRoute(builder: (BuildContext context) {
                    return orderPlanLogPage(order.id); }), (route) => route == null);
//
//                  Navigator.push(
//                    context,
//                    MaterialPageRoute(
//                      builder: (context) => orderPlanLogPage(order.id),
//                    ),
//                  );
                })
          ],
      ),
      body: Center(
//        child:Text('这是的id=' + id + '信息'),
          child: new Container(
              decoration: new BoxDecoration(
                borderRadius:
                    const BorderRadius.all(const Radius.circular(1.0)),
              ),
              margin: const EdgeInsets.all(10.0),
              child:  Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
//                    电影名称
                    Text(
                      "订单:${order.orderNo} ${order.status}",
                      style: TextStyle(
                        fontSize: 16.0,
                      ),
                      maxLines: 1,
                    ),
                    Divider(),
                    Text(
                      '任务金额：${order.orderMoney}',
                      style: TextStyle(fontSize: 16.0),
                    ),
//                    类型
                    Text("保证金：${order.orderBond}"),
//                    导演
                    Text('手续费：${order.orderCharge}'),
                    Text('创建时间：${order.create_time}'),
                  ]))),
    );
  }
}
