import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import './router/router.dart';
import './store/store.dart';

void main() async {
  //透明状态栏
  SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(statusBarColor: Colors.transparent));
  //缓存初始化
  await GetStorage.init();
  //依赖注入到内存
  Get.put(Store());
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<Store>(
        //初始化store控制器
        init: Store(),
        builder: (store) {
          return GetMaterialApp(
              title: 'app',
              theme: ThemeData(
                  //自定义主题色方式
                  colorScheme: ColorScheme.fromSwatch().copyWith(
                      //背景色
                      primary: store.primary,
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
        });
  }
}
