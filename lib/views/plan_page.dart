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
  final FocusNode _focusNode = FocusNode();

  TextEditingController _amountCtroller = new TextEditingController();
  TextEditingController _startDayCtroller = new TextEditingController();
  TextEditingController _endDayCtroller = new TextEditingController();
  TextEditingController _bandCtroller = new TextEditingController();

  bool _isRequesting = false;
  List<BookCell> _cardsList = [];
  int _indexcard = 0;
  String _curCardId;

  List<PlanViewCell> _planViewList = List();

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

    try {
      DateTime time1 = DateTime.parse(_startDayCtroller.text);
      DateTime time2 = DateTime.parse(_endDayCtroller.text);
      if (time1.isBefore(time2)) {
        Duration duration = time2.difference(time1);
        if (duration.inDays <= 2) {
          DialogUtils.showToastDialog(context, text: "结束日期要在开始日期至少2日后");
          return;
        }
      } else {
        DialogUtils.showToastDialog(context, text: "开始日期必须早于结束日期");
        return;
      }
    } catch (exception) {
      DialogUtils.showToastDialog(context, text: "日期格式异常");
      return;
    }

    if (_curCardId.isNotEmpty) {
      Map<String, String> params = {
        "cardId": _curCardId,
        "money": _amountCtroller.text,
        "startTime": _startDayCtroller.text,
        "endTime": _endDayCtroller.text,
        "reserved": _bandCtroller.text,
        "bondPer": "50"
      };
      print(params);
      try {
        showLoadingDialog();

//      return;
        HttpUtils.apipost(context, 'Order/planAddOther', params, (response) {
          print('=================Order/planAddOther======================');
//          print(response['data']['info']);
          if (response['error_code'] != "-1") {
            response['data']['planList'].forEach((ele) {
//              print("${ele['card_id']}|${ele['plan_money']}|${ele['plan_bond']}|${ele['plan_time']}|${ele['plan_test']}");
              _planViewList.add(PlanViewCell.fromJson(ele));
            });

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => planReviewPage(
                    _planViewList,
                    new PlanCell(
                      cardNo: response['data']['info']['card'].toString(),
                      planinfo: response['data']['info']['title'].toString(),
                      planID: response['data']['planId'].toString(),
                    )),
              ),
            );
          } else
            DialogUtils.showToastDialog(context, text: response['message']);
        });
      } catch (e) {
        print(e);
        DialogUtils.showToastDialog(context, text: '网络连接错误');
      } finally {
        hideLoadingDialog();
      }
    } else
      DialogUtils.showToastDialog(context, text: "请选择卡片");
  }

  void _itemselected(int index) {
    print('第$index');
    print(_cardsList[index].cardName);
    setState(() {
      _indexcard = index;
      _curCardId = _cardsList[index].id;
      _amountCtroller.text='';
      _bandCtroller.text='';

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
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 5.0),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    const SizedBox(height: 10.0),
//                                    _buildAmountText();
                                    Stack(
                                      alignment: new Alignment(1.0, 1.0),
                                      //statck
                                      children: <Widget>[
                                        new Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Padding(
                                                padding:
                                                    new EdgeInsets.fromLTRB(
                                                        5.0, 0.0, 5.0, 0.0),
                                                child: Text("目标金额:"),
                                              ),
                                              Expanded(
                                                child: new TextField(
                                                  textAlign: TextAlign.right,
                                                  controller: _amountCtroller,
                                                  cursorColor:
                                                      GlobalConfig.mainColor,
                                                  keyboardType:
                                                      TextInputType.number,
                                                  //光标切换到指定的输入框
                                                  onEditingComplete: () =>
                                                      FocusScope.of(context)
                                                          .requestFocus(
                                                              _focusNode),
                                                  textDirection: TextDirection.ltr,
                                                  decoration:
                                                      new InputDecoration(
                                                    hintText: '请输入计划金额',
                                                    contentPadding:
                                                        EdgeInsets.all(10.0),
                                                  ),
                                                ),
                                              ),
                                            ]),
                                      ],
                                    ),
                                    const SizedBox(height: 10.0),
                                    Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          new Expanded(
                                            child: new TextField(
                                              controller: _startDayCtroller,
                                              // 光标颜色
                                              cursorColor:
                                                  GlobalConfig.mainColor,
                                              style: TextStyle(fontSize: 14.0,),//输入文本的样式
                                              decoration: new InputDecoration(
                                                hintText: '开始时间',
                                                suffixIcon: new IconButton(
                                                  icon: new Icon(
                                                      Icons.calendar_today,
                                                      color: GlobalConfig
                                                          .mainColor),
                                                  onPressed: () {
                                                    ComFunUtil.showDatePicker(
                                                        context, (String data) {
                                                      _startDayCtroller.text =
                                                          data;
                                                    });
                                                  },
                                                ),
                                              ),
                                            ),
                                          ),
                                          new Padding(
                                              padding: new EdgeInsets.fromLTRB(
                                                  2.0, 0.0, 5.0, 0.0),
                                              child: Text("至")),
                                          new Expanded(
                                            child: new TextField(
                                              controller: _endDayCtroller,
                                              // 光标颜色
                                              cursorColor:
                                                  GlobalConfig.mainColor,
                                              style: TextStyle(fontSize: 14.0,),
                                              decoration: new InputDecoration(
                                                hintText: '结束时间',
                                                suffixIcon: new IconButton(
                                                  icon: new Icon(
                                                      Icons.calendar_today,
                                                      color: GlobalConfig
                                                          .mainColor),
                                                  onPressed: () {
                                                    ComFunUtil.showDatePicker(
                                                        context, (date) {
                                                      _endDayCtroller.text =
                                                          date;
                                                    });
                                                  },
                                                ),
                                              ),
                                            ),
                                          )
                                        ]),
                                    const SizedBox(height: 10.0),
                                    Stack(
                                      alignment: new Alignment(1.0, 1.0),
                                      //statck
                                      children: <Widget>[
                                        new Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            children: [
                                              Padding(
                                                padding:
                                                    new EdgeInsets.fromLTRB(
                                                        0.0, 0.0, 5.0, 0.0),
                                                child: Text("预留额度:"),
                                              ),
                                              Expanded(
                                                child: new TextField(
                                                  controller: _bandCtroller,
                                                  textAlign: TextAlign.right,
                                                  textDirection: TextDirection.ltr,
                                                  cursorColor:
                                                      GlobalConfig.mainColor,
                                                  keyboardType:
                                                      TextInputType.number,
                                                  //光标切换到指定的输入框
                                                  onEditingComplete: () =>
                                                      FocusScope.of(context)
                                                          .requestFocus(
                                                              _focusNode),
                                                  decoration:
                                                      new InputDecoration(
                                                    hintText: '请输入预留额度',
                                                    contentPadding:
                                                        EdgeInsets.all(10.0),
                                                  ),
                                                ),
                                              ),
                                            ]),
                                      ],
                                    ),
                                    const SizedBox(height: 10.0),
                                    Container(
                                      width: 340.0,
                                      child: new Card(
                                        color: GlobalConfig.mainColor,
                                        elevation: 16.0,
                                        child: FlatButton(
                                          child: Padding(
                                            padding: EdgeInsets.all(10.0),
                                            child: Text(
                                              '计划预览',
                                              style: new TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 16.0),
                                            ),
                                          ),
                                          onPressed: () {
                                            _submitPlan();
                                          },
                                        ),
                                      ),
                                    )
                                  ],
                                ))),
                      ),
                    ),
                  ],
                ),
        ));
  }

  Widget _buildAmountText() {
    return TextFormField(
      controller: _amountCtroller,
      decoration: InputDecoration(
        labelText: '请输入金额',
        filled: true,
        contentPadding: EdgeInsets.only(left: 10.0, right: 10.0),
      ),
      //键盘展示为号码
      keyboardType: TextInputType.number,
      //只能输入数字
      inputFormatters: <TextInputFormatter>[
        WhitelistingTextInputFormatter.digitsOnly,
      ],
      validator: (String value) {
        if (value.isEmpty) {
          return '背面签名3位数';
        }
      },

    );
  }


}
