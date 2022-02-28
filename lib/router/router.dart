import 'package:get/get.dart';
import '../tabbar.dart';
import '../views/drawer/theme.dart';
import '../views/play_list/play_list_index.dart';
import '../views/play_list/play_list_category.dart';
import '../views/play_list/play_list_category_list.dart';
import '../views/play_list/play_list_detail.dart';
import '../views/rank_list/rank_list_index.dart';
import '../views/rank_list/rank_list_detail.dart';
import '../views/music/music_detail.dart';
import '../views/album/album_detail.dart';
import '../views/mv/mv_list.dart';
import '../views/mv/mv_detail.dart';
import '../views/search/search_list.dart';
import '../views/user/history.dart';
import '../views/user/favourite_list.dart';

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
        name: '/play_list_index',
        page: () => const PlayListIndexComponent(),
        transition: Transition.cupertino),
    GetPage(
        name: '/play_list_category',
        page: () => const PlayListCategoryComponent(),
        transition: Transition.cupertino),
    GetPage(
        name: '/play_list_category_list',
        page: () => const PlayListCategoryListComponent(),
        transition: Transition.cupertino),
    GetPage(
        name: '/play_list_detail',
        page: () => const PlayListDetailComponent(),
        transition: Transition.cupertino),
    GetPage(
        name: '/rank_list_index',
        page: () => const RankListIndexComponent(),
        transition: Transition.cupertino),
    GetPage(
        name: '/rank_list_detail',
        page: () => const RankListDetailComponent(),
        transition: Transition.cupertino),
    GetPage(
        name: '/music_detail',
        page: () => const MusicDetailComponent(),
        transition: Transition.cupertino),
    GetPage(
        name: '/album_detail',
        page: () => const AlbumDetailComponent(),
        transition: Transition.cupertino),
    GetPage(
        name: '/mv_list',
        page: () => const MVListComponent(),
        transition: Transition.cupertino),
    GetPage(
        name: '/mv_detail',
        page: () => const MvDetailComponent(),
        transition: Transition.cupertino),
    GetPage(
        name: '/search_list',
        page: () => const SearchListComponent(),
        transition: Transition.cupertino),
    GetPage(
        name: '/history',
        page: () => const HistroyComponent(),
        transition: Transition.cupertino),
    GetPage(
        name: '/favourite_list',
        page: () => const FavouriteListComponent(),
        transition: Transition.cupertino),
  ];
}
