import 'package:flutter/material.dart';
import 'MyInfoPage.dart';

class thirdPage extends StatefulWidget {
  @override
  thirdPageState createState() => new thirdPageState();
}

class thirdPageState extends State<thirdPage> {
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
//      appBar:  AppBar(
//        centerTitle: true,
//        title:  Text('个人'),
//      ),
      body: Center(
        child: MyInfoPage(),
//        child: cardsManager(),
//        child: List(),
//        child: Text('个人中心'),
      ),
    );
  }
}