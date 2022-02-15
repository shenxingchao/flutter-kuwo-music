import 'package:flutter/material.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import './home.dart';
import './component/input.dart';
import './appbar.dart';

class TabbarComponent extends StatefulWidget {
  const TabbarComponent({Key? key}) : super(key: key);

  @override
  _TabbarComponentState createState() => _TabbarComponentState();
}

class _TabbarComponentState extends State<TabbarComponent> {
  //当前激活路由索引
  int currentIndex = 0;
  //tabbar路由列表
  final List router = [
    const HomeComponent(),
    const Text('音乐详情'),
    const HomeComponent(),
  ];
  //tabbar路由标题列表
  final List appBarTitle = ['首页', '歌曲详情', '我的'];

  //侧边栏控制器
  final zoomDrawerController = ZoomDrawerController();

  @override
  Widget build(BuildContext context) {
    //侧边栏
    return ZoomDrawer(
      controller: zoomDrawerController,
      //显示样式
      style: DrawerStyle.Style3,
      //抽屉宽度
      slideWidth: MediaQuery.of(context).size.width * (0.8),
      //主屏幕圆角
      borderRadius: 0.0,
      //旋转角度
      angle: 0.0,
      //禁止主页滑动打开抽屉手势
      disableGesture: false,
      //抽屉背景色
      backgroundColor: const Color(0x33000000),
      //显示抽屉阴影
      showShadow: true,
      //点击主屏幕时关闭抽屉
      mainScreenTapClose: true,
      //主屏幕覆盖层颜色
      overlayColor: const Color(0xff000000),
      //主屏幕迷糊量
      overlayBlur: 2,
      menuScreen: Container(
        width: MediaQuery.of(context).size.width * (0.8),
        height: MediaQuery.of(context).size.height,
        color: Colors.white,
      ),
      //主屏幕
      mainScreen: Scaffold(
        appBar: AppBarComponent(
          currentIndex == 0
              ? InputComponent(
                  height: 40,
                  hasBorder: false,
                  isCircle: true,
                  showSearchIcon: true,
                  placeholder: "歌曲/歌手/歌单/MV",
                  onSubmitted: (value) {
                    // Get.toNamed('/search_list', arguments: value);
                  })
              : Text(appBarTitle[currentIndex]),
          leading: GestureDetector(
              child: const Icon(Icons.menu),
              onTap: () {
                zoomDrawerController.toggle?.call();
              }),
          appBarHeight: currentIndex == 0 ? 70 : 66.0,
          elevation: 0,
          shadowColor: Colors.transparent,
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
        body: router[currentIndex],
        //tabbar
        bottomNavigationBar: BottomNavigationBar(
          //图标大小
          iconSize: 26,
          //当前激活项
          currentIndex: currentIndex,
          //布局类型
          type: BottomNavigationBarType.fixed,
          //选中字体
          selectedFontSize: 14,
          selectedItemColor: const Color(0xff333333),
          //没选中字体
          unselectedFontSize: 14,
          //背景颜色
          backgroundColor: Colors.white,
          //子节点
          items: [
            const BottomNavigationBarItem(label: '主页', icon: Icon(Icons.home)),
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
                        top: -15,
                        child: Image.asset('assets/images/icons/music.png',
                            fit: BoxFit.cover))
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
              }
            });
          },
        ),
      ),
    );
  }
}
