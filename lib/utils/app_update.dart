import 'dart:io';
import 'package:package_info/package_info.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:open_file/open_file.dart';
import './request.dart';

class AppUpdate {
  late String _version; //版本号
  late String savePath; //文件存储路径
  late String downloadUrl; //下载路径
  bool _permision = false; //是否有存储权限
  bool canUpdate = false; //是否可以更新


  init() async {
    //获取版本号
    await _getVersion();
    //获取文件存储路径
    await _findLocalPath();
    //检查权限
    await _checkPermission();
  }

  //获取版本号 pubspec.yaml version: 1.0.0+1  版本号+构件号 一般改前面的就行
  _getVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    _version = packageInfo.version;
  }

  //获取文件存储路径
  Future _findLocalPath() async {
    var directory = Platform.isAndroid
        ? await getExternalStorageDirectory()
        : await getApplicationDocumentsDirectory();
    savePath = directory!.path + "/app-release.apk";
  }

  //检测存储权限
  _checkPermission() async {
    if (Platform.isAndroid) {
      //获取状态
      var status = await Permission.storage.status;
      //如果没有授权，请求授权
      if (!status.isGranted) {
        if (await Permission.storage.request().isGranted) {
          //授权了
          _permision = true;
        } else {
          //拒绝授权
          _permision = false;
        }
      } else {
        //已经授权了
        _permision = true;
      }
    } else {
      //ios
      _permision = true;
    }
  }

  checkUpdate() async {
    //有权限
    if (_permision) {
      //获取版本信息 这里的http dio章节封装好了自己看
      await Request.http(url: '/version/app.json', type: 'get', data: {})
          .then((res) {
        //比对版本号 若有新版本则下载
        downloadUrl = res.data['url'];
        if (res.data["version"] != _version) {
          //有新版本需要更新
          canUpdate = true;
        }
      }).catchError((error) {});
    }
  }

  //安装Apk
  installApk() async {
    await OpenFile.open(savePath);
  }
}
