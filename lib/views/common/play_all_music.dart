import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../interface/play_list_music.dart';
import '../../store/store.dart';

//播放全部工具栏
class PlayAllMusicWidget extends StatelessWidget {
  const PlayAllMusicWidget({
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
          return Container(
            height: 50,
            color: Colors.white,
            child: SizedBox(
                height: 50,
                child: GestureDetector(
                  //保证空白范围可点击 这里点击一行
                  behavior: HitTestBehavior.opaque,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(children: [
                        Container(
                          margin: const EdgeInsets.fromLTRB(10, 0, 5, 0),
                          child: const Icon(Icons.play_circle_outline,
                              color: Color(0xff333333)),
                        ),
                        Text(
                          '播放全部/' + list.length.toString() + '首',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ]),
                    ],
                  ),
                  onTap: () {
                    List<PlayListMusic> audioList = [];
                    for (var element in list) {
                      audioList.add(PlayListMusic(
                          artist: element["artist"],
                          rid: element["rid"],
                          name: element["name"],
                          isLocal: false,
                          pic120: element["pic120"]));
                    }
                    store.playAudioList(audioList);
                  },
                )),
          );
        });
  }
}
