import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../model/oder_model.dart';
import '../utils/HttpUtils.dart';
import '../utils/DialogUtils.dart';
import 'orderPlanLog.dart';

class orderDetail extends StatefulWidget {
  final OrderCell order;
  orderDetail(this.order);

  @override
  orderDetailState createState() => new orderDetailState();
}

class orderDetailState extends State<orderDetail> {
  String _statu;
  void stopPlan() async {
    print(widget.order);
    if (_statu == "进行中") {
      Map<String, String> params = {
        "orderId": widget.order.id,
      };
      await HttpUtils.apipost(context, 'Order/orderCancle', params, (response) async{
        print('=================setDefaultcard======================');
        print(response);
        if (response['error_code'] == '1') {
          setState(() {
            _statu = "已取消";
          });
        }
        await DialogUtils.showToastDialog(context,response['message']);

      });
  /*    if(_statu == '已取消')
        Navigator.of(context).pop('1');*/
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('计划任务信息'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
        onPressed: () {
          Navigator.of(context).pop(_statu == '已取消' ? '1':'0');
        }),
        actions: <Widget>[
          FlatButton(
              child: Text('详细'),
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => orderPlanLogPage(widget.order.id),
                    ));

/*//                  销毁当前页面
                  Navigator.pushAndRemoveUntil(context,new MaterialPageRoute(builder: (BuildContext context) {
                    return orderPlanLogPage(order.id); }), (route) => route == null);*/
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
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
//                    电影名称
                    Text(
                      "订单:${widget.order.orderNo} ${ _statu == '已取消'?'已取消':widget.order.status}",
                      style: TextStyle(
                        fontSize: 16.0,
                      ),
                      maxLines: 1,
                    ),
                    Divider(),
                    Text(
                      '任务金额：${widget.order.orderMoney}',
                      style: TextStyle(fontSize: 16.0),
                    ),
//                    类型
                    Text("保证金：${widget.order.orderBond}"),
//                    导演
                    Text('手续费：${widget.order.orderCharge}'),
                    Text('创建时间：${widget.order.create_time}'),
                    const SizedBox(height: 20.0),
                    Divider(),
                    _statu == "进行中"
                        ? Container(
                            alignment: Alignment.bottomCenter,
                            child: CupertinoButton(
                              child: Text("终止计划"),
                              onPressed: () {
                                stopPlan();
                              },
                              color: Colors.blue,
                              disabledColor: Colors.grey,
                              padding: EdgeInsets.all(10),
                              minSize: 50,
                              pressedOpacity: 0.8,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(8.0)),
                            ),
                          )
                        : Container(),
                  ]))),
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _statu = widget.order.status;
  }
}

class orderDetail11 extends StatelessWidget {
  final OrderCell order;
  orderDetail11(this.order);

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('计划任务信息'),
        actions: <Widget>[
          FlatButton(
              child: Text('详细'),
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => orderPlanLogPage(order.id),
                    ));

/*//                  销毁当前页面
                  Navigator.pushAndRemoveUntil(context,new MaterialPageRoute(builder: (BuildContext context) {
                    return orderPlanLogPage(order.id); }), (route) => route == null);*/
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
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                    const SizedBox(height: 20.0),
                    Divider(),
                    Container(
                      alignment: Alignment.bottomCenter,
                      child: CupertinoButton(
                        child: Text(order.status == "进行中"
                            ? "终止计划"
                            : (order.status == "已取消" ? "恢复计划" : "")),
                        onPressed: () {
                          ;
                        },
                        color: Colors.blue,
                        disabledColor: Colors.grey,
                        padding: EdgeInsets.all(10),
                        minSize: 50,
                        pressedOpacity: 0.8,
                        borderRadius: BorderRadius.all(Radius.circular(8.0)),
                      ),
                    ),
                  ]))),
    );
  }
}
