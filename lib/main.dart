import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:fluro/fluro.dart';
import 'package:fluwx/fluwx.dart' as fluwx;
import './routers/routes.dart';
import './routers/application.dart';
import 'globleConfig.dart';
import './model/globle_model.dart';
import 'splashPage.dart';

void main() {
  runApp(Kukabao(
    model: globleModel(),
  ));
  if (Platform.isAndroid) {
// 以下两行 设置android状态栏为透明的沉浸。写在组件渲染之后，是为了在渲染后进行set赋值，覆盖状态栏，写在渲染之前MaterialApp组件会覆盖掉这个值。
    SystemUiOverlayStyle systemUiOverlayStyle =
        SystemUiOverlayStyle(statusBarColor: GlobalConfig.mainColor);
    SystemChrome.setSystemUIOverlayStyle(systemUiOverlayStyle);
  }
}

class Kukabao extends StatefulWidget {
  final globleModel model;
  const Kukabao({Key key, @required this.model}) : super(key: key);

  @override
  KukabaoState createState() => new KukabaoState();
}

class KukabaoState extends State<Kukabao> {

  @override
  Widget build(BuildContext context) {
    final router = new Router();
    Routes.configureRoutes(router);
    Application.router = router;

    return ScopedModel(
      model: widget.model,
      child: MaterialApp(
      title: '护卡宝',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        primaryColor: GlobalConfig.mainColor,
        primaryIconTheme: const IconThemeData(color: Colors.white),
        brightness: Brightness.light,
        accentColor: Colors.orange,
      ),
      color: GlobalConfig.mainColor,
//      initialRoute: "/",
      onGenerateRoute: Application.router.generator,
      onGenerateTitle: (context) {
        return '护卡宝应用';
      },
      builder: (BuildContext context, Widget child) {
        return Directionality(
            textDirection: TextDirection.ltr,
            child: MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaleFactor: 1,
              ),
              child: CupertinoTheme(
                data: CupertinoThemeData(
                  brightness: Brightness.light,
                ),
                child: child,
              ),
            ));
      },
      home: SplashPage(),
      ),
    );
  }

  _initFluwx() async {
    await fluwx.register(
        appId: GlobalConfig.wxAppId,
        doOnAndroid: true,
        doOnIOS: true,
        enableMTA: false);
    var result = await fluwx.isWeChatInstalled();
    print("is installed $result");
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _initFluwx();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    fluwx.dispose();
  }

  @override
  void didUpdateWidget(Kukabao oldWidget) {
    // TODO: implement didUpdateWidget
    super.didUpdateWidget(oldWidget);
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
  }
}


/*
void main() {
  runApp(MyApp(
    model: globleModel(),
  )
  );
*/
class MyApp extends StatelessWidget {
  final globleModel model;
  const MyApp({Key key, @required this.model}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final router = new Router();
    Routes.configureRoutes(router);
    Application.router = router;

    return ScopedModel(
        model: model,
        child: MaterialApp(
          title: '护卡宝',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            primarySwatch: Colors.blue,
            primaryColor: GlobalConfig.mainColor,
            primaryIconTheme: const IconThemeData(color: Colors.white),
            brightness: Brightness.light,
            accentColor: Colors.orange,
          ),
          color: GlobalConfig.mainColor,
          initialRoute: "/",
          onGenerateRoute: Application.router.generator,
          onGenerateTitle: (context) {
            return '护卡宝应用';
          },
          builder: (BuildContext context, Widget child) {
            return Directionality(
                textDirection: TextDirection.ltr,
                child: MediaQuery(
                  data: MediaQuery.of(context).copyWith(
                    textScaleFactor: 1,
                  ),
                  child: CupertinoTheme(
                    data: CupertinoThemeData(
                      brightness: Brightness.light,
                    ),
                    child: child,
                  ),
                ));
          },
          home: SplashPage(),
        ));
  }
}
