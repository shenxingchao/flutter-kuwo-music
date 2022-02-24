import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import './component/loading.dart';
import './utils/request.dart';
import './views/common/play_list.dart';
import './utils/app_update.dart';
import 'store/store.dart';

class HomeComponent extends StatefulWidget {
  const HomeComponent({Key? key}) : super(key: key);

  @override
  _HomeComponentState createState() => _HomeComponentState();
}

class _HomeComponentState extends State<HomeComponent>
    with WidgetsBindingObserver {
  //APP升级对象
  late AppUpdate appUpdate;

  //当前下载进度
  double downloadPercent = 0;
  //更新日志列表
  List historyList = [];

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
    //首屏缓存，如果有缓存，则不刷新
    if (Get.find<Store>().homeCache["homeBannerList"]!.isNotEmpty) {
      setState(() {
        bannerList = Get.find<Store>().homeCache["homeBannerList"] as List;
        playList = Get.find<Store>().homeCache["homePlayList"] as List;
      });
    } else {
      onRefresh();
    }

    WidgetsBinding.instance!.addObserver(this);
    //更新app
    updateApp();
  }

  //监听APP切换状态 必须with WidgetsBindingObserver 类似继承 但是不会覆盖原有的变量方法 可以with多个类
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    //从后台隐藏状态切换到前台显示状态
    if (state == AppLifecycleState.resumed) {
      //如果进度下载进度为1 则安装APP
      if (downloadPercent >= 1) {
        appUpdate.installApk();
      }
    }
  }

  //检查app更新
  void updateApp() async {
    //检查App升级
    appUpdate = AppUpdate();
    await appUpdate.init();
    await appUpdate.checkUpdate();
    if (appUpdate.canUpdate) {
      //查询更新日志并显示
      await Request.http(url: '/version/history.json', type: 'get', data: {})
          .then((res) {
        setState(() {
          historyList = res.data['data'];
        });
      }).catchError((error) {});
      //如果可以更新 弹窗选择是否更新
      showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return UnconstrainedBox(
              //抵消Dialog的最小宽度 即可设置宽度
              constrainedAxis: Axis.vertical, //内容垂直
              child: AlertDialog(
                backgroundColor: Colors.transparent,
                contentPadding: EdgeInsets.zero,
                content: SizedBox(
                  width: Get.width * 3 / 5,
                  height: 425,
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: Image.asset(
                            'assets/images/app_update.png',
                            fit: BoxFit.fitWidth,
                            alignment: Alignment.bottomCenter,
                          ),
                        ),
                        Expanded(
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: Container(
                              color: Colors.white,
                              padding:
                                  const EdgeInsets.fromLTRB(20, 20, 20, 10),
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    flex: 1,
                                    child: SingleChildScrollView(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Padding(
                                            padding:
                                                EdgeInsets.fromLTRB(0, 0, 0, 5),
                                            child: Text(
                                              '检测到新版本',
                                              style: TextStyle(fontSize: 18),
                                            ),
                                          ),
                                          Text(historyList.first["version"]),
                                          ...historyList.first["history_list"]
                                              .map((item) {
                                            return Text(
                                              item,
                                              style:
                                                  const TextStyle(fontSize: 16),
                                            );
                                          }).toList()
                                        ],
                                      ),
                                    ),
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      TextButton(
                                        child: const Text(
                                          '下次在说',
                                          style: TextStyle(
                                              color: Color(0xff999999)),
                                        ),
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                      TextButton(
                                        child: const Text(
                                          '立即更新',
                                          style: TextStyle(
                                              color: Color(0xff333333)),
                                        ),
                                        onPressed: () async {
                                          Navigator.of(context).pop();
                                          //显示下载进度
                                          late StateSetter dialogState;
                                          showDialog(
                                              context: context,
                                              barrierDismissible: false,
                                              builder: (BuildContext context) {
                                                return StatefulBuilder(
                                                    builder: (context, state) {
                                                  dialogState = state;
                                                  return UnconstrainedBox(
                                                      //抵消Dialog的最小宽度 即可设置宽度
                                                      constrainedAxis:
                                                          Axis.vertical, //内容垂直
                                                      child: AlertDialog(
                                                        backgroundColor:
                                                            Colors.transparent,
                                                        contentPadding:
                                                            EdgeInsets.zero,
                                                        content: SizedBox(
                                                          width:
                                                              Get.width * 3 / 5,
                                                          height: 295,
                                                          child: Column(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              children: [
                                                                SizedBox(
                                                                  width: double
                                                                      .infinity,
                                                                  child: Image
                                                                      .asset(
                                                                    'assets/images/app_update.png',
                                                                    fit: BoxFit
                                                                        .fitWidth,
                                                                    alignment:
                                                                        Alignment
                                                                            .bottomCenter,
                                                                  ),
                                                                ),
                                                                Expanded(
                                                                  child: Align(
                                                                    alignment:
                                                                        Alignment
                                                                            .bottomCenter,
                                                                    child: Container(
                                                                        color: Colors.white,
                                                                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                                                                        child: Column(
                                                                          children: [
                                                                            const SizedBox(
                                                                                width: double.infinity,
                                                                                child: Padding(
                                                                                  padding: EdgeInsets.fromLTRB(0, 0, 0, 5),
                                                                                  child: Text('更新提示', style: TextStyle(fontSize: 20), textAlign: TextAlign.center),
                                                                                )),
                                                                            SizedBox(
                                                                              width: double.infinity,
                                                                              child: Text("正在更新 当前进度" + (downloadPercent * 100).toStringAsFixed(2) + '%', textAlign: TextAlign.center),
                                                                            )
                                                                          ],
                                                                        )),
                                                                  ),
                                                                ),
                                                              ]),
                                                        ),
                                                      ));
                                                });
                                              });

                                          //显示通知
                                          showNotification() async {
                                            AndroidNotificationDetails
                                                androidPlatformChannelSpecifics =
                                                AndroidNotificationDetails(
                                                    'your channel id',
                                                    'your channel name',
                                                    channelDescription:
                                                        'your channel description',
                                                    autoCancel: false,
                                                    onlyAlertOnce: true,
                                                    showProgress: true,
                                                    maxProgress: 100,
                                                    progress:
                                                        (downloadPercent * 100)
                                                            .floor(),
                                                    importance: Importance.high,
                                                    priority: Priority.high,
                                                    ticker: 'ticker');
                                            NotificationDetails
                                                platformChannelSpecifics =
                                                NotificationDetails(
                                                    android:
                                                        androidPlatformChannelSpecifics);
                                            await Get.find<Store>()
                                                .flutterLocalNotificationsPlugin
                                                ?.show(0, '下载提醒', '当前下载进度',
                                                    platformChannelSpecifics,
                                                    payload: '');
                                          }

                                          //创建下载任务
                                          try {
                                            Dio dio = Dio();
                                            await dio.download(
                                                appUpdate.downloadUrl,
                                                appUpdate.savePath,
                                                onReceiveProgress:
                                                    (received, total) {
                                              if (total != -1) {
                                                //当前下载的百分比例
                                                double percentValue =
                                                    double.parse((received /
                                                            total)
                                                        .toStringAsFixed(2));
                                                dialogState(() {
                                                  downloadPercent =
                                                      percentValue;
                                                  showNotification();
                                                });
                                              }
                                            });

                                            await appUpdate.installApk();
                                          } catch (e) {
                                            Get.find<Store>()
                                                .flutterLocalNotificationsPlugin
                                                ?.cancel(0);
                                            Fluttertoast.showToast(
                                              msg: "已取消更新",
                                            );
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ]),
                ),
              ));
        },
      );
    }
  }

  void onRefresh() async {
    await getBannerList();
    await getPlayList();
    //下拉刷新完成
    refreshController.refreshCompleted();
    //写入缓存
    Get.find<Store>().changeHomeCache({
      "homeBannerList": bannerList,
      "homePlayList": playList,
    });
  }

  //获取轮播图
  Future getBannerList() async {
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
    return res;
  }

  //获取推荐歌单
  Future getPlayList() async {
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
    return res;
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
                backgroundColor: Colors.white,
                color: Theme.of(context).colorScheme.primary),
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
                  Column(children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                      child: Container(
                        alignment: Alignment.centerLeft,
                        child: const Text(
                          '推荐歌单',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    PlayListWidget(list: playList)
                  ])
                ]))))
        : const Loading();
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
      padding: const EdgeInsets.fromLTRB(40, 20, 40, 20),
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
                      width: 30,
                      height: 30,
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
            borderRadius: BorderRadius.circular(4),
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
                      alignment: Alignment.center,
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
