import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import './router/router.dart';

void main() {
  //透明状态栏
  SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(statusBarColor: Colors.transparent));
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
        title: 'app',
        theme: ThemeData(
            //自定义主题色方式
            colorScheme: ColorScheme.fromSwatch().copyWith(
              primary: const Color.fromARGB(255, 255, 223, 31),
            ),
            fontFamily: "PingFangSC"),
        //隐藏debug字样
        debugShowCheckedModeBanner: false,
        //名为"/"的路由作为应用的home(首页)
        initialRoute: "/",
        getPages: Routers.routes);
  }
}
