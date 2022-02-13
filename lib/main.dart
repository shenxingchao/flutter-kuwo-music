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
        theme: ThemeData(primarySwatch: Colors.blue, fontFamily: "PingFangSC"),
        debugShowCheckedModeBanner: false,
        //名为"/"的路由作为应用的home(首页)
        initialRoute: "/",
        getPages: Routers.routes);
    //使用这个拦截可以统一路由动画
    // onGenerateRoute: (settings) => Routers.generateRoute(settings));
  }
}
