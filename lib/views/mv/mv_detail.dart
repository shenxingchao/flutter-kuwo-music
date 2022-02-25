import 'package:flutter/material.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';

import '../../api/common_api.dart';
import '../../component/appbar.dart';
import '../../component/loading.dart';
import '../../utils/play_audio.dart';

class MvDetailComponent extends StatefulWidget {
  const MvDetailComponent({Key? key}) : super(key: key);

  @override
  _MvDetailComponentState createState() => _MvDetailComponentState();
}

class _MvDetailComponentState extends State<MvDetailComponent> {
  //路由参数
  late int id;

  //视频播放控制器
  VideoPlayerController? videoPlayerController;
  ChewieController? chewieController;

  @override
  void initState() {
    super.initState();
    //获取路由参数
    id = Get.arguments["id"];
    //暂停音乐播放
    PlayAudio.instance.audioPlayer.pause();
    initVideoPlayer();
  }

  @override
  void dispose() {
    videoPlayerController!.dispose();
    chewieController!.dispose();
    super.dispose();
  }

  //初始化视频播放器
  void initVideoPlayer() async {
    //获取视频地址
    var res = await CommonApi().getMusicListByPlayListId(mid: id, type: 'mv');

    //请求失败了
    if (res == null || res.data == null) {
      Fluttertoast.showToast(
        msg: "请求服务器错误",
      );
      return;
    }

    //开始初始化
    videoPlayerController =
        VideoPlayerController.network(res.data["data"]["url"]);
    await videoPlayerController!.initialize();

    chewieController = ChewieController(
      videoPlayerController: videoPlayerController as VideoPlayerController,
      aspectRatio: 853 / 480,
      autoPlay: true,
      looping: true,
      //播放时不允许休眠
      allowedScreenSleep:false,
      //进度条颜色
      materialProgressColors: ChewieProgressColors(
          bufferedColor: const Color(0xff666666),
          backgroundColor: const Color(0xff333333),
          playedColor: Theme.of(context).colorScheme.primary),
      optionsBuilder: (context, defaultOptions) async {},
    );

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: const AppBarComponent(
          Text(
            'MV详情'
          ),
          elevation: 0,
          shadowColor: Colors.transparent,
          backgroundColor: Colors.black,
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarBrightness: Brightness.light,
            statusBarIconBrightness: Brightness.light,
          ),
        ),
        body: chewieController != null
            ? Container(
                width: Get.width,
                height: Get.height,
                color: Colors.black,
                alignment: Alignment.center,
                child: Chewie(
                  controller: chewieController!,
                ))
            : Container(
                width: Get.width,
                height: Get.height,
                color: Colors.black,
                alignment: Alignment.center,
                child: const Loading(backgroundColor: Colors.black),
              ));
  }
}
