import 'package:flutter/material.dart';
import 'package:fijkplayer/fijkplayer.dart';

import '../../component/appbar.dart';

class MvDetailComponent extends StatefulWidget {
  const MvDetailComponent({Key? key}) : super(key: key);

  @override
  _MvDetailComponentState createState() => _MvDetailComponentState();
}

class _MvDetailComponentState extends State<MvDetailComponent> {
  final FijkPlayer player = FijkPlayer();

  @override
  void initState() {
    super.initState();
    initVideoPlayer();
  }

  @override
  void dispose() {
    player.release();
    super.dispose();
  }

  void initVideoPlayer() async {
    player.setDataSource(
        'http://vfx.mtime.cn/Video/2019/02/04/mp4/190204084208765161.mp4',
        autoPlay: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBarComponent(
          const Text('MV详情'),
          elevation: 0,
          shadowColor: Colors.transparent,
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
        body: Container(
          alignment: Alignment.center,
          child: FijkView(
            player: player,
          ),
        ));
  }
}
