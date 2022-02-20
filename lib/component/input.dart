import 'package:flutter/material.dart';

// 无敌封装输入框
class InputComponent extends StatelessWidget {
  final TextEditingController? controller;
  //输入框高度
  final double height;
  //背景颜色
  final Color backgroundColor;
  //边框
  final Color borderColor;
  //是否有边框
  final bool hasBorder;
  //是否圆角
  final bool isCircle;
  //字体大小
  final double fontSize;
  //字体颜色
  final Color color;
  //内容边距
  final EdgeInsetsGeometry contentPadding;
  //提示文字
  final String placeholder;
  //是否显示搜索图标
  final bool showSearchIcon;
  // 回车提交事件
  final void Function(String)? onSubmitted;

  const InputComponent(
      {Key? key,
      this.controller,
      this.height = 40,
      this.backgroundColor = Colors.white,
      this.borderColor = const Color(0xffdddddd),
      this.hasBorder = true,
      this.isCircle = false,
      this.fontSize = 16,
      this.color = const Color(0xff333333),
      this.contentPadding = const EdgeInsets.all(10),
      this.placeholder = '请输入',
      this.showSearchIcon = false,
      this.onSubmitted})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        height: height,
        alignment: Alignment.center,
        decoration: BoxDecoration(
            color: backgroundColor,
            //这里有bug只能这么判断
            border: Border.all(
                color: hasBorder ? borderColor : Colors.transparent,
                width: hasBorder ? 1 : 0),
            borderRadius: BorderRadius.circular(isCircle ? 30 : 4)),
        child: TextField(
          controller: controller,
          maxLines: 1,
          style: TextStyle(color: color, fontSize: fontSize),
          decoration: InputDecoration(
            filled: true,
            //填充配景色 必须设置filled: true
            fillColor: Colors.transparent,
            //重点，相当于高度包裹的意思，必须设置为true，不然有默认奇妙的最小高度
            isCollapsed: true,
            //因为高度自适应，所以内容边距上下设为0
            contentPadding: contentPadding,
            //placeholder
            hintText: placeholder,
            //边框
            border: InputBorder.none,
            //获取焦点边框
            focusedBorder: InputBorder.none,
            prefixIcon: Offstage(
              offstage: !showSearchIcon,
              child: const Icon(
                Icons.search,
                color: Colors.grey,
              ),
            ),
            suffixIcon: IconButton(
              onPressed: controller?.clear,
              icon: const Icon(
                Icons.clear,
                color: Colors.grey,
              ),
            ),
          ),
          onSubmitted: onSubmitted,
        ));
  }
}
