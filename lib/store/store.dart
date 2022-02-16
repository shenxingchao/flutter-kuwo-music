import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

//全局变量start
//本地缓存对象
var box = GetStorage();
//主题色列表
List<Color> themeList = [
  const Color(0xffFFDF1F),
  const Color(0xff40A7FF),
  const Color(0xff00ED93),
  const Color(0xffFF9B9D),
  const Color(0xffC986FF),
];
//全局变量end

//类似vuex状态管理类
class Store extends GetxController {
  //主题色
  Color primary = box.read('primary') != null
      ? themeList[box.read('primary')]
      : themeList[0];

  //更换主题色
  void changeTheme(Color color) {
    primary = color;
    update();
  }
}
