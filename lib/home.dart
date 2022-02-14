import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:carousel_slider/carousel_slider.dart';
import './component/loading.dart';
import './utils/request.dart';

class HomeComponent extends StatefulWidget {
  const HomeComponent({Key? key}) : super(key: key);

  @override
  _HomeComponentState createState() => _HomeComponentState();
}

class _HomeComponentState extends State<HomeComponent> {
  //Banner图
  List bannerList = [];
  //分类图标
  List categoryList = [
    {
      "title": '歌单',
      "icon": 'assets/images/play_list_icon.png',
    },
    {
      "title": '排行榜',
      "icon": 'assets/images/rank_icon.png',
    },
    {
      "title": '歌手',
      "icon": 'assets/images/artist_icon.png',
    },
    {
      "title": 'MV',
      "icon": 'assets/images/mv_icon.png',
    }
  ];

  //mounted
  @override
  void initState() {
    super.initState();
    getBannerList();
  }

  void getBannerList() async {
    var res =
        await Request.http(url: 'index/getBannerList', type: 'get', data: {})
            .then((res) {
      if (res.data["code"] != 200) {
        Fluttertoast.showToast(
          msg: res.data["msg"],
        );
      }
      return res;
    }).catchError((error) {
      Fluttertoast.showToast(
        msg: "请求服务器错误",
      );
    });
    if (mounted && res != null) {
      setState(() {
        bannerList = res.data["data"];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return bannerList.isNotEmpty
        ? Scrollbar(
            child: SingleChildScrollView(
                child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          //轮播图
                          Container(
                              decoration: const BoxDecoration(boxShadow: [
                                BoxShadow(
                                  offset: Offset(0, 8), //x,y轴
                                  color: Color(0xffcccccc), //投影颜色
                                  blurRadius: 8, //投影距离
                                )
                              ]),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: CarouselSlider(
                                  options: CarouselOptions(
                                    //宽高比
                                    aspectRatio: 1400 / 340,
                                    //可见比例
                                    viewportFraction: 1,
                                    //自动播放
                                    autoPlay: true,
                                  ),
                                  items: bannerList.map((item) {
                                    return Builder(
                                      builder: (BuildContext context) {
                                        return FadeInImage.assetNetwork(
                                          alignment: Alignment.topRight,
                                          //图片适应父组件方式  cover:等比缩放水平垂直直到2者都填满父组件 其他的没啥用了
                                          fit: BoxFit.cover,
                                          placeholder:
                                              'assets/images/default_banner.png',
                                          image: item["pic"] as String,
                                        );
                                      },
                                    );
                                  }).toList(),
                                ),
                              )),
                          //分类图标
                          Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Row(
                              //相当于css justifly
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              //相当于css align-item
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: categoryList.map((item) {
                                return Builder(
                                  builder: (BuildContext context) {
                                    return InkWell(
                                      child: Column(
                                        children: [
                                          SizedBox(
                                            width: 40,
                                            height: 40,
                                            child: Image.asset(
                                              item["icon"],
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                          Text(item['title'])
                                        ],
                                      ),
                                      onTap: () {},
                                    );
                                  },
                                );
                              }).toList(),
                            ),
                          )
                        ]))))
        : const Loading();
  }
}
