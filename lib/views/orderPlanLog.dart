import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../utils/HttpUtils.dart';
import '../model/plan_model.dart';
import '../routers/application.dart';

class orderPlanLogPage extends StatefulWidget {
  final String oid;
  orderPlanLogPage(this.oid);

  @override
  planLogPageState createState() => new planLogPageState();
}

class planLogPageState extends State<orderPlanLogPage> {
  List<PlanCell> _payLogList = List();
  int _page = 1;
  bool loading = false;

  _loadData() async {
    if (loading) {
      return null;
    }
    loading = true;
    try {
    HttpUtils.apipost(context, 'Order/orderDetails/p/'+_page.toString(), {'orderId':widget.oid}, (response) {
      setState(() {
        print('=================Order/orderDetails======================');
        print(response);
        if (response['data']['orderDetails'].isNotEmpty) {
          if (_payLogList == null) {
            _payLogList =[];
          }
          response['data']['orderDetails'].forEach((ele) {
            if (ele.isNotEmpty) {
              print(ele);
              _payLogList.add(PlanCell.fromJson(ele));
            }
          });
        }
      });

      });
    } finally {
      loading = false;
    }


  }


  _getItem(PlanCell subject) {
    var row = Container(
      margin: EdgeInsets.all(4.0),
      child: Row(
        children: <Widget>[
          Expanded(
              child: Container(
                margin: EdgeInsets.only(top: 5.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
//                    电影名称
                    Text(
                      "卡号:${subject.orderNo}",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16.0,
                      ),
                      maxLines: 1,
                    ),
                    Divider(),
                    Text(
                      '交易金额：${subject.orderMoney}',
                      style: TextStyle(
                          fontSize: 16.0
                      ),
                    ),
//                    类型
                    Text(
                        "保证金：${subject.orderBond}"
                    ),
//
                    Text(
                        '操作时间：${subject.orderTime}'
                    ),
                    Text(
                        '结果：${subject.status}'
                    ),
                    const SizedBox(height: 5.0),
                  ],
                ),
              )
          )
        ],
      ),
    );
    return Card(
      child: row,
    );
  }

  _getBody() {
    var length = _payLogList.length;
    return  ListView.builder(
//        itemCount: _payLogList.length,
        itemBuilder: (BuildContext context, int index) {
          if (index == length) {
            return new Center(
              child: new Container(
                margin: const EdgeInsets.only(top: 8.0),
                height: 32.0,
                child: Text('--没有了--'),
              ),
            );
          } else if (index > length) {
            return null;
          }else{
            return _getItem(_payLogList[index]);
          }
        },
    );

  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('交易记录'),
      ),
      body: Center(
        child: _getBody(),
      ),
    );
  }
}