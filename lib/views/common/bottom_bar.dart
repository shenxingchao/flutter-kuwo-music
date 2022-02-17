//通用底部播放工具条

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../store/store.dart';

class PlayMusicBottomBar extends StatefulWidget {
  const PlayMusicBottomBar({Key? key}) : super(key: key);

  @override
  _PlayMusicBottomBarState createState() => _PlayMusicBottomBarState();
}

class _PlayMusicBottomBarState extends State<PlayMusicBottomBar> {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<Store>(
        //初始化store控制器
        init: Store(),
        builder: (store) {
          return Offstage(
            offstage: store.playMusicInfo == null,
            child: Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Container(
                    color: Colors.red,
                    height: 80,
                  ),
                )
              ],
            ),
          );
        });
  }
}
