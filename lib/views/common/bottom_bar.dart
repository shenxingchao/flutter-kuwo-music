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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                              fontSize: 10.0,
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

//正在播放的歌曲列表，弹出的下拉框
class PlayListBottomSheetWidget extends StatefulWidget {
  const PlayListBottomSheetWidget({Key? key}) : super(key: key);

  @override
  _PlayListBottomSheetWidgetState createState() =>
      _PlayListBottomSheetWidgetState();
}

class _PlayListBottomSheetWidgetState extends State<PlayListBottomSheetWidget> {
  //初始化滚动视图控制器
  ScrollController scrollController = ScrollController();

  @override
  void dispose() {
    //为了避免内存泄露，需要调用_controller.dispose
    scrollController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    initScrollOffset();
  }

  //初始化弹窗的滚动条位置 为当前播放的歌曲 如果没有则初始化到顶部
  void initScrollOffset() {
    //查找当前正在播放的索引
    int playingIndex = Get.find<Store>().getPlayingIndex();

    scrollController =
        ScrollController(initialScrollOffset: 72.0 * playingIndex);
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<Store>(
        //初始化store控制器
        init: Store(),
        builder: (store) {
          return Container(
              height: Get.height / 2,
              color: Colors.white,
              child: Column(
                children: [
                  SizedBox(
                    height: 50,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Row(children: [
                                Container(
                                  margin: const EdgeInsets.fromLTRB(0, 0, 5, 0),
                                  child: const Icon(Icons.play_circle_outline,
                                      color: Color(0xff333333)),
                                ),
                                Text(
                                  '播放全部/' +
                                      store.playListMusic.length.toString() +
                                      '首',
                                  style: const TextStyle(fontSize: 16),
                                )
                              ]),
                            ),
                            onTap: () {
                              //播放第一首
                              store.playMusic(rid: store.playListMusic[0].rid);
                            }),
                        GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Row(children: const [Text('清空列表')]),
                            ),
                            onTap: () {
                              store.changePlayListMusic([]);
                            })
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: ListView(
                      controller: scrollController,
                      children: [
                        ...store.playListMusic.map((item) => Material(
                            color: Colors.white,
                            child: InkWell(
                              child: Column(children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  height: 72,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Offstage(
                                        offstage: store.playMusicInfo?.rid !=
                                            item.rid,
                                        child: Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              0, 0, 10, 0),
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(4),
                                            child: Image.network(
                                              item.pic120,
                                              alignment: Alignment.center,
                                              //图片适应父组件方式  cover:等比缩放水平垂直直到2者都填满父组件 其他的没啥用了
                                              fit: BoxFit.cover,
                                              width: 50,
                                              height: 50,
                                              errorBuilder:
                                                  (BuildContext context,
                                                      Object exception,
                                                      StackTrace? stackTrace) {
                                                return Image.asset(
                                                  'assets/images/default.png',
                                                  fit: BoxFit.cover,
                                                  width: 50,
                                                  height: 50,
                                                );
                                              },
                                            ),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                          flex: 1,
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                item.name
                                                    .replaceAll('&nbsp;', ' '),
                                                style: const TextStyle(
                                                    fontSize: 18),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              Text(
                                                item.artist
                                                    .replaceAll('&nbsp;', ' '),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                    color: Color(0xff999999)),
                                              ),
                                            ],
                                          )),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          //当前播放歌曲才显示收藏按钮
                                          store.playMusicInfo?.rid == item.rid
                                              ? Offstage(
                                                  offstage: store
                                                          .playMusicInfo?.rid !=
                                                      item.rid,
                                                  child: GestureDetector(
                                                      child: store
                                                              .getMusicLikeState(
                                                                  item.rid)
                                                          ? const Icon(
                                                              Icons
                                                                  .favorite_rounded,
                                                              size: 30,
                                                              color: Colors.red)
                                                          : const Icon(
                                                              Icons
                                                                  .favorite_border_rounded,
                                                              size: 30,
                                                              color: Color(
                                                                  0xffC3CADE)),
                                                      onTap: () async {
                                                        await store
                                                            .setLikeState(
                                                                item.rid);
                                                        setState(() {});
                                                      }))
                                              : const SizedBox(),
                                          GestureDetector(
                                            child: Icon(
                                                store.playMusicInfo?.rid ==
                                                            item.rid &&
                                                        store.audioPlayState ==
                                                            PlayerState.PLAYING
                                                    ? Icons.pause_circle
                                                    : Icons.play_circle,
                                                size: 30,
                                                color: const Color(0xffC3CADE)),
                                            onTap: () {
                                              if (store.playMusicInfo?.rid ==
                                                  item.rid) {
                                                if (store.audioPlayState ==
                                                    PlayerState.PLAYING) {
                                                  //暂停
                                                  PlayAudio.instance.audioPlayer
                                                      .pause();
                                                }
                                                if (store.audioPlayState ==
                                                        PlayerState.PAUSED ||
                                                    store.audioPlayState ==
                                                        PlayerState.COMPLETED) {
                                                  //播放完了再继续播放
                                                  PlayAudio.instance.audioPlayer
                                                      .resume();
                                                }
                                              } else {
                                                //直接播放
                                                store.playMusic(rid: item.rid);
                                              }
                                            },
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                )
                              ]),
                              onTap: () {
                                //直接播放
                                store.playMusic(rid: item.rid);
                              },
                            )))
                      ],
                    ),
                  )
                ],
              ));
        });
  }
}
