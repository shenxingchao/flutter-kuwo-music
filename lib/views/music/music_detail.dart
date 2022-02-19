import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutterkuwomusic/appbar.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';

import '../../store/store.dart';
import '../../utils/request.dart';

class MusicDetailComponent extends StatefulWidget {
  const MusicDetailComponent({Key? key}) : super(key: key);

  @override
  _MusicDetailComponentState createState() => _MusicDetailComponentState();
}

class _MusicDetailComponentState extends State<MusicDetailComponent> {
  //歌词列表
  List lrcList = [];

  @override
  void initState() {
    super.initState();
    //获取歌词
    getLrcList();
  }

  //获取歌词
  Future getLrcList() async {
    if (Get.find<Store>().playMusicInfo != null) {
      var res = await Request.http(
          url: 'music/getLrcList',
          type: 'get',
          data: {"musicId": Get.find<Store>().playMusicInfo?.rid}).then((res) {
        return res;
      }).catchError((error) {
        Fluttertoast.showToast(
          msg: "请求服务器错误",
        );
      });
      if (mounted && res != null) {
        setState(() {
          lrcList = res.data["data"]["lrclist"];
          print(lrcList);
        });
      }
      return res;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<Store>(
        //初始化store控制器
        init: Store(),
        builder: (store) {
          return Scaffold(
              extendBodyBehindAppBar: true,
              appBar: AppBarComponent(
                  Text(
                    store.playMusicInfo != null
                        ? store.playMusicInfo!.name
                        : '暂无',
                    style: const TextStyle(color: Colors.white),
                  ),
                  centerTitle: true,
                  appBarHeight: 66.0,
                  elevation: 0,
                  shadowColor: Colors.transparent,
                  backgroundColor: Colors.transparent,
                  leftIconColor: Colors.white),
              body: Stack(
                children: [
                  Positioned(
                      child: SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                    child: store.playMusicInfo != null
                        ? Image.network(
                            store.playMusicInfo!.pic,
                            alignment: Alignment.center,
                            fit: BoxFit.cover,
                          )
                        : Image.asset(
                            'assets/images/icons/music.png',
                            alignment: Alignment.center,
                            fit: BoxFit.cover,
                          ),
                  )),
                  //高斯模糊滤镜
                  BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 50.0, sigmaY: 50.0),
                    child: Center(
                      child: Container(
                        color: Colors.black.withOpacity(0.5),
                      ),
                    ),
                  ),
                  SafeArea(
                      child: Column(
                    children: [
                      Expanded(
                        flex: 1,
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                flex: 1,
                                child: SingleChildScrollView(
                                    child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    ...lrcList
                                        .map((item) => Container(
                                              height: 40,
                                              alignment: Alignment.center,
                                              child: Text(
                                                item["lineLyric"],
                                                style: const TextStyle(
                                                    fontSize: 16,
                                                    color: Colors.white),
                                              ),
                                            ))
                                        .toList()
                                  ],
                                )),
                              ),
                            ]),
                      )
                    ],
                  ))
                ],
              ));
        });
  }
}
