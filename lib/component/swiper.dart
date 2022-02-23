import 'dart:async';

import 'package:flutter/material.dart';

class Swiper extends StatefulWidget {
  //图片宽高比
  final double aspectRatio;
  //自动播放
  final bool autoPlay;
  //轮播Widget列表
  final List<Widget> items;

  const Swiper(
      {Key? key,
      required this.items,
      this.aspectRatio = 3 / 1,
      this.autoPlay = true})
      : super(key: key);

  @override
  _SwiperState createState() => _SwiperState();
}

class _SwiperState extends State<Swiper> {
  //定时器
  late Timer timer;
  //轮播控制器
  final PageController controller = PageController();

  ///轮播的时间
  late final Duration loopDuration = const Duration(milliseconds: 3000);

  @override
  void initState() {
    super.initState();
    if (widget.autoPlay) {
      startLoopFunction();
    }
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  //定义开始轮播的方法
  void startLoopFunction() {
    if (!widget.autoPlay) {
      return;
    }
    //定时器
    timer = Timer.periodic(loopDuration, (timer) {
      //滑动到下一页
      controller.nextPage(
        curve: Curves.linear,
        duration: const Duration(
          milliseconds: 500,
        ),
      );
    });
  }

  //定义停止轮播的方法
  void stopLoopFunction() {
    if (timer.isActive) {
      timer.cancel();
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      //利用LayoutBuilder获取父容器宽高constraints.maxWidth
      return GestureDetector(
        onTapDown: (TapDownDetails details) {
          stopLoopFunction();
        },
        onTapCancel: () {
          startLoopFunction();
        },
        onTapUp: (TapUpDetails details) {
          startLoopFunction();
        },
        child: SizedBox(
            height: constraints.maxWidth / widget.aspectRatio,
            child: PageView.builder(
              //滚动方向
              scrollDirection: Axis.horizontal,
              controller: controller,
              itemBuilder: (BuildContext context, int index) {
                return widget.items[index % widget.items.length];
              },
            )),
      );
    });
  }
}


/* Swiper(
  aspectRatio: 1400 / 340,
  items: bannerList.map((item) {
    return FadeInImage.assetNetwork(
      alignment: Alignment.center,
      //图片适应父组件方式  cover:等比缩放水平垂直直到2者都填满父组件 其他的没啥用了
      fit: BoxFit.cover,
      placeholder: 'assets/images/default_banner.png',
      image: item["pic"] as String,
    );
  }).toList()
) */