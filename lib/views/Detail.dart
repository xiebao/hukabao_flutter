import 'package:flutter/material.dart';

class Detail extends StatelessWidget {
  final String id;
  Detail(this.id);

  @override
  Widget build(BuildContext context) {
    Color _bticon=Colors.deepOrange;
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('详细信息' + id),
      ),
      body: Center(
//        child:Text('这是的id=' + id + '信息'),
          child: new Container(
              decoration: new BoxDecoration(
                border: new Border.all(width: 5.0, color: Colors.black38),
                borderRadius:
                const BorderRadius.all(const Radius.circular(8.0)),

              ),
              margin: const EdgeInsets.all(16.0),

              child: new GridView.count(
                crossAxisCount: 3,
                padding: const EdgeInsets.all(0.0),
                mainAxisSpacing: 0.0,
                crossAxisSpacing: 0.0,
                children: <Widget>[
                  Icon(Icons.home),
                  Icon(Icons.home),
                  Icon(Icons.home),
                  Tab(text: '首页', icon: Icon(Icons.home,color: _bticon,)),
                  Tab(text: '卡片', icon: Icon(Icons.credit_card,color: _bticon)),
                  Tab(text: '个人', icon: Icon(Icons.person,color: _bticon)),
                  Image.network('http://app.hukabao.com/Uploads/App/2018-12-14/5c136ee045ecb.png'),
                  Image.network('http://app.hukabao.com/Uploads/App/2018-12-14/5c136ecebc041.png'),
                  Image.asset('images/lake.jpg'),

                  Container(
                    child: GestureDetector(
                      child: new Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        verticalDirection: VerticalDirection.down,
                        // textDirection:,
//            textBaseline: TextBaseline.alphabetic,
                        children: <Widget>[
                          Expanded(child:
                          new Container(
                            constraints: new BoxConstraints.expand(),
                            decoration: new BoxDecoration(
                              image: new DecorationImage(
//                image: new NetworkImage('http://h.hiphotos.baidu.com/zhidao/wh%3D450%2C600/sign=0d023672312ac65c67506e77cec29e27/9f2f070828381f30dea167bbad014c086e06f06c.jpg'),
                                image: AssetImage('images/sysicon/icon_jilu.png'),
                              ),
                            ),

                          ),
                          ),
                          Expanded(child:Text('肥嘟嘟'))
                        ],
                      ),
                      onTap: () {
                        print(11);
//          var bodyJson = '{"user":1281,"pass":3041}';
//          Application.router.navigateTo(context, '/web/$bodyJson');
                      },
                    ),
                  ),

                  new Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    verticalDirection: VerticalDirection.down,
                    // textDirection:,
//            textBaseline: TextBaseline.alphabetic,
                    children: <Widget>[
                      Expanded(child:
                      new Container(
                        constraints: new BoxConstraints.expand(),
                        decoration: new BoxDecoration(
                          image: new DecorationImage(
//                image: new NetworkImage('http://h.hiphotos.baidu.com/zhidao/wh%3D450%2C600/sign=0d023672312ac65c67506e77cec29e27/9f2f070828381f30dea167bbad014c086e06f06c.jpg'),
                            image: AssetImage('images/sysicon/icon_jilu.png'),
                          ),
                        ),

                      ),
                      ),
                      Expanded(child:Text('的说法的'))
                    ],

                  ),
//                  new Image.asset('images/lake.jpeg', width: 200.0,height: 200.0, fit: BoxFit.cover),
                ],
              ))
      ),
    );
  }
}