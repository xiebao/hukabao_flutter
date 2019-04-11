import 'package:flutter/material.dart';
import '../routers/application.dart';
import '../model/book_cell.dart';
import '../utils/HttpUtils.dart';
import '../utils/DialogUtils.dart';
import '../components/bankCardBuider.dart';
import '../views/addCard.dart';
import '../globleConfig.dart';

class cardLists extends StatefulWidget {
  cardLists(this.fromtp);
  final bool fromtp; //区分来源，否则后退有问题

  @override
  TabBarDemoState createState() => new TabBarDemoState();
}

class TabBarDemoState extends State<cardLists>
    with AutomaticKeepAliveClientMixin, SingleTickerProviderStateMixin {
  @override
  bool get wantKeepAlive => true;

  bool _mounted = false;
  List<BookCell> _cardsList1 = List();
  List<BookCell> _cardsList2 = List();
  String _curType = "1";
  String _curCardId = '';
  String _userName;
  String _userIdNo;
  TabController _tabController;
  String _defalutId = '';
  List<String> _deleteIds = List();

  _loadData() async {
    if (_mounted) return;
    HttpUtils.apipost(context, 'Index/cardListIndex', {}, (response) {
      print('=================cardLists======================');
      response['data']['cardList'].forEach((ele) {
        if (ele.isNotEmpty) {
          print(ele);
          if (ele['cardType'] == '2')
            _cardsList2.add(BookCell.fromJson(ele));
          else {
            _cardsList1.add(BookCell.fromJson(ele));
            _userName = _userName ?? ele['name'];
            _userIdNo = _userIdNo ?? ele['idCardNo'];
          }
        }
      });

      _defalutId = response['data']['cardDefault'] ?? '';

      setState(() {
        _mounted = true;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void initState() {
    super.initState();
    _tabController = new TabController(vsync: this, length: 2);
    _loadData();
  }

  // 返回每个隐藏的菜单项
  _SelectView(IconData icon, String text, String id) {
    return new PopupMenuItem<String>(
        value: id,
        child: Container(
          child: new Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              new Icon(icon, color: GlobalConfig.mainColor),
              new Text(text),
            ],
          ),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: new AppBar(
          title: new Text('卡片管理'),
          centerTitle: true,
//        重写返回按钮，
          leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                Application.run(context, "/");
              }),
          flexibleSpace: null,
          bottom: TabBar(
            labelPadding: EdgeInsets.symmetric(horizontal: 38),
            tabs: <Widget>[
              new Tab(
                text: '储蓄卡',
                icon: Icon(Icons.card_giftcard),
              ),
              new Tab(
                text: '信用卡',
                icon: Icon(Icons.credit_card),
              ),
            ],
            controller: _tabController,
          ),

          actions: <Widget>[
            // 隐藏的菜单
            new PopupMenuButton<String>(
              itemBuilder: (BuildContext context) => <PopupMenuItem<String>>[
                    _SelectView(Icons.favorite, '设为默认', 'A'),
                    _SelectView(Icons.delete, '删除', 'B'),
//                    _SelectView(Icons.ac_unit, '隐藏测试', 'C'),
                  ],
              onSelected: (String action) {
                // 点击选项的时候
                print(action);
                switch (action) {
                  case 'A':
                    if (_curCardId != '' && _curType == '1') {
                      Map<String, String> params = {
                        "cardId": _curCardId,
                      };
                      HttpUtils.apipost(context, 'User/setDefaultcard', params,
                          (response){
                        print(
                            '=================setDefaultcard======================');

                        String ercd = response['error_code'].toString() ?? '0';
                        if (ercd == '1') {
                          setState(() {
                            _defalutId = _curCardId;
                          });
                        }
                        DialogUtils.showToastDialog(context, response['message']);
                      });
                    } else
                      DialogUtils.showToastDialog(context, "请长按选择储蓄卡卡片");

                    break;
                  case 'B':
                    if (_curCardId != '') {
                      Map<String, String> params = {
                        "cardId": _curCardId,
                      };
                      setState(() {
                        _deleteIds.add(_curCardId);
                      });
                      HttpUtils.apipost(context, 'User/cardDelete', params,
                          (response) {
                        print(
                            '=================cardDelete======================');
                        String ercd = response['error_code'].toString() ?? '0';
                         if (ercd != '1') {
                          setState(() {
                            _deleteIds.removeLast();
                          });
                        }
                        DialogUtils.showToastDialog(context,  response['message']);

                          });
                    } else
                      DialogUtils.showToastDialog(context, "请长按卡片选择");

                    break;
                  case 'C':
                    if (_curCardId != '') {
                      DialogUtils.showToastDialog(context, "隐藏测试$_curCardId");
                      setState(() {
                        _deleteIds.add(_curCardId);
                      });
                    } else
                      DialogUtils.showToastDialog(context,  "请长按卡片选择");

                    break;
                }
              },
            ),
          ],
        ),
        body: new TabBarView(
          controller: _tabController,
          children: <Widget>[
            /*  new Center(
              child: new Tab(
            icon: new Icon(Icons.directions_bike),
          )),*/
            new Center(
              child: new Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 10.0,
                ),
                child: ListView.builder(
                  itemCount: _cardsList1.length,
                  itemBuilder: (context, index) {
                    return _cardShow(Page(label: '储蓄卡'), _cardsList1[index]);
                  },
                ),
              ),
            ),
            new Center(
                child: new Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 10.0,
              ),
              child: !_mounted
                  ? DialogUtils.uircularProgress()
                  : ListView.builder(
                      itemCount: _cardsList2.length,
                      itemBuilder: (context, index) {
                        return _cardShow(
                            Page(label: '信用卡'), _cardsList2[index]);
                      },
                    ),
            )
//              child: new Tab(
//            icon: new Icon(Icons.directions_boat),
//          )
                ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          icon: Icon(Icons.add),
          label: Text("添加"),
          onPressed: () async {
            var cdtp = _tabController.index;
            print("添加" + cdtp.toString());
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => addCard(
                    cardType: (cdtp + 1).toString(),
                    userName: _userName,
                    UserIdNo: _userIdNo),
              ),
            ).then((result) {
              print(result);
              if (result == '1') {
                _mounted = false;
                _cardsList1 = List();
                _cardsList2 = List();
                _loadData();
              }
            });
          },
        ),
      ),
    );
  }

  Widget _cardShow(Page page, BookCell data) {
    return _deleteIds.indexOf(data.id) < 0
        ? InkWell(
            onLongPress: () {
              print('Selectable card state changed');
              setState(() {
                _curCardId = data.id;
                _curType = page.id == '储' ? "1" : "2";
                print(_curCardId + "-" + _curType);
              });
            },
            splashColor: Theme.of(context).colorScheme.primary.withAlpha(30),
            child: Stack(
              children: <Widget>[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                        alignment: Alignment.center,
                        color: _curCardId == data.id
                            ? Theme.of(context)
                                .colorScheme
                                .primary
                                .withAlpha(41)
                            : Colors.transparent,
                        child: CardDataItem(
                          page: page,
                          data: data,
                        ))
                  ],
                ),
                Align(
                    alignment: Alignment.topRight,
                    child: data.cardType == '1' && _defalutId == data.id
                        ? Padding(
                            padding: const EdgeInsets.only(right: 40, top: 25),
                            child: SizedBox(
                                width: 50,
                                child: Row(
                                  children: <Widget>[
                                    Text('默认'),
                                    Icon(
                                      Icons.favorite,
                                      size: 12,
                                      color: Colors.red[500],
                                    )
                                  ],
                                )))
                        : Padding(
                            padding: const EdgeInsets.only(right: 20, top: 12),
                            child: Radio(
                                value: data.id,
                                groupValue: _curCardId,
                                onChanged: (v) {
                                  print(v);
                                  setState(() {
                                    _curCardId = v;
                                  });
                                }),
                          )),
              ],
            ))
        : const SizedBox(height: 2.0);
  }
}
