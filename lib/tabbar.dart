import 'package:audioplayers/audioplayers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:flutterkuwomusic/views/common/play_list_bottom_sheet.dart';
import 'package:get/get.dart';
import './home.dart';
import './user.dart';
import './component/input.dart';
import 'component/appbar.dart';
import './store/store.dart';

class TabbarComponent extends StatefulWidget {
  const TabbarComponent({Key? key}) : super(key: key);

  @override
  _TabbarComponentState createState() => _TabbarComponentState();
}

class _TabbarComponentState extends State<TabbarComponent>
    with SingleTickerProviderStateMixin {
  //当前激活路由索引
  int currentIndex = 0;
  //tabbar路由列表
  final List router = [
    const HomeComponent(),
    const Text('音乐详情'),
    const UserCommponent(),
  ];
  //tabbar路由标题列表
  final List appBarTitle = ['首页', '歌曲详情', '我的'];

  //侧边栏控制器
  final zoomDrawerController = ZoomDrawerController();

  //定义动画控制器
  late AnimationController animationController;

  //文本默认值控制器
  TextEditingController textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    initAnimation();
  }

  @override
  void dispose() {
    //路由销毁时需要释放动画资源
    animationController.dispose();
    textController.dispose();
    super.dispose();
  }

  //初始化旋转动画
  void initAnimation() {
    //初始化动画控制器
    animationController =
        AnimationController(duration: const Duration(seconds: 12), vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    //侧边栏
    return ZoomDrawer(
      controller: zoomDrawerController,
      //从右到左
      isRtl: false,
      //显示样式
      style: DrawerStyle.Style3,
      //抽屉宽度
      slideWidth: Get.width * (0.75),
      //主屏幕圆角
      borderRadius: 0.0,
      //旋转角度
      angle: 0.0,
      //禁止主页滑动打开抽屉手势
      disableGesture: false,
      //抽屉背景色
      backgroundColor: const Color(0xffffffff),
      //显示抽屉阴影
      showShadow: false,
      //点击主屏幕时关闭抽屉
      mainScreenTapClose: true,
      //主屏幕覆盖层颜色
      overlayColor: const Color(0xcc000000),
      overlayBlend: BlendMode.srcOver,
      //主屏幕模糊量
      overlayBlur: 0,
      //侧边栏
      menuScreen: const MenuScreenWidget(),
      //主屏幕
      mainScreen: getMainScreen(context, animationController),
    );
  }

  //主屏幕
  Scaffold getMainScreen(BuildContext context, animationController) {
    return Scaffold(
        appBar: AppBarComponent(
          currentIndex == 0
              ? GestureDetector(
                  child: InputComponent(
                      controller: textController,
                      enabled: false,
                      height: 40,
                      hasBorder: true,
                      isCircle: true,
                      showSearchIcon: true,
                      placeholder: "歌曲/歌手/歌单/MV"),
                  onTap: () {
                    Get.toNamed('/search_list');
                  },
                )
              : Text(appBarTitle[currentIndex]),
          leading: GestureDetector(
              child: const Icon(Icons.menu),
              onTap: () {
                zoomDrawerController.toggle?.call();
              }),
          appBarHeight: currentIndex == 0 ? 70 : 66.0,
          elevation: 0,
          shadowColor: Colors.transparent,
          //状态栏样式
          systemOverlayStyle: const SystemUiOverlayStyle(
            statusBarBrightness: Brightness.dark,
            statusBarIconBrightness: Brightness.dark,
          ),
          backgroundColor: Colors.white,
          leftIconColor: const Color(0xff333333),
          titleTextStyle: const TextStyle(
            fontSize: 20,
            color: Color(0xff333333),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            //显示下拉弹出方法
            showModalBottomSheet<void>(
                context: context,
                builder: (BuildContext context) {
                  return const PlayListBottomSheetWidget();
                });
          },
          mini: true,
          backgroundColor: Theme.of(context).colorScheme.primary,
          child: const Icon(Icons.menu),
        ),
        body: router[currentIndex],
        //tabbar
        bottomNavigationBar: GetBuilder<Store>(
            //初始化store控制器
            init: Store(),
            builder: (store) {
              audioListen(store);
              return BottomNavigationBar(
                //图标大小
                iconSize: 28,
                //当前激活项
                currentIndex: currentIndex,
                //布局类型
                type: BottomNavigationBarType.fixed,
                //选中字体
                selectedFontSize: 10,
                selectedItemColor: Theme.of(context).colorScheme.primary,
                //没选中字体
                unselectedFontSize: 10,
                //背景颜色
                backgroundColor: Colors.white,
                //子节点
                items: [
                  const BottomNavigationBarItem(
                      label: '主页', icon: Icon(Icons.home)),
                  BottomNavigationBarItem(
                      label: '',
                      icon: Stack(
                        alignment: Alignment.bottomCenter,
                        clipBehavior: Clip.none,
                        children: [
                          const SizedBox(
                            width: 0,
                            height: 0,
                          ),
                          Positioned(
                            top: -19,
                            child: RotationTransition(
                              turns: animationController
                                ..addStatusListener((status) {
                                  if (store.audioPlayState ==
                                          PlayerState.PLAYING &&
                                      status == AnimationStatus.completed) {
                                    animationController.reset();
                                    animationController.forward();
                                  }
                                }),
                              //设置动画的旋转中心
                              alignment: Alignment.center,
                              child: ClipOval(
                                  child: store.playMusicInfo != null &&
                                          store.playMusicInfo!.pic120 != ''
                                      ? CachedNetworkImage(
                                          imageUrl: store.playMusicInfo!.pic120,
                                          alignment: Alignment.center,
                                          fit: BoxFit.cover,
                                          width: 50,
                                          height: 50,
                                          errorWidget: (context, url, error) =>
                                              Image.asset(
                                                'assets/images/default.png',
                                                fit: BoxFit.cover,
                                                width: 50,
                                                height: 50,
                                              ))
                                      : Image.asset(
                                          'assets/images/icons/music.png',
                                          fit: BoxFit.cover,
                                          width: 50,
                                          height: 50,
                                        )),
                            ),
                          )
                        ],
                      )),
                  const BottomNavigationBarItem(
                      label: '我的', icon: Icon(Icons.person)),
                ],
                //切换事件
                onTap: (int index) {
                  setState(() {
                    if (index != 1) {
                      //点击音乐图标直接进入音乐详情
                      currentIndex = index;
                    } else {
                      Get.toNamed('/music_detail');
                    }
                  });
                },
              );
            }));
  }

  //监听播放状态改变旋转动画
  void audioListen(Store store) {
    if (store.audioPlayState == PlayerState.PLAYING) {
      animationController.forward();
    }
    if (store.audioPlayState == PlayerState.PAUSED ||
        store.audioPlayState == PlayerState.STOPPED ||
        store.audioPlayState == PlayerState.COMPLETED) {
      animationController.stop();
    }
  }
}

//侧边栏屏幕
class MenuScreenWidget extends StatelessWidget {
  const MenuScreenWidget({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: Get.width * (0.8),
      height: Get.height,
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Image.asset(
            'assets/images/drawer.png',
            fit: BoxFit.fitWidth,
          ),
          Expanded(
            child: MediaQuery.removePadding(
              context: context,
              removeTop: true,
              child: Scaffold(
                body: ListView(
                  //垂直列表 水平列表有滚动条哦
                  scrollDirection: Axis.vertical,
                  children: [
                    ListTile(
                      leading: Icon(
                        Icons.history,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      title: const Text('更换主题色'),
                      tileColor: Colors.white,
                      onTap: () {
                        Get.toNamed(
                          '/theme',
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
