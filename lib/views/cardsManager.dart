import 'package:flutter/material.dart';
import '../routers/application.dart';
import '../model/book_cell.dart';
import '../utils/HttpUtils.dart';
import '../utils/DialogUtils.dart';
import '../components/bankCardBuider.dart';
import 'addCard.dart';
import 'editCard.dart';
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
  BookCell _curCard = BookCell();

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
    return PopupMenuItem<String>(
        value: id,
        child: Container(
          child: Row(
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
            onTap: (index){
                setState(() {
                  _curType=(index + 1).toString() ?? '1';
                });
            },

          ),

          actions: <Widget>[
            // 隐藏的菜单
            new PopupMenuButton<String>(
              itemBuilder: (BuildContext context) => _curType == '1'
                  ? <PopupMenuEntry<String>>[
                      _SelectView(Icons.favorite, '设为默认', 'A'),
                      PopupMenuDivider(height: 1.0),
                      _SelectView(Icons.delete, '删除', 'B'),
                      PopupMenuDivider(height: 1.0),
                      _SelectView(Icons.edit, '修改', 'C'),
                    ]
                  : <PopupMenuEntry<String>>[
                      PopupMenuDivider(height: 1.0),
                      _SelectView(Icons.delete, '删除', 'B'),
                      PopupMenuDivider(height: 1.0),
                      _SelectView(Icons.edit, '修改', 'C'),
                    ],
              onSelected: (String action) {
                // 点击选项的时候
                print(action);

                switch (action) {
                  case 'A':
                    setdefault();
                    break;
                  case 'B':
                    deletitem();
                    break;
                  case 'C':
                    edititem();
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
                    cardType: (cdtp + 1).toString() ?? '1',
                    userName: _userName??"",
                    UserIdNo: _userIdNo??""),
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
            onLongPress:() {
              setState(() {
                _curCardId = data.id;
                _curCard = data;
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
                                .withAlpha(88)
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
                            padding: const EdgeInsets.only(right: 20, top: 25),
                            child: SizedBox(
                                width: 100,
                                child: Row(
                                  children: <Widget>[
                                    Text('默认'),
                                    Icon(
                                      Icons.favorite,
                                      size: 12,
                                      color: Colors.red[500],
                                    ),
                                    Radio(
                                        value: data.id,
                                        groupValue: _curCardId,
                                        onChanged: (v) {
                                          setState(() {
                                            _curCardId = data.id;
                                            _curCard = data;
                                            _curType = page.id == '储' ? "1" : "2";
                                            print(_curCardId + "-" + _curType);
                                          });

                                        })
                                  ],
                                )))
                        : Padding(
                            padding: const EdgeInsets.only(right: 20, top: 12),
                            child: Radio(
                                value: data.id,
                                groupValue: _curCardId,
                                onChanged: (v) {
                                  setState(() {
                                    _curCardId = data.id;
                                    _curCard = data;
                                    _curType = page.id == '储' ? "1" : "2";
                                    print(_curCardId + "-" + _curType);
                                  });

                                }),
                          )),
              ],
            ))
        : const SizedBox(height: 2.0);
  }

  void setdefault() async {
    if(_tabController.index==1){
       setState(() {
        _curType = '2';
      });
      await DialogUtils.showToastDialog(context, "不支持默认信用卡设置");
      return;
    }
    if (_curCardId != '' && _curType == '1') {
      Map<String, String> params = {
        "cardId": _curCardId,
      };
      await HttpUtils.apipost(context, 'User/setDefaultcard', params,
          (response) async {
        String ercd = response['error_code'].toString() ?? '0';
        if (ercd == '1') {
          setState(() {
            _defalutId = _curCardId;
          });
        }
        await DialogUtils.showToastDialog(context, response['message']);
      });
    } else {
      if (_curType != '1')
        await DialogUtils.showToastDialog(context, "不支持默认信用卡设置");
      else
        await DialogUtils.showToastDialog(context, "请长按选择储蓄卡卡片");
    }
  }

  void deletitem() async {
    if (_curCardId != '') {
      Map<String, String> params = {
        "cardId": _curCardId,
      };
      setState(() {
        _deleteIds.add(_curCardId);
      });
      await HttpUtils.apipost(context, 'User/cardDelete', params,
          (response) async {
        print('=================cardDelete======================');
        String ercd = response['error_code'].toString() ?? '0';
        if (ercd != '1') {
          setState(() {
            _deleteIds.removeLast();
          });
        }
        await DialogUtils.showToastDialog(context, response['message']);
      });
    } else
      await DialogUtils.showToastDialog(context, "请长按卡片选择");
  }

  void edititem() async {
    if (_curCardId != '' && _curCard.id != '') {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => editCard(_curCard),
        ),
      ).then((result) {
        if (result == '1') {
          _mounted = false;
          _cardsList1 = List();
          _cardsList2 = List();
          _loadData();
        }
      });
    } else
      await DialogUtils.showToastDialog(context, "请长按卡片选择");
  }
}
