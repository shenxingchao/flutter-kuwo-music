import 'package:flutter/material.dart';

class TextButtonComponent extends StatelessWidget {
  //定义属性 要用final关键字 可以参数用?表示
  //如果可选参数不加问号，则必须在构造函数中初始化赋值
  final String text;
  final TextStyle? textStyle;
  final Size? size;
  final Color color; //主题色
  final Color overlayColor; //点击时背景颜色
  final Color backgroundColor; //背景颜色
  final EdgeInsets? padding;
  final VoidCallback? onPressed;

  //声明构造函数及里面的需要传入的属性 {}内的表示可选参数
  const TextButtonComponent({
    this.text = '',
    this.textStyle = const TextStyle(color: Colors.blue, fontSize: 16),
    this.size = const Size(60, 30),
    this.color = Colors.blue,
    this.overlayColor = const Color(0xFFE3F2FD),
    this.backgroundColor = Colors.transparent,
    this.padding = const EdgeInsets.fromLTRB(20, 4, 20, 4),
    this.onPressed,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    //文字按钮
    return TextButton(
      style: ButtonStyle(
        //按钮大小
        minimumSize: MaterialStateProperty.all(size),
        //内边距
        padding: MaterialStateProperty.all(padding),
        //边框
        side: MaterialStateProperty.all(BorderSide(color: color, width: 1)),
        //圆角
        shape: MaterialStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(4))),
        //背景
        backgroundColor: MaterialStateProperty.all(backgroundColor),
        //点击时背景
        overlayColor: MaterialStateProperty.all(overlayColor),
      ),
      onPressed: onPressed ?? () {},
      child: Text(
        text,
        style: textStyle,
      ),
    );
  }
}
