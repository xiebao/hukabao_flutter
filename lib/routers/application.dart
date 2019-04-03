import 'package:fluro/fluro.dart';
import '../utils/HttpUtils.dart';
import '../utils/DialogUtils.dart';
import '../model/globle_model.dart';

class Application {
  static Router router;
  static void run(context, url) async{
    if (url.startsWith('/web?')) {
//web页面是否过期
      final model = globleModel().of(context);
      print("------Application---Router------${model.token}------------");
      if(model.token=='')
        DialogUtils.close2Logout(context);
      else{
        HttpUtils.request(
            'Index/checktoken/token/${model.token}', data: {}, method: 'post')
            .then((response) {
          if (response["error_code"].toString() == '1') {
            Application.router.navigateTo(
                context, url, transition: TransitionType.fadeIn);
          } else
            DialogUtils.close2Logout(context);
        });
      }
    }
    else
      Application.router.navigateTo(context, url,transition: TransitionType.native);
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


onPressed: () {
                  var bodyJson = '{"user":1281,"pass":3041}';
                  router.navigateTo(context, '/home/$bodyJson');
                  // Perform some action
                },


          */
