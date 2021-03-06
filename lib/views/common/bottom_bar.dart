//通用底部播放工具条
import 'package:audioplayers/audioplayers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutterkuwomusic/views/common/play_list_bottom_sheet.dart';
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
        AnimationController(duration: const Duration(seconds: 12), vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<Store>(
        //初始化store控制器
        init: Store(),
        builder: (store) {
          audioListen(store);
          return GestureDetector(
              child: Row(
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
                              width: 0.4, //宽度
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
                                if (store.audioPlayState ==
                                        PlayerState.PLAYING &&
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
                                    ? CachedNetworkImage(
                                        imageUrl: store.playMusicInfo!.pic120,
                                        alignment: Alignment.center,
                                        fit: BoxFit.cover,
                                        width: 50,
                                        height: 50,
                                        errorWidget: (context, url, error) =>
                                            Image.asset(
                                              'assets/images/default.png',
                                              fit: BoxFit.cover,
                                              width: 50,
                                              height: 50,
                                            ))
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                          store.playMusicInfo != null
                                              ? store.playMusicInfo!.name
                                              : '音乐就要免费听',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: 14.0,
                                          )),
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
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Material(
                                  color: Colors.white,
                                  child: InkWell(
                                    child: Container(
                                      padding: const EdgeInsets.all(10),
                                      child: Icon(
                                          store.audioPlayState ==
                                                  PlayerState.PLAYING
                                              ? Icons
                                                  .pause_circle_outline_rounded
                                              : Icons.play_arrow_rounded,
                                          size: 24,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary),
                                    ),
                                    onTap: () {
                                      if (store.audioPlayState ==
                                          PlayerState.PLAYING) {
                                        //暂停
                                        PlayAudio.instance.pauseAudio();
                                      }
                                      if (store.audioPlayState ==
                                              PlayerState.PAUSED ||
                                          store.audioPlayState ==
                                              PlayerState.COMPLETED) {
                                        //播放完了再继续播放
                                        PlayAudio.instance.resumeAudio();
                                      }
                                    },
                                  )),
                              Material(
                                  color: Colors.white,
                                  child: InkWell(
                                    child: Container(
                                      padding: const EdgeInsets.all(10),
                                      child: Icon(Icons.skip_next_rounded,
                                          size: 24,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary),
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
                                      child: Icon(Icons.menu,
                                          size: 24,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary),
                                    ),
                                    onTap: () => {
                                      //显示下拉弹出方法
                                      showModalBottomSheet<void>(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return const PlayListBottomSheetWidget();
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
              ),
              onTap: () {
                Get.toNamed('music_detail');
              });
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
