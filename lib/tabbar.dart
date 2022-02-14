import 'package:flutter/material.dart';
import './home.dart';

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
  final List appBarTitle = ['主页', '我的'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: router[currentIndex],
      //tabbar
      bottomNavigationBar: BottomNavigationBar(
        //图标大小
        iconSize: 26,
        //当前激活项
        currentIndex: currentIndex,
        //布局类型
        type: BottomNavigationBarType.fixed,
        // showSelectedLabels: false,
        // showUnselectedLabels: false,
        //选中字体
        selectedFontSize: 14,
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
                      top: -10,
                      child: Image.asset('assets/images/test.png',
                          fit: BoxFit.cover))
                ],
              )),
          const BottomNavigationBarItem(label: '我的', icon: Icon(Icons.person)),
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
    );
  }
}
