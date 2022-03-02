import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import './router/router.dart';
import './store/store.dart';
import 'utils/play_audio.dart';

void main() async {
  //透明状态栏
  SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(statusBarColor: Colors.transparent));
  //缓存初始化
  await GetStorage.init();
  //依赖注入到内存
  Get.put(Store());
  //打开APP就开始监听音频播放状态 只需要监听一次
  listenAudio();
  //初始化通知插件
  initNotification();
  runApp(const MyApp());
}

//监听音频播放状态
listenAudio() {
  PlayAudio.instance.audioPlayer.onPlayerStateChanged.listen((PlayerState s) {
    if (s == PlayerState.PLAYING) {
      Get.find<Store>().changeAudioPlayState(PlayerState.PLAYING);
    }
    if (s == PlayerState.STOPPED) {
      Get.find<Store>().changeAudioPlayState(PlayerState.STOPPED);
    }
    if (s == PlayerState.PAUSED) {
      Get.find<Store>().changeAudioPlayState(PlayerState.PAUSED);
    }
    if (s == PlayerState.COMPLETED) {
      Get.find<Store>().changeAudioPlayState(PlayerState.COMPLETED);
    }
  });
}

//初始化通知插件
initNotification() async {
  //初始化
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/launcher_icon');
  final IOSInitializationSettings initializationSettingsIOS =
      // ignore: prefer_const_constructors
      IOSInitializationSettings();
  final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
  await flutterLocalNotificationsPlugin.initialize(initializationSettings,
      onSelectNotification: (e) {});
  //保存到store
  Get.find<Store>()
      .changeFlutterLocalNotificationsPlugin(flutterLocalNotificationsPlugin);
}

class MyApp extends StatelessWidget {
  const MyApp({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<Store>(
        //初始化store控制器
        init: Store(),
        builder: (store) {
          return GetMaterialApp(
              title: 'app',
              theme: ThemeData(
                  //scaffold背景色
                  scaffoldBackgroundColor: Colors.white,
                  //自定义主题色方式
                  colorScheme: ColorScheme.fromSwatch().copyWith(
                      //主题色
                      primary: store.primary,
                      //图标颜色
                      onPrimary: const Color(0Xff333333)),
                  // fontFamily: "PingFangSC",
                  textTheme: const TextTheme(
                      //Material 正文字体
                      bodyText2: TextStyle(
                    fontSize: 12.0,
                    color: Color(0xff333333),
                    // fontFamily: "PingFangSC",
                  ))),
              //隐藏debug字样
              debugShowCheckedModeBanner: false,
              //名为"/"的路由作为应用的home(首页)
              initialRoute: "/",
              getPages: Routers.routes);
        });
  }
}
