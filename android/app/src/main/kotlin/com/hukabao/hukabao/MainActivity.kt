package com.hukabao.hukabao

import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.Bundle

import io.flutter.app.FlutterActivity
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant

import java.io.File
import android.app.Activity
import android.content.Context
import android.net.http.HttpResponseCache.install
import android.widget.Toast
import androidx.core.content.FileProvider
import android.provider.Settings
import androidx.annotation.RequiresApi

class MainActivity: FlutterActivity() {
  private val CHANNEL = "com.hukabao.flutter.xiebaoxin/channel"
  private var apkfilefstr:String? = null
  override fun onCreate(savedInstanceState: Bundle?) {
    super.onCreate(savedInstanceState)
    GeneratedPluginRegistrant.registerWith(this)
//    MethodChannel(flutterView, CHANNEL).setMethodCallHandler { methodCall, result -> }
    MethodChannel(flutterView, CHANNEL).setMethodCallHandler { methodCall, result ->
      when (methodCall.method) {
        "install" -> {
          var appfile = methodCall.argument<String>("appfile")
          this.apkfilefstr = appfile;
         if( openAPKFile(this,appfile))
            result.success("YES")
          else
           result.success("NO")
        }
        "showToast" -> showToast(this, "message",Toast.LENGTH_SHORT)
        "othermsg" -> {
          //调用传来的参数"othermsg"对应的值
          val msg = methodCall.argument<String>("msg")
          //调用本地Toast的方法
          Toast.makeText(this, msg, Toast.LENGTH_SHORT).show()
          //回调给客户端
          result.success("native android toast success")
        }
        else -> {
          result.success("")
        }
      }
      result.success(null) //没有返回值，所以直接返回为null
//      result.notImplemented()

    }

  }


  /**
   * 打开安装包
   */
  fun openAPKFile(mContext:Activity,fileUri: String?) :Boolean {
    // 核心是下面几句代码
    if (null != fileUri) {
      try {
        val intent = Intent(Intent.ACTION_VIEW)
        val apkFile = File(fileUri)
        //兼容7.0
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
          intent.flags = Intent.FLAG_GRANT_READ_URI_PERMISSION
          val contentUri = FileProvider.getUriForFile(mContext, mContext.packageName + ".fileProvider", apkFile)
          intent.setDataAndType(contentUri, "application/vnd.android.package-archive")
          //兼容8.0
          if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val hasInstallPermission = mContext.packageManager.canRequestPackageInstalls()

            if (!hasInstallPermission) {
              showToast(this, "003",Toast.LENGTH_SHORT)
              startInstallPermissionSettingActivity()
              return false;
            }
          }
          showToast(this, "002",Toast.LENGTH_SHORT)
        } else {
          showToast(this, "001",Toast.LENGTH_SHORT)
          intent.setDataAndType(Uri.fromFile(apkFile), "application/vnd.android.package-archive")
          intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
        }

        if (mContext.packageManager.queryIntentActivities(intent, 0).size > 0) {
          showToast(this, "开始安装了",Toast.LENGTH_SHORT)
          mContext.startActivity(intent)
        }

      } catch (e: Throwable) {
        e.printStackTrace()
      }
    }
    return true;
  }


  @RequiresApi(api = Build.VERSION_CODES.O)
  private fun startInstallPermissionSettingActivity() {
    //注意这个是8.0新API
    val packageURI = Uri.parse("package:$packageName")
    val intent = Intent(Settings.ACTION_MANAGE_UNKNOWN_APP_SOURCES,packageURI)
    intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
    startActivityForResult(intent, 100)
  }

  override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
    super.onActivityResult(requestCode, resultCode, data)
    if (requestCode == 100 && resultCode == RESULT_OK) {
      installApk(this.apkfilefstr);
    }

  }

  private fun showToast(context: Context, message: String, duration: Int){
    println(message)
    Toast.makeText(context, message, duration).show()
  }


 private fun installApk( apkUrl:String?) {
  val intent = Intent(Intent.ACTION_VIEW);
   if (Build.VERSION.SDK_INT < Build.VERSION_CODES.N) {
    intent.setDataAndType(Uri.fromFile(File(apkUrl)),"applicationnd.android.package-archive");
  } else {//Android7.0之后获取uri要用contentProvider
    val apkUri =FileProvider.getUriForFile(this, this.packageName + ".fileProvider", File(apkUrl));
     //添加这一句表示对目标应用临时授权该Uri所代表的文件
    intent.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION);
    intent.setDataAndType(apkUri, "applicationnd.android.package-archive");
    intent.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION);
  }
  intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
  startActivity(intent)
}

}