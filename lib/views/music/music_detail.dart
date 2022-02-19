import 'dart:async';
import 'dart:ui';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutterkuwomusic/appbar.dart';
import 'package:flutterkuwomusic/utils/play_audio.dart';
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
  //当前播放进度 秒
  double audioDuration = 0;

  //初始化滚动视图控制器
  ScrollController scrollController = ScrollController(initialScrollOffset: 0);

  //播放进度监听
  late StreamSubscription<Duration> audioPositionListen;
  //当前滚动位置的歌词索引
  int positionIndex = 0;

  @override
  void initState() {
    super.initState();
    //获取歌词
    getLrcList();
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
            double offsetScroll = ((positionIndex - 5) * 40);
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
                      SizedBox(
                        height: 440,
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
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
                                            .map((entry) => Container(
                                                  height: 40,
                                                  alignment: Alignment.center,
                                                  child: Text(
                                                    entry.value["lineLyric"],
                                                    style: TextStyle(
                                                        fontSize: 16,
                                                        color: positionIndex ==
                                                                entry.key
                                                            ? Colors.white
                                                            : const Color(
                                                                0xff999999)),
                                                  ),
                                                ))
                                            .toList(),
                                        // GestureDetector(
                                        //   child: Text('下一首'),
                                        //   onTap: () {
                                        //     store.playNextMusic();
                                        //   },
                                        // )
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
