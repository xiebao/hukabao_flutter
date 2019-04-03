import 'package:flutter/material.dart';
import 'package:fluro/fluro.dart';
import '../views/webViewnew.dart';
import '../views/login.dart';
import '../views/cardsManager.dart';
import '../views/MyInfoPage.dart';
import '../homePage.dart';
import '../splashPage.dart';
import '../views/sharePage.dart';
import '../views/payLog.dart';
import '../views/orderList.dart';
import '../views/plan_page.dart';


// /web?url=${Uri.encodeComponent(linkUrl)}&title=${Uri.encodeComponent('掘金沸点')}
//'/swip?pics=${Uri.encodeComponent(_buildPicsStr())}&currentIndex=${i.toString()}'
Handler webPageHandler = Handler(
    handlerFunc: (BuildContext context, Map<String, List<String>> params) {
      String articleUrl = params['url']?.first;
      String title = params['title']?.first;
      print('$articleUrl and  $title');
        return WebView(title, articleUrl);
    }
  );

Handler loginPageHandler = Handler(
    handlerFunc: (BuildContext context, Map<String, List<String>> params) {
      return LoginPage();
    });

Handler homePageHandler = Handler(
    handlerFunc: (BuildContext context, Map<String, List<String>> params) {
      return homePage();
    });


Handler flashPageHandler = Handler(
    handlerFunc: (BuildContext context, Map<String, List<String>> params) {
      return SplashPage();
    });


Handler sharePageHandler = Handler(
    handlerFunc: (BuildContext context, Map<String, List<String>> params) {
        return sharePage();
//      return MyInfoPage();
    });

Handler planPageHandler=Handler(
    handlerFunc: (BuildContext context, Map<String, List<String>> params) {
  return planPage();
//      return MyInfoPage();
});


Handler cardAdminPageHandler=Handler(
    handlerFunc: (BuildContext context, Map<String, List<String>> params) {
      return cardLists(false);
//      return MyInfoPage();
    });



Handler userPageHandler = Handler(
    handlerFunc: (BuildContext context, Map<String, List<String>> params) {
/*      String user_id = params['id']?.first;
      String status=params['status']?.first;
      String phone = params['phone']?.first;
      String name = params['username']?.first;
      String avatar= params['avatar']?.first;*/
      return MyInfoPage();//user_id,status,phone,name,avatar
    });


Handler orderListPageHandler = Handler(
    handlerFunc: (BuildContext context, Map<String, List<String>> params) {
      return orderListPage();
    });


/*

Handler swipPageHandler = Handler(
    handlerFunc: (BuildContext context, Map<String, List<String>> params) {
      String pics = params['pics']?.first;
      String index = params['currentIndex']?.first;
      print(pics);
      return SwipPage(pics: pics,currentIndex: index,);
    });

*/

Handler payLogPageHandler = Handler(
    handlerFunc: (BuildContext context, Map<String, List<String>> params) {
      return payLogPage();
    });


