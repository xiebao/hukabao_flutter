import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../utils/HttpUtils.dart';
import '../utils/DialogUtils.dart';
import '../model/planReview_model.dart';
import '../routers/application.dart';

class planReviewPage extends StatefulWidget {
  planReviewPage(this.planList, this.info);
  final List<PlanViewCell> planList;
  final PlanCell info;
  @override
  planReviewPageState createState() => new planReviewPageState();
}

class planReviewPageState extends State<planReviewPage> {
  bool loading = false;

  _getItem(PlanViewCell subject) {
    var row = Container(
      margin: EdgeInsets.all(4.0),
      child: Row(
        children: <Widget>[
          Expanded(
              child: Container(
            margin: EdgeInsets.only(left: 8.0),
            height: 150.0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
//                    电影名称
                /*  Text(
                      "卡号:${subject.cardNo}",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20.0,
                      ),
                      maxLines: 1,
                    ),*/
//                    豆瓣评分
                Text(
                  '交易金额：${subject.planMoney}',
                  style: TextStyle(fontSize: 16.0),
                ),
//                    类型
                Text("保证金：${subject.planBond}"),
//
                Text('计划时间：${subject.planTime}'),
                Text('手续费：${subject.planFee}'),
              ],
            ),
          ))
        ],
      ),
    );
    return Card(
      child: row,
    );
  }

  _planConfirm() async {
    HttpUtils.apipost(
        context, 'Order/planConfirm', {'planId': widget.info.planID},
        (response) {
      print('=================planConfirm======================');
      DialogUtils.showToastDialog(context, text: response['message']);
      if (response['error_code'] != "-1") {
        Application.run(context, "/");
      }
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('计划预览'),
          leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                Application.run(context, "/");
              }),
          bottom: PreferredSize(
              child: Container(
                  height: 40,
                  width: double.infinity,
                  color: Colors.grey,
                  child: Text("  当前${widget.info.cardNo}  计划:${widget.info.planinfo}",
//                textAlign: TextAlign.center,
                style: new TextStyle(color: Colors.white, fontSize: 12.0),
                    maxLines: 2,
              )),
              preferredSize: Size(200, 45)),
          /* actions: <Widget>[
           InkWell(onTap: (){Application.run(context, "/");} ,child: Text("取消"),),
          IconButton(
            icon: Icon(Icons.delete),
            tooltip: "取消",
            onPressed: () {
              print("Alarm");
            },
          ),
          IconButton(
            icon: Icon(Icons.assignment_turned_in),
            tooltip: "确认",
            onPressed: () {
              print("Home");
            },
          ),

        ],*/
        ),
        body: Center(
          child: ListView.builder(
            itemCount: widget.planList.length,
            itemBuilder: (BuildContext context, int index) {
              return _getItem(widget.planList[index]);
            },
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          icon: Icon(Icons.done),
          label: Text("确认计划"),
          onPressed: _planConfirm,
        ));
  }
}
