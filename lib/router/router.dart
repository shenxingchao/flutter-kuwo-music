import 'package:get/get.dart';
import '../tabbar.dart';
import '../views/theme.dart';
import '../views/play_list/play_list_detail.dart';
import '../views/music/music_detail.dart';

//抽离路由代码
class Routers {
  //路由全部放这里
  static final routes = [
    GetPage(
        name: '/',
        page: () => const TabbarComponent(),
        transition: Transition.cupertino),
    GetPage(
        name: '/theme',
        page: () => const ThemeComponent(),
        transition: Transition.cupertino),
    GetPage(
        name: '/play_list_detail',
        page: () => const PlayListDetailComponenet(),
        transition: Transition.cupertino),
    GetPage(
        name: '/music_detail',
        page: () => const MusicDetailComponent(),
        transition: Transition.cupertino),
  ];
}
