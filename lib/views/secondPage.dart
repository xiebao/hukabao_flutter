import 'package:flutter/material.dart';
import 'cardsManager.dart';
import '../routers/application.dart';

class secondPage extends StatefulWidget {
  @override
  secondPageState createState() =>  secondPageState();
}

class secondPageState extends State<secondPage> {
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      body: Center(
        child: cardLists(false),
      ),
    );

  }
}