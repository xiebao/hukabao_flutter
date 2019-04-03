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
  final bool fromtp;//区分来源，否则后退有问题

  @override
  TabBarDemoState createState() => new TabBarDemoState();
}

class TabBarDemoState extends State<cardLists> with AutomaticKeepAliveClientMixin,SingleTickerProviderStateMixin {
  @override
  bool get wantKeepAlive => true;

  bool _mounted = false;
  List<BookCell> _cardsList1 = List();
  List<BookCell> _cardsList2 = List();
  String _curType="1";
  String _curCardId='';
String _userName;
String _userIdNo;
  TabController _tabController;

  _loadData() async {
    if (_mounted && _cardsList1.isNotEmpty) return;
    HttpUtils.apipost(context, 'Index/cardListIndex', {}, (response) {
      print('=================cardLists======================');
      response['data']['cardList'].forEach((ele) {
        if (ele.isNotEmpty) {
          print(ele);
          if (ele['cardType'] == '2')
            _cardsList2.add(BookCell.fromJson(ele));
          else
            {
              _cardsList1.add(BookCell.fromJson(ele));
              _userName=_userName ?? ele['name'];
              _userIdNo=_userIdNo ?? ele['idCardNo'];
            }


        }
      });

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
        child: new Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            new Icon(icon, color:GlobalConfig.mainColor),
            new Text(text),
          ],
        )
    );
  }
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('卡片管理'),
        centerTitle: true,
//        重写返回按钮，
        leading:IconButton(icon: Icon(Icons.arrow_back), onPressed: (){ Application.run(context, "/");}),
        bottom: new TabBar(
          tabs: <Widget>[
            new Text('储蓄卡'),
            new Text('信用卡'),
          ],
          controller: _tabController,
        ),
        actions: <Widget>[
         /* // 非隐藏的菜单
          IconButton(
          icon: Icon(Icons.playlist_play),
          tooltip: 'Air it',
          onPressed: null,
          ),
*/
          // 隐藏的菜单
          new PopupMenuButton<String>(
            itemBuilder: (BuildContext context) => <PopupMenuItem<String>>[
              _SelectView(Icons.message, '设为默认', 'A'),
              _SelectView(Icons.group_add, '修改', 'B'),
              _SelectView(Icons.cast_connected, '删除', 'C'),
            ],
            onSelected: (String action) {
              // 点击选项的时候
              print(action);
              switch (action) {
                case 'A':
                  if (_curCardId!='' && _curType=='1'){
                    Map<String, String> params = {
                      "cardId": _curCardId,
                    };
                    HttpUtils.apipost(context, 'User/setDefaultcard', params, (response) {
                      print('=================setDefaultcard======================');
                      DialogUtils.showToastDialog(context, text: response['message']);
                      if (response['error_code'] == '1'){
                        setState(() {
                          _mounted = false;
                          _loadData();
                        });
                      };
                    });
                  }else
                    DialogUtils.showToastDialog(context, text: "请长按卡片选择");

                  break;
                case 'B':
                  if (_curCardId!=''){
                    Map<String, String> params = {
                      "cardId": _curCardId,
                    };
                    HttpUtils.apipost(context, 'User/cardDelete', params, (response) {
                      print('=================cardDelete======================');
                      DialogUtils.showToastDialog(context, text: response['message']);
                      if (response['error_code'] == '1'){
                        setState(() {
                          _mounted = false;
                          _loadData();
                        });
                      };
                    });
                  }else
                    DialogUtils.showToastDialog(context, text: "请长按卡片选择");

                  break;
                case 'C':
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
                vertical: 18.0,
              ),
              child: ListView.builder(
                itemCount: _cardsList1.length,
                itemBuilder: (context, index) {
                 return _cardShow( Page(label: '储蓄卡'),_cardsList1[index]);

                },
              ),
            ),
          ),
          new Center(
              child: new Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 18.0,
            ),
            child: ListView.builder(
              itemCount: _cardsList2.length,
              itemBuilder: (context, index) {
                return _cardShow(Page(label: '信用卡'),_cardsList2[index]);
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
        onPressed: () {
          var cdtp = _tabController.index;
          print("添加" + cdtp.toString());
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => addCard(cardType: (cdtp + 1).toString(),userName: _userName,UserIdNo:_userIdNo),
            ),
          ).then((result) {
            print(result);
            if (result == '1') {
              _mounted = false;
              _loadData();
            }
          });
        },
      ),
    );
  }

   Widget _cardShow(Page page,  BookCell data){
    return InkWell(
         onLongPress: () {
           print('Selectable card state changed');
           setState(() {
             _curCardId=data.id;
             _curType=  page.id == '储'?"1":"2";
             print(_curCardId+"-"+_curType);

           });
         },
         splashColor: Theme.of(context).colorScheme.primary.withAlpha(30),
         child: Stack(
           children: <Widget>[
             Column(  crossAxisAlignment: CrossAxisAlignment.start,
               children: [
                 Container(
                     color: _curCardId==data.id
                         ? Theme.of(context).colorScheme.primary.withAlpha(41)
                         : Colors.transparent,
                     child:CardDataItem(
                       page:page,
                       data:data,
                     )
                 )
               ],),
             Align(
                 alignment: Alignment.topRight,
                 child: Padding(
                   padding: const EdgeInsets.all(4.0),
                   /*     child: Icon(
                                  Icons.check_circle,
                                  color: _isSelected ? Colors.white : Colors.transparent,
                                ),*/
                   child: Radio(value: data.id, groupValue: _curCardId, onChanged: (v){print(v);setState(() {
                     _curCardId=v;
                   });}),
                 )
             ),
           ],
         )
     );
   }

}
