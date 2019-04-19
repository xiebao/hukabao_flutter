import 'dart:core';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import '../components/bankCardBuider.dart';
import '../model/book_cell.dart';
import '../model/planReview_model.dart';
import '../utils/HttpUtils.dart';
import '../utils/DialogUtils.dart';
import '../utils/comUtil.dart';
import 'planReview.dart';
import '../globleConfig.dart';

class planPage extends StatefulWidget {
  @override
  planPageState createState() => new planPageState();
}

class planPageState extends State<planPage> {
  GlobalKey<FormState> _formKey = new GlobalKey<FormState>();

  TextEditingController _amountCtroller = new TextEditingController();
  TextEditingController _startDayCtroller = new TextEditingController();
  TextEditingController _endDayCtroller = new TextEditingController();
  TextEditingController _bandCtroller = new TextEditingController();

  bool _isRequesting = false;
  List<BookCell> _cardsList = [];
  int _indexcard = 0;
  String _curCardId;
  String _orderNo, _smsSeq;
  List<PlanViewCell> _planViewList = List();
  bool _isplanreg = false;

  TextEditingController _regCodeCtrl = TextEditingController();
  bool _regclk = false;

  void _dataInit() async {
    if (_isRequesting) return;
    HttpUtils.apipost(context, 'Index/cardListIndex', {}, (response) {
      print('=========cardLists=========');
      setState(() {
        response['data']['cardList'].forEach((ele) {
          if (ele.isNotEmpty) {
            print(ele);
            _isRequesting = true;
            if (ele['cardType'] == '2') _cardsList.add(BookCell.fromJson(ele));
          }
        });
      });
    });
  }

  @override
  void initState() {
    super.initState();
    _dataInit();
  }

  // 加载进度条
  Container loadingDialog;
  // 显示加载进度条
  showLoadingDialog() {
    setState(() {
      loadingDialog = new Container(
          constraints: BoxConstraints.expand(),
          color: Color(0x80000000),
          child: new Center(
            child: new CircularProgressIndicator(),
          ));
    });
  }

  // 隐藏加载进度条
  hideLoadingDialog() {
    setState(() {
      loadingDialog = new Container();
    });
  }

  void _submitPlan() async {
    if (_isRequesting)
      _curCardId = _cardsList[_indexcard].id;
    else
      return;

    if (_curCardId.isEmpty) {
      DialogUtils.showToastDialog(context, "请选择卡片");
      return;
    }

    _isplanreg = true;

    if (_cardsList[_indexcard].planBanged != '1') {
      await DialogUtils()
          .showMyDialog(context, '卡片未激活注册计划，是否现在激活?')
          .then((rv) async {
        if (rv) {
          Map<String, String> params = {
            "cardId": _curCardId,
          };

          await HttpUtils.apipost(context, "Index/extcardAddFirst", params,
              (response) async {
            await DialogUtils.showToastDialog(context, response['message']);
            if (response['error_code'] == '1') {
              _orderNo = response['data']['orderNo'];
              _smsSeq = response['data']['smsSeq'];

              await showCardRegDialog().then((v) async {
                if (v != null && v != '') {
                  List<String> msg = v.split(",");
                  setState(() {
                    _isplanreg = (msg[0] == '1' ? true : false);
                  });
                }
              });
            }
          });
        }
      });
      if (_isplanreg) await _submit();
    } else
      await _submit();
  }

  void _submit() async {
    try {
      String billday = _cardsList[_indexcard].bankBill;
      String endpayday = _cardsList[_indexcard].bankRepayDate;

      DateTime nowTime = DateTime.now();
      DateTime time1 = DateTime.parse(_startDayCtroller.text.trim());
      DateTime time2 = DateTime.parse(_endDayCtroller.text.trim());
      print(_startDayCtroller.text);
      print(_endDayCtroller.text);

      DateTime nowtimeflg = DateTime.parse(
          "${nowTime.year.toString()}-${nowTime.month.toString().padLeft(2, '0')}-${nowTime.day.toString().padLeft(2, '0')}");
      if (time1.isBefore(nowtimeflg)) {
        await DialogUtils.showToastDialog(context, "开始日期至少从今天开始");
        return;
      }

      if (time1.isBefore(time2)) {
        Duration duration = time2.difference(time1);
        if (duration.inDays <= 2) {
          await DialogUtils.showToastDialog(context, "结束日期要在开始日期至少2日后");
          return;
        }
      } else {
        await DialogUtils.showToastDialog(context, "开始日期必须早于结束日期");
        return;
      }

      print(time2.difference(time1).inDays);

      DateTime billdaytimeflg = DateTime.now();
      if (nowTime.day < int.parse(billday))
        billdaytimeflg = DateTime.parse(
            "${nowTime.year.toString()}-${(nowTime.month - 1).toString().padLeft(2, '0')}-${billday.padLeft(2, '0')}");
      else
        billdaytimeflg = DateTime.parse(
            "${nowTime.year.toString()}-${nowTime.month.toString().padLeft(2, '0')}-${billday.padLeft(2, '0')}");

      if (time1.isBefore(billdaytimeflg)) {
        await DialogUtils.showToastDialog(context, "开始日期必须在账单日之后");
        return;
      }

      DateTime endpaydaytimeflg = DateTime.now();
      if (nowTime.day > int.parse(endpayday))
        endpaydaytimeflg = DateTime.parse(
            "${nowTime.year.toString()}-${(nowTime.month + 1).toString().padLeft(2, '0')}-${endpayday.padLeft(2, '0')}");
      else
        endpaydaytimeflg = DateTime.parse(
            "${nowTime.year.toString()}-${nowTime.month.toString().padLeft(2, '0')}-${endpayday.padLeft(2, '0')}");
      if (time1.isAfter(endpaydaytimeflg)) {
        await DialogUtils.showToastDialog(context, "结束日期必须在还款日之前");
        return;
      }
    } catch (e) {
      print(e.toString());
      await DialogUtils.showToastDialog(context, "日期格式错误");
      return;
    }

    final form = _formKey.currentState;
    if (form.validate()) {
      if (int.parse(_amountCtroller.text) < 500) {
        await DialogUtils.showToastDialog(context, "计划金额必须不少于500元");
        return;
      }
      if (int.parse(_bandCtroller.text) < 100) {
        await DialogUtils.showToastDialog(context, "保证金金额必须大于100元");
        return;
      }

      Map<String, String> params = {
        "cardId": _curCardId,
        "money": _amountCtroller.text.trim(),
        "startTime": _startDayCtroller.text.trim(),
        "endTime": _endDayCtroller.text.trim(),
        "reserved": _bandCtroller.text.trim(),
        "bondPer": "50"
      };
      print(params);
      try {
        showLoadingDialog();
        await HttpUtils.apipost(context, 'Order/planAddOther', params,
            (response) async {
//          print(response['data']['info']);
          hideLoadingDialog();
          if (response['error_code'] != "-1") {
            _planViewList = List();
            response['data']['planList'].forEach((ele) {
//              print("${ele['card_id']}|${ele['plan_money']}|${ele['plan_bond']}|${ele['plan_time']}|${ele['plan_test']}");
              _planViewList.add(PlanViewCell.fromJson(ele));
            });
            setState(() {
              _isplanreg = false;
            });

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => planReviewPage(
                    _planViewList,
                    PlanCell(
                      cardNo: response['data']['info']['card'].toString(),
                      planinfo: response['data']['info']['title'].toString(),
                      planID: response['data']['planId'].toString(),
                    )),
              ),
            );
          } else
            await DialogUtils.showToastDialog(context, response['message']);
        });
      } catch (e) {
        print(e);
        await DialogUtils.showToastDialog(context, '网络连接错误');
      }
    }
  }

  void _itemselected(int index) {
    print('第$index');
    print(_cardsList[index].cardName);
    setState(() {
      _indexcard = index;
      _curCardId = _cardsList[index].id;
      _amountCtroller.text = '';
      _bandCtroller.text = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("计划管理"),
        ),
        body: Center(
          child: _cardsList.isEmpty
              ? Text("没有发现卡片")
              : new ListView(
                  children: <Widget>[
                    new Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(
                          Radius.circular(10.0),
                        ),
                      ),
                      padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
                      width: MediaQuery.of(context).size.width,
                      height: 220,
                      child: Swiper(
//                      controller: _swiperController,
                        itemBuilder: (BuildContext context, int index) {
                          return CardDataItem(
                              page: Page(label: '信用卡'),
                              data: _cardsList[index]);
                        },
                        itemCount: _cardsList.length, // _picList.length,
                        scale: 0.5,
//                      layout:SwiperLayout.STACK,
//                      pagination: new SwiperPagination(),
                        pagination: SwiperPagination(
                            alignment: Alignment.bottomCenter,
                            margin: const EdgeInsets.fromLTRB(0, 0, 10, 10),
                            builder: DotSwiperPaginationBuilder(
                                color: Colors.white,
                                activeColor: Colors.black54)),

                        onTap: _itemselected,
                        onIndexChanged: _itemselected,
                      ),
                    ),
                    new Container(
                      padding: new EdgeInsets.all(20.0),
                      child: SafeArea(
                        child: Form(
                            //绑定状态属性
                            key: _formKey,
                            autovalidate: true,
                            child: SingleChildScrollView(
                                padding: const EdgeInsets.all(5.0),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    _buildAmountText(),
                                    const SizedBox(height: 5.0),
                                    _buildBandText(),
                                    const SizedBox(height: 5.0),
                                    _buidPlanDaysRow(),
                                    const SizedBox(height: 30.0),
                                    Container(
                                      width: 300.0,
                                      child: FlatButton(
                                        disabledColor: Colors.grey,
                                        color: GlobalConfig.mainColor,
                                        child: Padding(
                                          padding: EdgeInsets.all(10.0),
                                          child: Text(
                                            '计划预览',
                                            style: new TextStyle(
                                                color: Colors.white,
                                                fontSize: 16.0),
                                          ),
                                        ),
                                        onPressed:
                                            _isplanreg ? _submitPlan : null,
                                      ),
                                    ),
                                  ],
                                ))),
                      ),
                    ),
                  ],
                ),
        ));
  }

  Widget _buildAmountText() {
    return ComFunUtil().buideStandInput(context, '目标金额', _amountCtroller,
        iType: 'number', maxlen: 6, showPlaceholder: false, valfun: (value) {
      if (value.isEmpty || value.trim().length < 3 || value.trim().length > 7) {
        return '';
      }
    }, changfun: (_) {
      setState(() {
        _isplanreg = true;
      });
    });
  }

  Widget _buildBandText() {
    return ComFunUtil().buideStandInput(context, '预留额度', _bandCtroller,
        iType: 'number', maxlen: 5, showPlaceholder: false, valfun: (value) {
      if (value.isEmpty || value.trim().length < 3 || value.trim().length > 5) {
        return '';
      }
    }, changfun: (_) {
      setState(() {
        _isplanreg = true;
      });
    });
  }

  Widget _buidPlanDaysRow() {
    return new Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 5.0, 0.0, 0.0),
      child: new Row(
        children: <Widget>[
          Expanded(
            flex: 9,
            child: _buildStartDayText(),
          ),
          Expanded(
            flex: 1,
            child: SizedBox(
              width: 10.0,
            ), //Text('至')
          ),
          Expanded(
            flex: 9,
            child: _buildEndDayText(),
          ),
        ],
      ),
    );
  }

  Widget _buildStartDayText() {
    return InkWell(
      onTap: () {
        ComFunUtil.showDatePicker(context, (String data) {
          _startDayCtroller.text = data;
          setState(() {
            _isplanreg = true;
          });
        });
      },
      child: ComFunUtil().buideStandInput(
        context,
        '开始日',
        _startDayCtroller,
        showPlaceholder: false,
        valfun: (value) {
          if (value.isEmpty) {
            return '';
          }
        },
        tapfun: true,
      ),
    );
  }

  Widget _buildEndDayText() {
    return InkWell(
      onTap: () {
        ComFunUtil.showDatePicker(context, (date) {
          _endDayCtroller.text = date;
          setState(() {
            _isplanreg = true;
          });
        });
      },
      child: ComFunUtil().buideStandInput(
        context,
        '结束日',
        _endDayCtroller,
        showPlaceholder: false,
        valfun: (value) {
          if (value.isEmpty) {
            return '';
          }
        },
        tapfun: true,
      ),
    );
  }

  Future<String> showCardRegDialog() {
    return showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => new AlertDialog(
                    title: new Text("计划卡片激活注册"),
                    contentPadding: EdgeInsets.all(10.0),
                    content: Container(
                      height: 30,
                      child: Column(
                        children: <Widget>[
                          Text('激活码'),
                          TextField(
                            controller: _regCodeCtrl,
                            cursorColor: GlobalConfig.mainColor,
                            maxLength: 6,
                            keyboardType: TextInputType.phone,
                            decoration: new InputDecoration(
                              hintText: '请输入激活码',
                              contentPadding: EdgeInsets.all(10.0),
                            ),
                          )
                        ],
                      ),
                    ),
                    actions: <Widget>[
                      new FlatButton(
                        child: new Text("取消"),
                        onPressed: () {
                          Navigator.of(context).pop('');
                        },
                      ),
                      new FlatButton(
                          child: _regclk == true ? Text('验证中…') : Text("确定"),
                          onPressed: cardreg)
                    ])) ??
        '';
  }

  void cardreg() async {
    if (_regCodeCtrl.text != '') {
      Map<String, String> params = {
        "cardId": _curCardId,
        "orderNo": _orderNo,
        "smsSeq": _smsSeq,
        "phoneCode": _regCodeCtrl.text.trim()
      };
      setState(() {
        _regclk = true;
      });

      await HttpUtils.apipost(context, "Index/extcardAdd", params, (response) async{
        await DialogUtils.showToastDialog(context,response['message']);
        Navigator.of(context)
            .pop("${response['error_code']},${response['message']}");
      });
    }
  }
}
