import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../appbar.dart';
import '../store/store.dart';

class ThemeComponent extends StatefulWidget {
  const ThemeComponent({Key? key}) : super(key: key);

  @override
  _ThemeComponentState createState() => _ThemeComponentState();
}

class _ThemeComponentState extends State<ThemeComponent> {
  List<Color> themeList = [
    const Color(0xffFFDF1F),
    const Color(0xff40A7FF),
    const Color(0xff00ED93),
    const Color(0xffFF9B9D),
    const Color(0xffC986FF),
  ];

  @override
  Widget build(BuildContext context) {
    return GetBuilder<Store>(
        //初始化store控制器
        init: Store(),
        builder: (store) {
          return Scaffold(
              appBar: AppBarComponent(
                const Text('更换主题色'),
                appBarHeight: 66.0,
                elevation: 0,
                shadowColor: Colors.transparent,
                backgroundColor: Theme.of(context).colorScheme.primary,
              ),
              body: GridView.count(
                //2列
                crossAxisCount: 3,
                //水平间距
                crossAxisSpacing: 10,
                //垂直间距
                mainAxisSpacing: 10,
                //内边距
                padding: const EdgeInsets.all(10),
                //子元素宽高比
                childAspectRatio: 0.8,
                //子元素
                children: themeList
                    .map(
                      (item) => GestureDetector(
                          child: Container(
                            decoration: BoxDecoration(
                              //背景颜色
                              color: item,
                              borderRadius: BorderRadius.circular(4),
                              boxShadow: item == Get.find<Store>().primary
                                  ? const [
                                      BoxShadow(
                                        offset: Offset(0, 4), //x,y轴
                                        color: Color(0xffaaaaaa), //投影颜色
                                        blurRadius: 4, //投影距离
                                      )
                                    ]
                                  : [],
                            ),
                          ),
                          onTap: () {
                            store.changeTheme(item);
                          }),
                    )
                    .toList(),
              ));
        });
  }
}
