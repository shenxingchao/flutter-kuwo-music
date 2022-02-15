import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Store extends GetxController {
  //主题色
  Color primary = const Color(0xffFFDF1F);

  //更换主题色
  void changeTheme(Color color) {
    primary = color;
    update();
  }
}
