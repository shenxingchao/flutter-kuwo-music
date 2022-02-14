//appbar组件 必须实现PreferredSizeWidget接口
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppBarComponent extends StatelessWidget implements PreferredSizeWidget {
  final Widget title;
  final Widget? leading;
  final List<Widget>? rightIcon;
  final double appBarHeight;
  final double elevation;
  final Color shadowColor;
  final Color backgroundColor;
  final SystemUiOverlayStyle? systemOverlayStyle;
  const AppBarComponent(
    this.title, {
    Key? key,
    this.leading,
    this.rightIcon,
    this.appBarHeight = 66.0,
    this.elevation = 4,
    this.shadowColor = const Color(0xfffefefe),
    this.backgroundColor = Colors.white,
    this.systemOverlayStyle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    //appbar组件
    return AppBar(
      //标题
      title: title,
      //标题居中
      centerTitle: false,
      //阴影程度
      elevation: elevation,
      //阴影颜色
      shadowColor: shadowColor,
      //设置状态栏高度以 去除appheight有限制高度 实际就是appbar的最大高度
      toolbarHeight: 500,
      //设置状态栏背景颜色
      backgroundColor: backgroundColor,
      //状态栏文字样式
      systemOverlayStyle: systemOverlayStyle,
      //标题样式
      titleTextStyle: const TextStyle(fontSize: 20, color: Color(0xff333333)),
      //左侧图标
      leading: leading,
      //右侧icon list
      actions: rightIcon,
      //右侧icon主题
      actionsIconTheme: const IconThemeData(
          color: Colors.black,
          //透明度
          opacity: 100),
      //左侧icon主题
      iconTheme: const IconThemeData(
          color: Colors.black,
          //透明度
          opacity: 100),
    );
  }

  @override
  // implement preferredSize 实现抽象类PreferredSizeWidget里的抽象方法
  Size get preferredSize => Size.fromHeight(appBarHeight);
}
