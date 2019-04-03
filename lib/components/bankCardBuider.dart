import 'package:flutter/material.dart';
import '../model/book_cell.dart';

class CardDataItem extends StatelessWidget {
  const CardDataItem({this.page, this.data});
  final Page page;
  final  BookCell data;

  static   List<Color> tcolor=[Colors.red[200],Colors.green[200],Colors.blue[200],Colors.purple[200],Colors.indigo[200],];
  static   List<Color> tscolor=[Colors.red[300],Colors.green[300],Colors.blue[300],Colors.purple[300],Colors.indigo[300],];

  static const double height = 210.0;
  static const double width = 355.0;
  final int radioValue = 0;

  @override
  /* Widget build(BuildContext context) {
    return Card(
      child: new Padding(
        padding: const EdgeInsets.all(16.0),
        child: new Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            new Align(
              alignment: Alignment.centerLeft,
//                page.id == '储' ? Alignment.centerLeft : Alignment.centerRight,
              child: new CircleAvatar(child: new Text('${page.id}')),
            ),
            new SizedBox(
              width: 144.0,
              height: 144.0,
              child: new Image.asset(
                data.cardIcon,
                fit: BoxFit.contain,
              ),
            ),
            new Center(
              child: new Text(
                data.cardName,
                style: Theme.of(context).textTheme.title,
              ),
            ),
          ],
        ),
      ),
    );
  }
*/
  Widget build(BuildContext context) {
    //sizedBox部件会强制子项具有给定的宽度和高度(父级允许的话),如果没有给定宽度|高度,将
    //自行调整以维护子项大小
    return Padding(  padding: new EdgeInsets.fromLTRB(10, 5, 10, 5),child: SizedBox(
      height: height,
      width: width,
      child: buildCard(),
    ),) ;
  }

  Widget buildCard() {
    return new Card(
      //背景色
      color: tcolor[(int.parse(data.id))%5],
      //阴影大小-默认2.0
      elevation: 5.0,

      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10.0))), //设置圆角

      child:  Column(
        //横轴起始测对齐
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _firstRow(),
          _buildText(),
          _buildRowText(),
        ],
      ),
    );
  }

  Widget _firstRow() {
    return  ListTile(
          leading: CircleAvatar(
            backgroundImage: AssetImage(
              "images/bank/${data.cardIcon ?? 'unionpay'}.png",
            ) ?? AssetImage( "images/bank/unionpay.png"),
            maxRadius: 20,
            backgroundColor: Colors.white,
          ),
          title: Text(data.cardName),
          subtitle: Text('${data.cardIcon}单日限额8888888888${data.bankAbbr}'),
        );
  }

  Widget _buildText() {
    return  Center(
        child: Text(
          data.cardNo,
          style: const TextStyle(color: Colors.white, fontSize: 24),
        ),
//      ),
    );
  }

  Widget _buildRowText() {
    return  Container(
        height: 45,
//        color: subcolor,
        decoration: new BoxDecoration(
          color: tscolor[(int.parse(data.id))%5],
          borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(10),
              bottomRight: Radius.circular(10)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildContainer(data.bankRepayDate),
            _buildContainer(data.name),
          ],
        ),
    );
  }

  Widget _buildContainer(String text) {
    return new Container(
        margin: const EdgeInsets.only(left: 30.0, right: 30, top: 10),
        child: new Text(
          text,
          style: new TextStyle(
              fontSize: 15.0,
              color: Colors.white70,
              fontWeight: FontWeight.bold),
        ));
  }
}
