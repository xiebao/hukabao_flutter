import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../utils/dataUtils.dart';
import '../components/index_model_list.dart';
import '../model/index_model.dart';
import '../model/model_cell.dart';
import '../views/swip_page.dart';

class IndexPage extends StatefulWidget {
  IndexPage(this.picList);
  final List<PicsCell> picList;

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

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    EdgeInsets padding = MediaQuery.of(context).padding;
    double top = math.max(padding.top, EdgeInsets.zero.top);

    return SafeArea(
      top: true,
      bottom: false,
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
                  child:SwipPage(widget.picList),
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
