import './router_handler.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';

class Routes {
  static String root = '/';
  static String swipPage = '/swip';
  static String flashPage = "/flash";
  static String webViewPage = '/web';
  static String homePage = '/home';//
  static String loginPage = '/login';
  static String userCenterPage = '/user';
  static String planPage = '/plan';

  static String sharePage = '/share';
  static String payLogPage = '/paylog';
  static String addCardPage = '/addcard';
  static String cardAdminPage = '/cardadmin';
  static String orderListPage = '/order';
  static String omyMsgistPage = '/myMsg';


  static void configureRoutes(Router router) {
    router.notFoundHandler = new Handler(
        handlerFunc: (BuildContext context, Map<String, List<String>> params) {
      print("ROUTE WAS NOT FOUND !!!");
    });
    router.define(root,handler: homePageHandler);
      router.define(flashPage, handler: flashPageHandler);
    router.define(webViewPage, handler: webPageHandler);
    router.define(homePage, handler: homePageHandler);
    router.define(loginPage,handler: loginPageHandler);

    router.define(planPage,handler: planPageHandler);
    router.define(userCenterPage, handler:userPageHandler);
    router.define(cardAdminPage,handler: cardAdminPageHandler);

    router.define(sharePage, handler:sharePageHandler);
    router.define(payLogPage, handler: payLogPageHandler);
    router.define(orderListPage, handler:orderListPageHandler);
    router.define(omyMsgistPage, handler: myMsgListPageHandler);


  }
}
