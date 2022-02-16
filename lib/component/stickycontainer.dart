import 'package:flutter/material.dart';

class StickyContainerComponent extends SliverPersistentHeaderDelegate {
  final double maxHeight;
  //注意这里的最小高度要加上状态栏高度，不然看不见
  final double minHeight;
  final Widget Function(
      BuildContext context, double offset, bool overlapsContent) builder;

  StickyContainerComponent(
      {this.maxHeight = 120, this.minHeight = 80, required this.builder})
      : assert(maxHeight >= minHeight);

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return builder(context, shrinkOffset, overlapsContent);
  }

  @override
  double get maxExtent => maxHeight;

  @override
  double get minExtent => minHeight;

  @override
  bool shouldRebuild(covariant StickyContainerComponent oldDelegate) =>
      maxHeight != oldDelegate.maxHeight ||
      minHeight != oldDelegate.minHeight ||
      builder != oldDelegate.builder;
}

//吸顶状态条使用方法 需要和SliverAppBar 同级
/* SliverPersistentHeader(
            pinned: true,
            delegate: StickyContainerComponent(
                maxHeight: 120,
                minHeight: 0,
                builder: (context, offset, overlapsContent) {
                  return Container(
                    height: 120,
                    color: Colors.blue,
                    child: Text('333'),
                  );
                })), */

//可以用来包裹任何的renderbox控件放在sliverlist里面
/* SliverToBoxAdapter(
      child: SizedBox(
        height: 0,
      ),
    ) */