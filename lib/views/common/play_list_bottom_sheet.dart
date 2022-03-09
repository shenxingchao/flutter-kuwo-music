import 'package:audioplayers/audioplayers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../store/store.dart';
import '../../utils/play_audio.dart';

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
                              child: Row(children: const [
                                Text(
                                  '清空列表',
                                  style: TextStyle(fontSize: 16),
                                ),
                              ]),
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
                        ...store.playListMusic.asMap().entries.map((entry) {
                          var item = entry.value;
                          var key = entry.key;
                          return Dismissible(
                              key: Key(item.rid.toString()),
                              onDismissed: (direction) {
                                //删除并更新
                                store.playListMusic.removeAt(key);

                                store.changePlayListMusic(store.playListMusic,
                                    stopMusic:
                                        store.playMusicInfo?.rid == item.rid);
                              },
                              direction: DismissDirection.endToStart,
                              background: Container(
                                color: const Color(0xfff1f1f1),
                              ),
                              child: Material(
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
                                              offstage:
                                                  store.playMusicInfo?.rid !=
                                                      item.rid,
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.fromLTRB(
                                                        0, 0, 10, 0),
                                                child: ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            4),
                                                    child: CachedNetworkImage(
                                                        imageUrl: item.pic120,
                                                        alignment:
                                                            Alignment.center,
                                                        fit: BoxFit.cover,
                                                        width: 50,
                                                        height: 50,
                                                        errorWidget: (context,
                                                                url, error) =>
                                                            Image.asset(
                                                              'assets/images/default.png',
                                                              fit: BoxFit.cover,
                                                              width: 50,
                                                              height: 50,
                                                            ))),
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
                                                      item.name.replaceAll(
                                                          '&nbsp;', ' '),
                                                      style: const TextStyle(
                                                          fontSize: 16),
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                    Text(
                                                      item.artist.replaceAll(
                                                          '&nbsp;', ' '),
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: const TextStyle(
                                                          color: Color(
                                                              0xff999999)),
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
                                                store.playMusicInfo?.rid ==
                                                        item.rid
                                                    ? Offstage(
                                                        offstage: store
                                                                    .playMusicInfo
                                                                    ?.rid !=
                                                                item.rid ||
                                                            Get.currentRoute ==
                                                                '/favourite_list',
                                                        child: GestureDetector(
                                                            child: store.getMusicLikeState(
                                                                    item.rid)
                                                                ? const Icon(
                                                                    Icons
                                                                        .favorite_rounded,
                                                                    size: 30,
                                                                    color: Colors
                                                                        .red)
                                                                : const Icon(
                                                                    Icons
                                                                        .favorite_border_rounded,
                                                                    size: 30,
                                                                    color: Color(0xffC3CADE)),
                                                            onTap: () async {
                                                              await store
                                                                  .setLikeState(
                                                                      item.rid);
                                                              setState(() {});
                                                            }))
                                                    : const SizedBox(),
                                                GestureDetector(
                                                  child: Icon(
                                                      store.playMusicInfo
                                                                      ?.rid ==
                                                                  item.rid &&
                                                              store.audioPlayState ==
                                                                  PlayerState
                                                                      .PLAYING
                                                          ? Icons.pause_circle
                                                          : Icons.play_circle,
                                                      size: 30,
                                                      color: const Color(
                                                          0xffC3CADE)),
                                                  onTap: () {
                                                    if (store.playMusicInfo
                                                            ?.rid ==
                                                        item.rid) {
                                                      if (store
                                                              .audioPlayState ==
                                                          PlayerState.PLAYING) {
                                                        //暂停
                                                        PlayAudio.instance
                                                            .pauseAudio();
                                                      }
                                                      if (store.audioPlayState ==
                                                              PlayerState
                                                                  .PAUSED ||
                                                          store.audioPlayState ==
                                                              PlayerState
                                                                  .COMPLETED) {
                                                        //播放完了再继续播放
                                                        PlayAudio.instance
                                                            .resumeAudio();
                                                      }
                                                    } else {
                                                      //直接播放
                                                      store.playMusic(
                                                          rid: item.rid);
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
                                  )));
                        })
                      ],
                    ),
                  )
                ],
              ));
        });
  }
}