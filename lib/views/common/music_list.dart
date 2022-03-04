import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../store/store.dart';

//音乐列表
class MusicListWidget extends StatelessWidget {
  const MusicListWidget(
      {Key? key, required this.list, this.pageType = 0, this.callback})
      : super(key: key);

  final List list;
  //显示在哪个特殊页面 0 普通页面 1我的收藏（我喜欢）2已下载
  final int pageType;
  //回调函数
  final dynamic callback;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<Store>(
        //初始化store控制器
        init: Store(),
        builder: (store) {
          return SliverList(
              delegate: SliverChildListDelegate([
            Column(children: [
              ...list.asMap().entries.map((entry) => Material(
                    color: Colors.white,
                    child: InkWell(
                        child: Column(children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            height: 72,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                    margin:
                                        const EdgeInsets.fromLTRB(0, 0, 10, 0),
                                    child: Text((entry.key + 1).toString())),
                                Expanded(
                                    flex: 1,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          (entry.value["name"] as String)
                                              .replaceAll('&nbsp;', ' '),
                                          style: const TextStyle(fontSize: 16),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        //副标题 下载页面隐藏，没那么多数据
                                        Offstage(
                                          offstage: pageType == 2,
                                          child: Container(
                                            margin: const EdgeInsets.fromLTRB(
                                                0, 5, 0, 0),
                                            child: Row(
                                              children: [
                                                Text(
                                                  entry.value["hasLossless"]
                                                      ? '无损 '
                                                      : '',
                                                  style: const TextStyle(
                                                      color: Colors.orange),
                                                ),
                                                Text(
                                                  entry.value["hasmv"] == 1
                                                      ? 'MV '
                                                      : '',
                                                  style: const TextStyle(
                                                      color: Colors.orange),
                                                ),
                                                Expanded(
                                                  flex: 1,
                                                  child: GestureDetector(
                                                    child: Align(
                                                      alignment:
                                                          Alignment.centerLeft,
                                                      child: Text(
                                                        (entry.value["artist"]
                                                                as String)
                                                            .replaceAll(
                                                                '&nbsp;', ' '),
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: TextStyle(
                                                            color: Theme.of(
                                                                    context)
                                                                .colorScheme
                                                                .primary),
                                                      ),
                                                    ),
                                                    onTap: () {
                                                      Get.toNamed(
                                                          '/artist_detail',
                                                          arguments: {
                                                            "id": entry.value[
                                                                "artistid"]
                                                          });
                                                    },
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    )),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Offstage(
                                      offstage: entry.value["hasmv"] != 1,
                                      child: GestureDetector(
                                        behavior: HitTestBehavior.opaque,
                                        child: Container(
                                          margin: const EdgeInsets.fromLTRB(
                                              0, 0, 5, 0),
                                          padding: const EdgeInsets.all(5),
                                          child: const Icon(
                                              Icons.play_circle_outline_rounded,
                                              color: Color(0xff999999)),
                                        ),
                                        onTap: () => {
                                          Get.toNamed('/mv_detail', arguments: {
                                            "id": entry.value["rid"]
                                          })
                                        },
                                      ),
                                    ),
                                    GestureDetector(
                                      behavior: HitTestBehavior.opaque,
                                      child: Container(
                                        padding: const EdgeInsets.all(5),
                                        child: const Icon(Icons.more_vert,
                                            size: 16, color: Color(0xffcccccc)),
                                      ),
                                      onTap: () => {
                                        //显示下拉弹出方法
                                        showModalBottomSheet<void>(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return MoreBottomSheetWidget(
                                                  item: entry.value,
                                                  pageType: pageType,
                                                  callback: callback);
                                            })
                                      },
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                        ]),
                        onTap: () async {
                          //添加到播放列表
                          store.playMusic(
                            rid: entry.value["rid"],
                            isLocal: pageType == 2,
                          );
                        },
                        onLongPress: () => {
                              //显示下拉弹出方法
                              showModalBottomSheet<void>(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return MoreBottomSheetWidget(
                                        item: entry.value,
                                        pageType: pageType,
                                        callback: callback);
                                  })
                            }),
                  ))
            ])
          ]));
        });
  }
}

//更多下拉弹窗
class MoreBottomSheetWidget extends StatelessWidget {
  const MoreBottomSheetWidget(
      {Key? key, required this.item, required this.pageType, this.callback})
      : super(key: key);

  //当前操作的行
  final dynamic item;
  //特殊页面类型
  final int pageType;
  //回调函数
  final dynamic callback;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<Store>(
        //初始化store控制器
        init: Store(),
        builder: (store) {
          return Container(
              height: Get.height / 3,
              color: Colors.white,
              child: Column(children: [
                Expanded(
                    flex: 1,
                    child: ListView(
                      //垂直列表 水平列表有滚动条哦
                      scrollDirection: Axis.vertical,
                      //children可以放任意的组件
                      children: [
                        Offstage(
                          offstage: pageType != 1 && pageType != 2,
                          child: Material(
                            color: Colors.white,
                            child: InkWell(
                              child: Container(
                                height: 50,
                                padding: const EdgeInsets.all(10),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: const [
                                    Icon(
                                      Icons.highlight_remove_rounded,
                                      size: 30,
                                      color: Color(0xff333333),
                                    ),
                                    SizedBox(
                                      width: 5,
                                    ),
                                    Text(
                                      '删除',
                                      style: TextStyle(fontSize: 16),
                                    ),
                                  ],
                                ),
                              ),
                              onTap: () {
                                //删除收藏
                                if (pageType == 1) {
                                  store.deleteFavouriteMusicList(
                                      idList: [item["rid"]]);
                                }
                                //删除下载的歌曲和缓存
                                if (pageType == 2) {
                                  store.deleteDownloadMusicList(list: [
                                    {
                                      "rid": item["rid"],
                                      "name": item["name"],
                                    }
                                  ]);
                                }
                                if (callback != null) {
                                  callback();
                                }
                              },
                            ),
                          ),
                        ),
                        Material(
                          color: Colors.white,
                          child: InkWell(
                            child: Container(
                              height: 50,
                              padding: const EdgeInsets.all(10),
                              child: Row(
                                children: const [
                                  Icon(
                                    Icons.play_circle_outline_rounded,
                                    size: 30,
                                    color: Color(0xff333333),
                                  ),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  Text(
                                    '下一首播放',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ],
                              ),
                            ),
                            onTap: () {},
                          ),
                        ),
                        StatefulBuilder(
                          builder: (BuildContext context, StateSetter state) {
                            return Material(
                                color: Colors.white,
                                child: InkWell(
                                  child: Container(
                                    height: 50,
                                    padding: const EdgeInsets.all(10),
                                    child: Row(
                                      children: [
                                        store.getMusicLikeState(item["rid"])
                                            ? const Icon(Icons.favorite_rounded,
                                                size: 30, color: Colors.red)
                                            : const Icon(
                                                Icons.favorite_border_rounded,
                                                size: 30,
                                                color: Color(0xff333333)),
                                        const SizedBox(
                                          width: 5,
                                        ),
                                        Text(
                                          store.getMusicLikeState(item["rid"])
                                              ? '已收藏'
                                              : '收藏',
                                          style: const TextStyle(fontSize: 16),
                                        ),
                                      ],
                                    ),
                                  ),
                                  onTap: () async {
                                    await store.setLikeState(item["rid"]);
                                    //局部刷新
                                    state(() {});
                                    //刷新收藏列表
                                    if (pageType == 1 && callback != null) {
                                      callback();
                                    }
                                  },
                                ));
                          },
                        ),
                        Material(
                          color: Colors.white,
                          child: InkWell(
                            child: Container(
                              height: 50,
                              padding: const EdgeInsets.all(10),
                              child: Row(
                                children: const [
                                  Icon(
                                    Icons.add_box_outlined,
                                    size: 30,
                                    color: Color(0xff333333),
                                  ),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  Text(
                                    '添加到歌单',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ],
                              ),
                            ),
                            onTap: () {},
                          ),
                        ),
                        Offstage(
                          offstage: pageType == 2,
                          child: Material(
                            color: Colors.white,
                            child: InkWell(
                              child: Container(
                                height: 50,
                                padding: const EdgeInsets.all(10),
                                child: Row(
                                  children: const [
                                    Icon(
                                      Icons.download_outlined,
                                      size: 30,
                                      color: Color(0xff333333),
                                    ),
                                    SizedBox(
                                      width: 5,
                                    ),
                                    Text(
                                      '下载',
                                      style: TextStyle(fontSize: 16),
                                    ),
                                  ],
                                ),
                              ),
                              onTap: () {
                                store.downloadMp3(
                                    rid: item["rid"], name: item["name"]);
                              },
                            ),
                          ),
                        ),
                      ],
                    ))
              ]));
        });
  }
}
