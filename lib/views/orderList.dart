import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../utils/HttpUtils.dart';
import '../model/oder_model.dart';
import 'OrderDetail.dart';

class orderListPage extends StatefulWidget {
  @override
  orderListPageState createState() => new orderListPageState();
}

class orderListPageState extends State<orderListPage> {
  List<OrderCell> _payLogList = List();
  int _page = 1;
  bool loading = false;

  _loadData() async {
    if (loading) {
      return null;
    }
    loading = true;
    try {
    await HttpUtils.apipost(context, 'Order/orderList/p/'+_page.toString(), {}, (response) {
      setState(() {
        print(response);
        _page += 1;
        print(_page);
        if (response['data']['orderList'].isNotEmpty) {
          if (_payLogList == null) {
            _payLogList =[];
          }
          response['data']['orderList'].forEach((ele) {
            if (ele.isNotEmpty) {
              print(ele);
              _payLogList.add(OrderCell.fromJson(ele));
            }
          });
        }
      });

      });
    } finally {
      loading = false;
    }
  }

  _getItem(OrderCell subject)  {
    var row = InkWell(
      onTap:()async{
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>  orderDetail(subject),
          ),
        ).then((result) {
          if (result == '1') {
            setState(() {
              subject.status='已取消';
            });
          }
        });
        } ,
      child: Container(
        margin: EdgeInsets.all(4.0),
        child: Row(
          children: <Widget>[
            Expanded(
                child: Container(
                  margin: EdgeInsets.only(left: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        "订单:${subject.orderNo} ${subject.status}",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16.0,
                        ),
                        maxLines: 1,
                      ),
                    Divider(),
                      Text(
                        '任务金额：${subject.orderMoney}',
                        style: TextStyle(
                            fontSize: 16.0
                        ),
                      ),
//                    类型
                      Text(
                          "预留额度：${subject.orderBond}"
                      ),
//                    导演
                      Text(
                          '手续费：${subject.orderCharge}'
                      ),
                      Text(
                          '创建时间：${subject.createtime}'
                      ),
                      const SizedBox(height: 5.0),
                    ],
                  ),
                )
            )
          ],
        ),
      ),
    )
    ;
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
            _loadData();
            return new Center(
              child: new Container(
                margin: const EdgeInsets.only(top: 8.0),
                width: 32.0,
                height: 32.0,
                child: const CircularProgressIndicator(),
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
        title: Text('计划订单'),
      ),
      body: Center(
        child: _getBody(),
      ),
    );
  }
}