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
        //选中字体
        selectedFontSize: 14,
        //没选中字体
        unselectedFontSize: 14,
        //背景颜色
        backgroundColor: Colors.white,
        //子节点
        items: const [
          BottomNavigationBarItem(label: '主页', icon: Icon(Icons.home)),
          BottomNavigationBarItem(label: '我的', icon: Icon(Icons.person)),
        ],
        //切换事件
        onTap: (int index) {
          setState(() {
            currentIndex = index;
          });
        },
      ),
    );
  }
}
