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
                //背景色
                primary: const Color(0xffFFDF1F),
                //图标颜色
                onPrimary: const Color(0Xff333333)),
            fontFamily: "PingFangSC",
            textTheme: const TextTheme(
                //Material 正文字体
                bodyText2: TextStyle(
              fontSize: 14.0,
              color: Color(0xff333333),
              fontFamily: "PingFangSC",
            ))),
        //隐藏debug字样
        debugShowCheckedModeBanner: false,
        //名为"/"的路由作为应用的home(首页)
        initialRoute: "/",
        getPages: Routers.routes);
  }
}
