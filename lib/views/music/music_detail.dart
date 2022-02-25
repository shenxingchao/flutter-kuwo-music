import 'dart:async';
import 'dart:ui';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutterkuwomusic/component/appbar.dart';
import 'package:flutterkuwomusic/interface/play_mode.dart';
import 'package:flutterkuwomusic/utils/play_audio.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';

import '../../store/store.dart';
import '../../utils/request.dart';
import '../common/bottom_bar.dart';

class MusicDetailComponent extends StatefulWidget {
  const MusicDetailComponent({Key? key}) : super(key: key);

  @override
  _MusicDetailComponentState createState() => _MusicDetailComponentState();
}

class _MusicDetailComponentState extends State<MusicDetailComponent> {
  //歌词容器key 用于获取容器高度
  GlobalKey lrcContinerKey = GlobalKey();
  double lrcContainerHeight = 0;
  //歌词列表
  List lrcList = [];
  //当前播放进度 秒
  double audioDuration = 0;
  String audioDurationFormat = '00:00';

  //初始化滚动视图控制器
  ScrollController scrollController = ScrollController(initialScrollOffset: 0);

  //播放进度监听
  late StreamSubscription<Duration> audioPositionListen;
  //当前滚动位置的歌词索引
  int positionIndex = 0;

  //当前显示状态 歌词false 封面true
  bool showCover = false;

  //播放百分比
  double audioPercent = 0;

  @override
  void initState() {
    super.initState();
    //初始化歌词容器高度 并获取歌词
    initLrcContainerHeight();
    //播放进度监听
    audioProgressListen();
  }

  @override
  void dispose() {
    //为了避免内存泄露，需要调用_controller.dispose
    scrollController.dispose();
    audioPositionListen.cancel();
    super.dispose();
  }

  //初始化歌词容器高度 并获取歌词
  initLrcContainerHeight() async {
    //获取歌词
    await getLrcList();
    if (mounted) {
      setState(() {
        RenderBox? renderBox =
            lrcContinerKey.currentContext?.findRenderObject() as RenderBox;
        lrcContainerHeight = renderBox.size.height;
      });
    }
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
      if (mounted &&
          res != null &&
          res.data != null &&
          res.data["data"] != null &&
          res.data["data"]["lrclist"] != null) {
        setState(() {
          lrcList = res.data["data"]["lrclist"];
          positionIndex = 0;
          scrollController.jumpTo(0.0);
        });
      }
      return res;
    }
  }

  //播放进度监听
  audioProgressListen() {
    audioPositionListen = PlayAudio.instance.audioPlayer.onAudioPositionChanged
        .listen((Duration p) {
      setState(() {
        //当前播放进度 秒
        audioDuration = p.inMilliseconds / 1000;
        //播放百分比
        audioPercent =
            audioDuration / Get.find<Store>().playMusicInfo!.duration > 1
                ? 1
                : audioDuration / Get.find<Store>().playMusicInfo!.duration;
        //当前播放进度格式化
        audioDurationFormat = ((audioDuration / 60).floor() < 10
                ? '0' + (audioDuration / 60).floor().toString()
                : (audioDuration / 60).floor().toString()) +
            ":" +
            ((audioDuration % 60).floor() < 10
                ? '0' + (audioDuration % 60).floor().toString()
                : (audioDuration % 60).floor().toString());
        //根据播放进度判断在这个时间所在的索引 然后滚动到这个索引位置的歌词
        var index = 0;
        for (var i = 0; i < lrcList.length; i++) {
          var item = lrcList[i];
          if (double.parse(item["time"]) > audioDuration) {
            break;
          }
          index = i;
        }

        if (positionIndex != index) {
          //需要滚动
          positionIndex = index;
          //从第5行开始滚动 且当前滚动位置小于最大滚动位置 滚动到底部就不滚动了
          if (positionIndex > 5 &&
              (scrollController.position.pixels <
                      scrollController.position.maxScrollExtent ||
                  positionIndex < lrcList.length - 6)) {
            double offsetScroll =
                (positionIndex - 5) * (lrcContainerHeight / 11);
            scrollController.animateTo(
              offsetScroll,
              duration: const Duration(milliseconds: 200),
              curve: Curves.ease,
            );
          }
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<Store>(
        //初始化store控制器
        init: Store(),
        builder: (store) {
          //歌曲播放状态监听
          audioStateListen(store);
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
                //状态栏样式
                systemOverlayStyle: const SystemUiOverlayStyle(
                  statusBarBrightness: Brightness.light,
                  statusBarIconBrightness: Brightness.light,
                ),
              ),
              body: Stack(
                children: [
                  Positioned(
                      child: SizedBox(
                    width: Get.width,
                    height: Get.height,
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
                    filter: ImageFilter.blur(sigmaX: 30.0, sigmaY: 30.0),
                    child: Center(
                      child: Container(
                        color: Colors.black.withOpacity(0.5),
                      ),
                    ),
                  ),
                  SafeArea(
                      child: Column(
                    children: [
                      Offstage(
                        offstage: !showCover,
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          child: SizedBox(
                            width: Get.width,
                            height: Get.width,
                            child: store.playMusicInfo != null
                                ? Center(
                                    child: Image.network(
                                      store.playMusicInfo!.pic,
                                      alignment: Alignment.center,
                                      fit: BoxFit.cover,
                                      width: Get.width / 5 * 3,
                                      height: Get.width / 5 * 3,
                                    ),
                                  )
                                : const SizedBox(),
                          ),
                          onTap: () {
                            setState(() {
                              showCover = false;
                            });
                          },
                        ),
                      ),
                      Expanded(
                          flex: 1,
                          child: Offstage(
                            offstage: showCover,
                            child: LayoutBuilder(builder: (BuildContext context,
                                BoxConstraints constraints) {
                              //利用LayoutBuilder获取父容器宽高constraints.maxHeight 457
                              return GestureDetector(
                                  key: lrcContinerKey,
                                  child: SizedBox(
                                    width: Get.width,
                                    child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Expanded(
                                            flex: 1,
                                            child: SingleChildScrollView(
                                                controller: scrollController,
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    ...lrcList
                                                        .asMap()
                                                        .entries
                                                        .map(
                                                            (entry) =>
                                                                Container(
                                                                  height: constraints
                                                                          .maxHeight /
                                                                      11,
                                                                  alignment:
                                                                      Alignment
                                                                          .center,
                                                                  child: Text(
                                                                    entry.value[
                                                                        "lineLyric"],
                                                                    maxLines: 1,
                                                                    overflow:
                                                                        TextOverflow
                                                                            .ellipsis,
                                                                    style: TextStyle(
                                                                        fontSize: positionIndex == entry.key
                                                                            ? 20
                                                                            : 16,
                                                                        color: positionIndex ==
                                                                                entry.key
                                                                            ? Colors.white
                                                                            : const Color(0xff999999)),
                                                                  ),
                                                                ))
                                                        .toList(),
                                                  ],
                                                )),
                                          ),
                                        ]),
                                  ),
                                  onTap: () {
                                    setState(() {
                                      showCover = true;
                                    });
                                  });
                            }),
                          )),
                      Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        child: Container(
                                            padding: const EdgeInsets.all(10),
                                            child: Row(children: [
                                              store.getMusicLikeState(
                                                      store.playMusicInfo?.rid)
                                                  ? const Icon(
                                                      Icons.favorite_rounded,
                                                      size: 30,
                                                      color: Colors.red)
                                                  : const Icon(
                                                      Icons
                                                          .favorite_border_rounded,
                                                      size: 30,
                                                      color: Colors.grey),
                                            ])),
                                        onTap: () async {
                                          if (store.playMusicInfo != null) {
                                            await store.setLikeState(
                                                store.playMusicInfo?.rid);
                                            setState(() {});
                                          }
                                        },
                                      ))
                                ]),
                            Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    audioDurationFormat,
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: SliderTheme(
                                      data: SliderTheme.of(context).copyWith(
                                          trackHeight: 0.2,
                                          inactiveTrackColor: Colors.white),
                                      child: Slider(
                                        value: audioPercent,
                                        onChanged: (v) {
                                          if (store.playMusicInfo != null) {
                                            //拖动后毫秒数
                                            double second =
                                                store.playMusicInfo!.duration *
                                                    v;
                                            int microseconds =
                                                (second * 1000 * 1000).round();
                                            PlayAudio.instance.seekAudio(
                                                microseconds: microseconds);
                                          }
                                        },
                                        max: 1.0,
                                        min: 0,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    store.playMusicInfo != null
                                        ? store.playMusicInfo!.songTimeMinutes
                                        : '00:00',
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ]),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      child: Container(
                                          padding: const EdgeInsets.all(10),
                                          child: Row(
                                            children: [
                                              //单曲播放
                                              Offstage(
                                                offstage: store.playMode !=
                                                    PlayMode.SINGLE_MODE,
                                                child: const Icon(
                                                    Icons.looks_one_outlined,
                                                    size: 20,
                                                    color: Color(0xaaffffff)),
                                              ),
                                              //循环播放
                                              Offstage(
                                                offstage: store.playMode !=
                                                    PlayMode.LIST_FOR_MODE,
                                                child: const Icon(
                                                    Icons.repeat_rounded,
                                                    size: 20,
                                                    color: Color(0xaaffffff)),
                                              ),
                                              //顺序播放
                                              Offstage(
                                                offstage: store.playMode !=
                                                    PlayMode.LIST_MODE,
                                                child: const Icon(
                                                    Icons.playlist_play_rounded,
                                                    size: 20,
                                                    color: Color(0xaaffffff)),
                                              ),
                                              //单曲循环
                                              Offstage(
                                                offstage: store.playMode !=
                                                    PlayMode.SINGLE_FOR_MODE,
                                                child: const Icon(
                                                    Icons.repeat_one_rounded,
                                                    size: 20,
                                                    color: Color(0xaaffffff)),
                                              ),
                                              //随机播放
                                              Offstage(
                                                offstage: store.playMode !=
                                                    PlayMode.RANDOM_MODE,
                                                child: const Icon(
                                                    Icons.shuffle_rounded,
                                                    size: 20,
                                                    color: Color(0xaaffffff)),
                                              )
                                            ],
                                          )),
                                      onTap: () {
                                        //切换下一种播放模式
                                        store.changePlayMode();
                                      },
                                    )),
                                Row(
                                  children: [
                                    Material(
                                        color: Colors.transparent,
                                        child: InkWell(
                                          child: Container(
                                            padding: const EdgeInsets.all(10),
                                            child: const Icon(
                                                Icons.skip_previous_rounded,
                                                size: 40,
                                                color: Colors.white),
                                          ),
                                          onTap: () => {
                                            //播放上一首
                                            store.playPrevMusic()
                                          },
                                        )),
                                    Material(
                                        color: Colors.transparent,
                                        child: InkWell(
                                          child: Container(
                                            padding: const EdgeInsets.all(10),
                                            child: Icon(
                                                store.audioPlayState ==
                                                        PlayerState.PLAYING
                                                    ? Icons
                                                        .pause_circle_filled_rounded
                                                    : Icons
                                                        .play_circle_filled_rounded,
                                                size: 70,
                                                color: Colors.white),
                                          ),
                                          onTap: () {
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
                                          },
                                        )),
                                    Material(
                                        color: Colors.transparent,
                                        child: InkWell(
                                          child: Container(
                                            padding: const EdgeInsets.all(10),
                                            child: const Icon(
                                                Icons.skip_next_rounded,
                                                size: 40,
                                                color: Colors.white),
                                          ),
                                          onTap: () => {
                                            //播放下一首
                                            store.playNextMusic()
                                          },
                                        )),
                                  ],
                                ),
                                Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    child: Container(
                                      padding: const EdgeInsets.all(10),
                                      child: const Icon(Icons.menu_rounded,
                                          size: 20, color: Color(0xaaffffff)),
                                    ),
                                    onTap: () => {
                                      //显示下拉弹出方法
                                      showModalBottomSheet<void>(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return const PlayListBottomSheetWidget();
                                          })
                                    },
                                  ),
                                )
                              ],
                            )
                          ],
                        ),
                      )
                    ],
                  ))
                ],
              ));
        });
  }

  //开始播放，如果歌词为空，则尝试获取歌词,
  void audioStateListen(Store store) {
    if (store.audioPlayState == PlayerState.STOPPED ||
        store.audioPlayState == PlayerState.COMPLETED) {
      //播放完毕清空歌词
      lrcList = [];
    }
    if (store.audioPlayState == PlayerState.PLAYING && lrcList.isEmpty) {
      //重置歌词 等待2秒获取歌词 因为此时当前播放为空 所以不能获取歌词  获取歌词判断的逻辑有问题 必须要有歌曲播放才能获取 要判断当前是否切换了下一首
      getLrcList();
    }
  }
}
