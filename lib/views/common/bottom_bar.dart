//通用底部播放工具条
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../store/store.dart';
import '../../utils/play_audio.dart';

class PlayMusicBottomBar extends StatefulWidget {
  const PlayMusicBottomBar({Key? key}) : super(key: key);

  @override
  _PlayMusicBottomBarState createState() => _PlayMusicBottomBarState();
}

class _PlayMusicBottomBarState extends State<PlayMusicBottomBar>
    with SingleTickerProviderStateMixin {
  //定义动画控制器
  late AnimationController animationController;

  @override
  void initState() {
    super.initState();
    initAnimation();
  }

  @override
  void dispose() {
    //路由销毁时需要释放动画资源
    animationController.dispose();
    super.dispose();
  }

  //初始化旋转动画
  void initAnimation() {
    //初始化动画控制器
    animationController =
        AnimationController(duration: const Duration(seconds: 6), vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<Store>(
        //初始化store控制器
        init: Store(),
        builder: (store) {
          audioListen(store);
          return Row(
            children: [
              Expanded(
                flex: 1,
                child: Container(
                  height: 60,
                  padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                  //定义样式
                  decoration: const BoxDecoration(
                      //边框
                      border: Border(
                        top: BorderSide(
                          width: 0.5, //宽度
                          color: Color(0xffcccccc), //边框颜色
                        ),
                      ),
                      color: Colors.white),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      RotationTransition(
                        turns: animationController
                          ..addStatusListener((status) {
                            if (store.audioPlayState == PlayerState.PLAYING &&
                                status == AnimationStatus.completed) {
                              animationController.reset();
                              animationController.forward();
                            }
                          }),
                        //设置动画的旋转中心
                        alignment: Alignment.center,
                        child: ClipOval(
                            child: store.playMusicInfo != null &&
                                    store.playMusicInfo!.pic120 != ''
                                ? Image.network(
                                    store.playMusicInfo!.pic120,
                                    alignment: Alignment.center,
                                    //图片适应父组件方式  cover:等比缩放水平垂直直到2者都填满父组件 其他的没啥用了
                                    fit: BoxFit.cover,
                                    width: 50,
                                    height: 50,
                                    errorBuilder: (BuildContext context,
                                        Object exception,
                                        StackTrace? stackTrace) {
                                      return Image.asset(
                                        'assets/images/default.png',
                                        fit: BoxFit.cover,
                                        width: 50,
                                        height: 50,
                                      );
                                    },
                                  )
                                : Image.asset(
                                    'assets/images/icons/music.png',
                                    fit: BoxFit.cover,
                                    width: 50,
                                    height: 50,
                                  )),
                      ),
                      Expanded(
                          flex: 1,
                          child: Container(
                            margin: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                            child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    store.playMusicInfo != null
                                        ? store.playMusicInfo!.name
                                        : '音乐就要免费听',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Offstage(
                                    offstage: store.playMusicInfo == null,
                                    child: Text(
                                      store.playMusicInfo != null
                                          ? store.playMusicInfo!.artist
                                          : '',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                          fontSize: 12.0,
                                          color: Color(0xff999999)),
                                    ),
                                  ),
                                ]),
                          )),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Material(
                              color: Colors.white,
                              child: InkWell(
                                child: Container(
                                  padding: const EdgeInsets.all(10),
                                  child: Icon(
                                      store.audioPlayState ==
                                              PlayerState.PLAYING
                                          ? Icons.pause_circle_outline_rounded
                                          : Icons.play_arrow_rounded,
                                      size: 30,
                                      color: const Color(0xff333333)),
                                ),
                                onTap: () {
                                  if (store.audioPlayState ==
                                      PlayerState.PLAYING) {
                                    //暂停
                                    PlayAudio.instance.audioPlayer.pause();
                                  }
                                  if (store.audioPlayState ==
                                          PlayerState.PAUSED ||
                                      store.audioPlayState ==
                                          PlayerState.COMPLETED) {
                                    //播放完了再继续播放
                                    PlayAudio.instance.audioPlayer.resume();
                                  }
                                },
                              )),
                          Material(
                              color: Colors.white,
                              child: InkWell(
                                child: Container(
                                  padding: const EdgeInsets.all(10),
                                  child: const Icon(Icons.skip_next_rounded,
                                      size: 30, color: Color(0xff333333)),
                                ),
                                onTap: () => {
                                  //播放下一首
                                  store.playNextMusic()
                                },
                              )),
                          Material(
                              color: Colors.white,
                              child: InkWell(
                                child: Container(
                                  padding: const EdgeInsets.all(10),
                                  child: const Icon(Icons.menu,
                                      size: 30, color: Color(0xff333333)),
                                ),
                                onTap: () => {
                                  //显示下拉弹出方法
                                  showModalBottomSheet<void>(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return Container(
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height /
                                                2,
                                            color: Colors.white,
                                            child: ListView(
                                              children: [
                                                ...store.playListMusic
                                                    .map((item) => Material(
                                                        color: Colors.white,
                                                        child: InkWell(
                                                          child: Column(
                                                              children: [
                                                                Container(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .all(10),
                                                                  height: 50,
                                                                  child: Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .spaceBetween,
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .center,
                                                                    children: [
                                                                      Expanded(
                                                                          flex:
                                                                              1,
                                                                          child:
                                                                              Column(
                                                                            mainAxisAlignment:
                                                                                MainAxisAlignment.spaceBetween,
                                                                            crossAxisAlignment:
                                                                                CrossAxisAlignment.start,
                                                                            children: [
                                                                              Column(
                                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                                children: [
                                                                                  Text(
                                                                                    item.name,
                                                                                    style: TextStyle(fontSize: 18, color: store.playMusicInfo?.rid == item.rid ? Theme.of(context).colorScheme.primary : const Color(0xff333333)),
                                                                                    maxLines: 1,
                                                                                    overflow: TextOverflow.ellipsis,
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                            ],
                                                                          )),
                                                                      Row(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.end,
                                                                        crossAxisAlignment:
                                                                            CrossAxisAlignment.end,
                                                                        children: [
                                                                          GestureDetector(
                                                                            child:
                                                                                const Icon(Icons.delete_outline_rounded, color: Color(0xffcccccc)),
                                                                            onTap: () =>
                                                                                {
                                                                              print("弹出下载")
                                                                            },
                                                                          ),
                                                                        ],
                                                                      )
                                                                    ],
                                                                  ),
                                                                ),
                                                                const Divider(
                                                                  height: 1,
                                                                  color: Color(
                                                                      0xffdddddd),
                                                                )
                                                              ]),
                                                          onTap: () {},
                                                        )))
                                              ],
                                            ));
                                      })
                                },
                              )),
                        ],
                      )
                    ],
                  ),
                ),
              )
            ],
          );
        });
  }

  //监听播放状态改变旋转动画
  void audioListen(Store store) {
    if (store.audioPlayState == PlayerState.PLAYING) {
      animationController.forward();
    }
    if (store.audioPlayState == PlayerState.PAUSED ||
        store.audioPlayState == PlayerState.STOPPED ||
        store.audioPlayState == PlayerState.COMPLETED) {
      animationController.stop();
    }
  }
}
