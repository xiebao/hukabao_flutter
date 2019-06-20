import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../utils/dataUtils.dart';
import '../utils/HttpUtils.dart';
import '../components/index_model_list.dart';
import '../model/index_model.dart';
import '../model/model_cell.dart';
import '../views/swip_page.dart';

class IndexPage extends StatefulWidget {
/*  IndexPage(this.picList);
  final List<PicsCell> picList;*/

  IndexPageState createState() => IndexPageState();
}

class IndexPageState extends State<IndexPage>
    with AutomaticKeepAliveClientMixin {
  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;

  List<ModelCell> _listData = new List();

  bool _isRequesting = false; //是否正在请求数据的flag

  void _initModelList() async {
    if (_isRequesting) return;

    Map<String, dynamic> params = {
      "modAddr": '1',
      "category": "all",
      "limit": 20
    };
    DataUtils.getIndexModelListData(params).then((result) {
      print(result);
      setState(() {
        _listData = result;
        _isRequesting = true;
      });
    });
  }

  /**
   * 获取九宫格
   */
  @override
  void initState() {
    _initModelList();
    super.initState();
  }

  List<PicsCell> _picList = [];

  Future _initPicList() async {
    await HttpUtils.apipost(context,'Index/cardIndex',{},(response) {
      print("----------------adList--------------------");

      PicsCell dd;
      print(response['data']['adList']);

        response['data']['adList'].forEach((ele) {
          dd = PicsCell(
              imgurl: ele['image_url'], title: ele['title'], url: ele['url']);
          _picList.add(dd);
        });
    });
    return _picList;
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    EdgeInsets padding = MediaQuery.of(context).padding;
    double top = math.max(padding.top, EdgeInsets.zero.top);

    return SafeArea(
      top: false,
      bottom: true,
      child: !_isRequesting
          ? Center(
              child:
              Image.asset(
                'images/logo.png',
                width: 100,
                height: 100,
              )
//              DialogUtils.uircularProgress(),
            )
          : Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.fromLTRB(0, top, 0, 10.0),
                  child:
                  FutureBuilder(
                    future: _initPicList(),
                    builder: (BuildContext context, AsyncSnapshot snapshot) {      //snapshot就是_calculation在时间轴上执行过程的状态快照
                      switch (snapshot.connectionState) {
                        case ConnectionState.none: return new Text('Press button to start');    //如果_calculation未执行则提示：请点击开始
                        case ConnectionState.waiting: return new Text('Awaiting result...');  //如果_calculation正在执行则提示：加载中
                        default:    //如果_calculation执行完毕
                          if (snapshot.hasError)    //若_calculation执行出现异常
                            return new Text('Error: ${snapshot.error}');
                          else {
                            if (snapshot.hasData) {
                              return SwipPage(snapshot.data);
                            } else {
                              return Center(
                                child: Text("加载中"),
                              );
                            }
                          }   //若_calculation执行正常完成
//                    return new Text('Result: ${snapshot.data}');
                      }
                    },
                  ),

                ), //, //
                Expanded(
                  child: IndexModelList(_listData),
                ),
              ],
            ),
//      ),
//      body:  IndexModelList(_listData),
    );
  }
}
