import 'package:get/get.dart';
import '../tabbar.dart';
import '../views/theme.dart';

//抽离路由代码
class Routers {
  //路由全部放这里
  static final routes = [
    GetPage(
        name: '/',
        page: () => const TabbarComponent(),
        transition: Transition.rightToLeft),
    GetPage(
        name: '/theme',
        page: () => const ThemeComponent(),
        transition: Transition.rightToLeft),
  ];
}
