import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../store/store.dart';

//音乐列表
class ListWidget extends StatelessWidget {
  const ListWidget({
    Key? key,
    required this.list,
  }) : super(key: key);

  final List list;

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
                            height: 73,
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
                                          entry.value["name"],
                                          style: const TextStyle(fontSize: 18),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        //副标题
                                        Container(
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
                                                child: Text(
                                                    entry.value["artist"],
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: const TextStyle(
                                                        color:
                                                            Color(0xff999999))),
                                              )
                                            ],
                                          ),
                                        ),
                                      ],
                                    )),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    GestureDetector(
                                      behavior: HitTestBehavior.opaque,
                                      child: Container(
                                        margin: const EdgeInsets.fromLTRB(
                                            0, 0, 5, 0),
                                        padding: const EdgeInsets.all(5),
                                        child: const Icon(
                                            Icons.play_circle_outline_rounded,
                                            color: Color(0xffcccccc)),
                                      ),
                                      onTap: () => {print("弹出下载")},
                                    ),
                                    GestureDetector(
                                      behavior: HitTestBehavior.opaque,
                                      child: Container(
                                        padding: const EdgeInsets.all(5),
                                        child: const Icon(Icons.more_horiz,
                                            color: Color(0xffcccccc)),
                                      ),
                                      onTap: () => {print("弹出下载")},
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                          const Divider(
                            height: 1,
                            color: Color(0xffdddddd),
                          )
                        ]),
                        onTap: () async {
                          //添加到播放列表
                          store.playMusic(rid: entry.value["rid"]);
                        },
                        onLongPress: () => {
                              print("弹出下载"),
                            }),
                  ))
            ])
          ]));
        });
  }
}
