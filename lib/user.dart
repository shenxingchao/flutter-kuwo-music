import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:package_info/package_info.dart';

import './component/loading.dart';

class UserCommponent extends StatefulWidget {
  const UserCommponent({Key? key}) : super(key: key);

  @override
  _UserCommponentState createState() => _UserCommponentState();
}

class _UserCommponentState extends State<UserCommponent> {
  late PackageInfo packageInfo;

  bool _showLoading = true;

  @override
  void initState() {
    super.initState();
    _getPackageInfo();
  }

  //获取版本信息
  _getPackageInfo() async {
    packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      _showLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return !_showLoading
        ? ListView(
            //垂直列表 水平列表有滚动条哦
            scrollDirection: Axis.vertical,
            children: [
              Container(
                color: Colors.white,
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('当前版本：' +
                        packageInfo.version +
                        "." +
                        packageInfo.buildNumber +
                        " ©by sxc 2022/2/13"),
                    const Text(
                        "本软件仅用于学习用途，接口皆来自于网络，版权归酷我所有，请在法律允许的范围内使用。如有侵权，请联系本人删除",
                        style:
                            TextStyle(fontSize: 12, color: Color(0xff999999)))
                  ],
                ),
              ),
              Container(
                width: Get.width,
                padding: const EdgeInsets.fromLTRB(30, 50, 30, 50),
                color: Colors.white,
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Material(
                          color: Colors.white,
                          child: InkWell(
                            child: Column(children: const [
                              Icon(Icons.favorite_rounded,
                                  size: 30, color: Colors.red),
                              SizedBox(
                                height: 5,
                              ),
                              Text("收藏")
                            ]),
                            onTap: () {
                              Get.toNamed(
                                '/favourite_list',
                              );
                            },
                          ))
                    ]),
              ),
              const Divider(
                height: 1,
                color: Color(0xffdddddd),
              ),
              ListTile(
                leading: Icon(
                  Icons.history,
                  color: Theme.of(context).colorScheme.primary,
                ),
                trailing: const Icon(Icons.keyboard_arrow_right,
                    color: Color(0xff999999)),
                title: const Text('更新日志'),
                tileColor: Colors.white,
                onTap: () {
                  Get.toNamed(
                    '/history',
                  );
                },
              ),
            ],
          )
        : const Loading();
  }
}
