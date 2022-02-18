import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutterkuwomusic/appbar.dart';
import 'package:get/get.dart';

import '../../store/store.dart';

class MusicDetailComponent extends StatefulWidget {
  const MusicDetailComponent({Key? key}) : super(key: key);

  @override
  _MusicDetailComponentState createState() => _MusicDetailComponentState();
}

class _MusicDetailComponentState extends State<MusicDetailComponent> {
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
                  leftIconColor: Colors.white,
                  systemOverlayStyle: const SystemUiOverlayStyle(
                      statusBarBrightness: Brightness.dark,
                      statusBarIconBrightness: Brightness.dark)),
              body: Stack(
                children: [
                  Positioned(
                    child: store.playMusicInfo != null
                        ? SizedBox(
                            width: MediaQuery.of(context).size.width,
                            height: MediaQuery.of(context).size.height,
                            child: Image.network(
                              store.playMusicInfo!.pic,
                              alignment: Alignment.center,
                              fit: BoxFit.cover,
                              //加滤镜
                              // color: Colors.black,
                              colorBlendMode: BlendMode.srcIn,
                            ),
                          )
                        : Container(
                            color: Colors.red,
                          ),
                  ),
                  //高斯模糊滤镜
                  BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 20.0, sigmaY: 20.0),
                    child: Center(
                      child: Container(
                        color: Colors.black.withOpacity(0.3),
                      ),
                    ),
                  ),
                  SafeArea(child: Text('333'))
                ],
              ));
        });
  }
}
