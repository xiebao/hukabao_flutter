import 'dart:async' show Future;
import '../utils/HttpUtils.dart';
import '../model/book_cell.dart';
import '../model/model_cell.dart';
class DataUtils {
/*
//import 'package:flutter/services.dart' show rootBundle;
  static Future<String> _loadPinsListAsset() async {
    return await rootBundle.loadString('assets/pins.json');
  }
*/
  // 首页九宫格列表数据
  static Future<List<ModelCell>> getIndexModelListData(
      Map<String, dynamic> params) async {
    List<ModelCell> resultList = new List();

    await HttpUtils.post(null,'Public/getAppModel',(response) {
      var responseList = response['data'];
      try {
        for (int i = 0; i < responseList.length; i++) {
          ModelCell bookCell;

          bookCell = ModelCell.fromJson(responseList[i]);
//        print(bookCell.modName);
          resultList.add(bookCell);
        }
      } catch (e) {
        return [];
      }
    },params:params);

    return resultList;
  }

/*
  // 获取小册导航栏
  static Future<List<BookNav>> getBookNavData() async {
    List<BookNav> resultList = [];
    var response = await HttpUtils.post1(GlobalConfig.base);
    var responseList = response['d'];
    for (int i = 0; i < responseList.length; i++) {
      BookNav bookNav;
      try {
        bookNav = BookNav.fromJson(responseList[i]);
      } catch (e) {
        print("error $e at $i");
        continue;
      }
      resultList.add(bookNav);
    }

    return resultList;
  }*/

  // 获取小册--卡片列表
  static Future<List<BookCell>> getBookListData(
      Map<String, dynamic> params) async {
    List<BookCell> resultList = new List();
//    var response =  await HttpUtils.request('User/cardList', data: params, method: 'post');
    await HttpUtils.post(null,'Public/getAppModel',(response) {
      var responseList = response['d'];
      for (int i = 0; i < responseList.length; i++) {
        BookCell bookCell;
        try {
          bookCell = BookCell.fromJson(responseList[i]);
        } catch (e) {
          print("error $e at $i");
          continue;
        }
        resultList.add(bookCell);
      }

    },params:params);

    return resultList;
  }
}
