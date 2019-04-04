import 'dart:core';
import 'package:fluro/fluro.dart';
import '../utils/HttpUtils.dart';
import '../utils/DialogUtils.dart';

class Application {
  static Router router;
  static void run(context, appuri,
      {String url, String title, bool withToken = true}) async {
    if (appuri.startsWith('/web')) {
      if (url != '') {
        await HttpUtils().theToken.then((String token) async {
          if (token == '')
            DialogUtils.close2Logout(context);
          else {
            if (withToken == true)
              url = url.endsWith('token/')
                  ? url + token
                  : "$url/$token"; // "$url/token/$token";
            appuri =
                "/web?url=${Uri.encodeComponent(url)}&title=${Uri.encodeComponent(title ?? '浏览')}";

            await HttpUtils.request('Index/checktoken/token/$token',
                    data: {}, method: 'post')
                .then((response) {
              if (response["error_code"].toString() == '1') {
                router.navigateTo(context, appuri,
                    transition: TransitionType.fadeIn);
              } else
                DialogUtils.close2Logout(context);
            });
          }
        });
      } else {
        DialogUtils.showToastDialog(context, text: '无效网址');
      }
    } else
      router.navigateTo(context, appuri, transition: TransitionType.native);
  }
}

/*
 onPressed: () {
            Application.router.navigateTo(context, "/login",
                transition: TransitionType.fadeIn);
          },
router.navigateTo(context, "/users/1234", transition: TransitionType.fadeIn);

          onTap: () {
                Application.router.navigateTo(context,
                   '/swip?pics=${Uri.encodeComponent(_buildPicsStr())}&currentIndex=${i.toString()}');
              },
//// /web?url=${Uri.encodeComponent(linkUrl)}&title=${Uri.encodeComponent('掘金沸点')}


//        var bodyJson = '{"url":'+cellItem.url+',"title":'+cellItem.modName+'}';
            //        url = "/web/$bodyJson";
onPressed: () {
                  var bodyJson = '{"user":1281,"pass":3041}';
                  router.navigateTo(context, '/home/$bodyJson');
                  // Perform some action
                },


          */
