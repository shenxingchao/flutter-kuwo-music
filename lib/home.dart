import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
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
      "icon": 'assets/images/icons/play_list.png',
    },
    {
      "title": '排行榜',
      "icon": 'assets/images/icons/rank.png',
    },
    {
      "title": '歌手',
      "icon": 'assets/images/icons/artist.png',
    },
    {
      "title": 'MV',
      "icon": 'assets/images/icons/mv.png',
    }
  ];
  //推荐歌单
  List playList = [];
  //定义刷新控件
  final RefreshController refreshController =
      RefreshController(initialRefresh: false);

  //mounted
  @override
  void initState() {
    super.initState();
    onRefresh();
  }

  void onRefresh() {
    getBannerList();
    getPlayList();
    //下拉刷新完成
    refreshController.refreshCompleted();
  }

  //获取轮播图
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

  //获取推荐歌单
  void getPlayList() async {
    var res = await Request.http(
        url: 'index/getRecomendSongList', type: 'get', data: {}).then((res) {
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
        playList = res.data["data"]["list"];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return bannerList.isNotEmpty
        ? //刷新组件
        SmartRefresher(
            //下拉刷新
            enablePullDown: true,
            //经典header 其他[ClassicHeader],[WaterDropMaterialHeader],[MaterialClassicHeader],[WaterDropHeader],[BezierCircleHeader]
            header: WaterDropMaterialHeader(
                backgroundColor: Theme.of(context).colorScheme.primary),
            controller: refreshController,
            onRefresh: onRefresh,
            child: Scrollbar(
                child: SingleChildScrollView(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                  //轮播图
                  CarouselWidget(bannerList: bannerList),
                  //分类图标
                  CategoryWidget(categoryList: categoryList),
                  //推荐歌单
                  RecommendPlayListWidget(playList: playList)
                ]))))
        : const Loading();
  }
}

//推荐歌单
class RecommendPlayListWidget extends StatelessWidget {
  const RecommendPlayListWidget({
    Key? key,
    required this.playList,
  }) : super(key: key);

  final List playList;

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
        child: Container(
          alignment: Alignment.centerLeft,
          child: const Text(
            '歌单推荐',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ),
      Padding(
        padding: const EdgeInsets.all(5.0),
        child: Wrap(
          //从左到右排列
          direction: Axis.horizontal,
          //水平间距
          spacing: 0,
          //垂直间距 此值可以设置为负数 以减小上下之间的间距 不然默认的0有点大
          runSpacing: 0,
          //相当于水平方向上的 justifly-content
          alignment: WrapAlignment.start,
          //相当于垂直方向上的 align-item
          runAlignment: WrapAlignment.center,
          children: playList
              .map((item) => FractionallySizedBox(
                  widthFactor: 1 / 3,
                  child: Padding(
                    padding: const EdgeInsets.all(5),
                    child: GestureDetector(
                      child: Column(
                        children: [
                          Stack(
                            alignment: Alignment.bottomLeft,
                            children: [
                              AspectRatio(
                                  aspectRatio: 1 / 1,
                                  child: Container(
                                      decoration:
                                          const BoxDecoration(boxShadow: [
                                        BoxShadow(
                                          offset: Offset(0, 4), //x,y轴
                                          color: Color(0xffcccccc), //投影颜色
                                          blurRadius: 4, //投影距离
                                        )
                                      ]),
                                      child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(4),
                                          child: FadeInImage.assetNetwork(
                                            alignment: Alignment.topRight,
                                            //图片适应父组件方式  cover:等比缩放水平垂直直到2者都填满父组件 其他的没啥用了
                                            fit: BoxFit.cover,
                                            placeholder:
                                                'assets/images/default.png',
                                            image: item["img"],
                                          )))),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(5, 0, 0, 5),
                                child: Text(
                                  (item["listencnt"] / 10000)
                                          .toStringAsFixed(2) +
                                      "万",
                                  style: const TextStyle(color: Colors.white),
                                ),
                              )
                            ],
                          ),
                          Container(
                            margin: const EdgeInsets.fromLTRB(0, 5, 0, 5),
                            child: Text(
                              item["name"],
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                          Text(
                            item["uname"],
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 14, color: Color(0xff999999)),
                          ),
                        ],
                      ),
                      onTap: () {
                        // Get.toNamed('/book_chapter',
                        //     arguments: Book(
                        //         id: item["id"],
                        //         bookName: item["book_name"]));
                      },
                    ),
                  )))
              .toList(),
        ),
      )
    ]);
  }
}

//分类图标
class CategoryWidget extends StatelessWidget {
  const CategoryWidget({
    Key? key,
    required this.categoryList,
  }) : super(key: key);

  final List categoryList;

  @override
  Widget build(BuildContext context) {
    return Padding(
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
                    const SizedBox(height: 5.0),
                    Text(item['title'])
                  ],
                ),
                onTap: () {
                  // Get.toNamed('/book_chapter',
                  //     arguments: Book(
                  //         id: item["id"],
                  //         bookName: item["book_name"]));
                },
              );
            },
          );
        }).toList(),
      ),
    );
  }
}

//轮播图
class CarouselWidget extends StatelessWidget {
  const CarouselWidget({
    Key? key,
    required this.bannerList,
  }) : super(key: key);

  final List bannerList;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Container(
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
                      placeholder: 'assets/images/default_banner.png',
                      image: item["pic"] as String,
                    );
                  },
                );
              }).toList(),
            ),
          )),
    );
  }
}
