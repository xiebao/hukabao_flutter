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
import android.widget.Toast
import androidx.core.content.FileProvider
import android.provider.Settings
import androidx.annotation.RequiresApi

class MainActivity: FlutterActivity() {
  private val CHANNEL = "com.hukabao.flutter.xiebaoxin/channel"
  override fun onCreate(savedInstanceState: Bundle?) {
    super.onCreate(savedInstanceState)
    GeneratedPluginRegistrant.registerWith(this)
//    MethodChannel(flutterView, CHANNEL).setMethodCallHandler { methodCall, result -> }
    MethodChannel(flutterView, CHANNEL).setMethodCallHandler { methodCall, result ->
      when (methodCall.method) {
        "install" -> {
          var appfile = methodCall.argument<String>("appfile")
          openAPKFile(this,appfile)
        }
        "installtest" -> {
          var appfile = methodCall.argument<String>("appfile")
          openAPKFiletest(this,appfile)
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
  fun openAPKFile(mContext:Activity,fileUri: String?) {
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
              return;
            }
          }
          showToast(this, "002",Toast.LENGTH_SHORT)
        } else {
          showToast(this, "001",Toast.LENGTH_SHORT)
          intent.setDataAndType(Uri.fromFile(apkFile), "application/vnd.android.package-archive")
        // FLAG_ACTIVITY_NEW_TASK 可以保证安装成功时可以正常打开 app
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
  }

  /**
   * 跳转到设置-允许安装未知来源-页面
   */

  @RequiresApi(api = Build.VERSION_CODES.O)
  private fun startInstallPermissionSettingActivity(packageUri:Uri) {
    //注意这个是8.0新API
    val intent1 = Intent(Settings.ACTION_MANAGE_UNKNOWN_APP_SOURCES,packageUri)
    intent1.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
    startActivity(intent)
    startActivityForResult(intent1, 999)

  }


  private fun showToast(context: Context, message: String, duration: Int){
    println(message)
    Toast.makeText(context, message, duration).show()
  }


    fun openAPKFiletest(activity:Activity,filePath:String?){
      val intent = Intent(Intent.ACTION_VIEW)
      val apkFile = File(filePath)

        // 由于没有在Activity环境下启动Activity,设置下面的标签
        intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
      if (Build.VERSION.SDK_INT >= 24) { //判读版本是否在7.0以上
        showToast(this, "001",Toast.LENGTH_SHORT)
          //参数1 上下文, 参数2 Provider主机地址 和配置文件中保持一致  参数3  共享的文件
        val apkUri = FileProvider.getUriForFile(activity, activity.packageName + ".fileProvider", apkFile)          //添加这一句表示对目标应用临时授权该Uri所代表的文件
          intent.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
          intent.setDataAndType(apkUri, "application/vnd.android.package-archive")           //兼容8.0
          if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            showToast(this, "002",Toast.LENGTH_SHORT)
            val hasInstallPermission = activity.packageManager.canRequestPackageInstalls()
            if (!hasInstallPermission) {
              showToast(this, "003",Toast.LENGTH_SHORT)

              startInstallPermissionSettingActivity()
//              return
          }
          }
        } else {
        showToast(this, "004",Toast.LENGTH_SHORT)
          intent.setDataAndType(Uri.fromFile( apkFile), "application/vnd.android.package-archive")
        }
        activity.startActivity(intent)
      showToast(this, "ok",Toast.LENGTH_SHORT)


    /*  //兼容7.0
      if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
        intent.flags = Intent.FLAG_GRANT_READ_URI_PERMISSION
        val contentUri = FileProvider.getUriForFile(activity, activity.packageName + ".fileProvider", apkFile)
        intent.setDataAndType(contentUri, "application/vnd.android.package-archive")
        val intent = Intent(Settings.ACTION_MANAGE_UNKNOWN_APP_SOURCES)
        startActivityForResult(intent, RESULT_CODE)
        //兼容8.0
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
          val hasInstallPermission = activity.packageManager.canRequestPackageInstalls()
          if (!hasInstallPermission) {
            startInstallPermissionSettingActivity()
            return
          }
        }
      } else {
        intent.setDataAndType(Uri.fromFile(apkFile), "application/vnd.android.package-archive")
        intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
      }*/
      /*
        if (Build.VERSION.SDK_INT > Build.VERSION_CODES.M) {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {//新增8.0应用单个的安装权限判断
                activity?.let {
                    if (it.packageManager.canRequestPackageInstalls()) { //使用此方法判断该应用有没有打开允许安装未知应用的功能
                      showToast(this, ""+filePath,Toast.LENGTH_SHORT)
                    } else {
                        val intent = Intent(Settings.ACTION_MANAGE_UNKNOWN_APP_SOURCES)
                        startActivityForResult(intent, 999)
                    }
                }
            } else {
                activity?.apply {
                  showToast(this, "Build.VERSION.SDK_INT 《 Build.VERSION_CODES.O",Toast.LENGTH_SHORT)
                }
            }

        } else {
          showToast(this, "installAPP",Toast.LENGTH_SHORT)

        }*/
    }

  private fun installAPP(data: Uri, context: Context) {
    val promptInstall = Intent(Intent.ACTION_VIEW)
            .setDataAndType(data, "application/vnd.android.package-archive")
    // FLAG_ACTIVITY_NEW_TASK 可以保证安装成功时可以正常打开 app
    promptInstall.flags = Intent.FLAG_ACTIVITY_NEW_TASK
    context.startActivity(promptInstall)
  }

  fun install(context: Context, downloadfile: File) {
    val intent = Intent(Intent.ACTION_VIEW)
    val apkUri = FileProvider.getUriForFile(context, BuildConfig.APPLICATION_ID + ".fileprovider", downloadfile)
    intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
    intent.addFlags(Intent.FLAG_GRANT_WRITE_URI_PERMISSION)
    intent.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
    intent.setDataAndType(apkUri, "application/vnd.android.package-archive")
    context.startActivity(intent)

  }

  override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
    super.onActivityResult(requestCode, resultCode, data)
    if (requestCode == 999) {
      showToast(this, "操作了权限",Toast.LENGTH_SHORT)
    }
  }

}