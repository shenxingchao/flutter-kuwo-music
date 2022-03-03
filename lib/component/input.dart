import 'package:flutter/material.dart';

// 无敌封装输入框
class InputComponent extends StatelessWidget {
  //焦点控制
  final FocusNode? focusNode;
  //控制器
  final TextEditingController? controller;
  //是否自动获取焦点
  final bool autofocus;
  //是否启用
  final bool enabled;
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
  //是否显示清除图标
  final bool showClearIcon;
  //回车提交事件
  final void Function(String)? onSubmitted;
  //点击事件
  final void Function()? onTap;
  //内容改变事件
  final void Function(String)? onChanged;

  const InputComponent(
      {Key? key,
      this.focusNode,
      this.controller,
      this.enabled = true,
      this.autofocus = false,
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
      this.showClearIcon = false,
      this.onSubmitted,
      this.onTap,
      this.onChanged,})
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
          focusNode:focusNode,
          controller: controller,
          maxLines: 1,
          style: TextStyle(color: color, fontSize: fontSize),
          autofocus:autofocus,
          decoration: InputDecoration(
            enabled:enabled,
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
            suffixIcon: Offstage(
              offstage: !showClearIcon,
              child: IconButton(
                onPressed: controller?.clear,
                icon: const Icon(
                  Icons.clear,
                  size: 14,
                  color: Colors.grey,
                ),
              ),
            ),
          ),
          onSubmitted: onSubmitted,
          onTap: onTap,
          onChanged: onChanged,
        ));
  }
}
