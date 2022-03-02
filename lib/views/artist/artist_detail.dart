import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../../component/loading.dart';
import '../../component/sticky_container.dart';
import '../../interface/play_list_music.dart';
import '../../store/store.dart';
import '../../utils/request.dart';
import '../common/album_list.dart';
import '../common/music_list.dart';
import '../common/bottom_bar.dart';
import '../common/mv_list.dart';

class ArtistDetailComponent extends StatefulWidget {
  const ArtistDetailComponent({Key? key}) : super(key: key);

  @override
  _ArtistDetailComponentState createState() => _ArtistDetailComponentState();
}

class _ArtistDetailComponentState extends State<ArtistDetailComponent>
    with SingleTickerProviderStateMixin {
  //路由参数
  late int id;
  //tab控制器
  late TabController tabController;
  //tab选项卡列表
  List tabItemList = [
    '单曲',
    '专辑',
    'MV',
  ];
  //tab激活项
  int tabItemIndex = 0;
  //请求的url列表
  List<String> urlList = [
    'artist/getArtistMusicList',
    'artist/getArtistAlbumList',
    'artist/getArtistMVList',
  ];
  //3个列表
  List<List> list = [[], [], []];
  //歌手信息
  dynamic artistDetail;
  //当前页
  List<int> pages = [1, 1, 1];
  //分页数
  final int pageSize = 20;
  //列表是否全部加载完成 3个
  List<bool> loadFinisheds = [false, false, false];
  //定义刷新控件 4个
  final List<RefreshController> refreshControllers = [
    RefreshController(initialRefresh: false),
    RefreshController(initialRefresh: false),
    RefreshController(initialRefresh: false),
  ];

  @override
  void initState() {
    super.initState();
    //获取路由参数
    id = Get.arguments["id"];
    //初始化tab控制器
    tabController = TabController(length: 4, vsync: this)
      ..addListener(() {
        setState(() {
          if (tabController.index == tabController.animation?.value) {
            tabItemIndex = tabController.index;
            if (tabItemIndex != 3 && list[tabItemIndex].isEmpty) {
              onRefresh();
            }
          }
        });
      });
    //获取歌手详情
    getArtistDetail();
    //下拉刷新获取第一个tabview数据
    onRefresh();
  }

  @override
  void dispose() {
    //释放controller
    tabController.dispose();
    //释放refreshControllers
    for (var element in refreshControllers) {
      element.dispose();
    }
    super.dispose();
  }

  //获取歌手详情
  Future getArtistDetail() async {
    var res = await Request.http(
        url: 'artist/getArtistDetail',
        type: 'get',
        data: {"artistid": id}).then((res) {
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
        artistDetail ??= res.data["data"];
      });
    }
    return res;
  }

  //下拉刷新方法
  void onRefresh() async {
    if (mounted) {
      setState(() {
        //重置加载状态
        loadFinisheds[tabItemIndex] = false;
        pages[tabItemIndex] = 1;
        list[tabItemIndex].clear();
        refreshControllers[tabItemIndex].loadComplete();
      });
      //获取数据
      getData();
      //下拉刷新完成
      refreshControllers[tabItemIndex].refreshCompleted();
    }
  }

  //上拉加载方法
  void onLoading() async {
    //模拟请求完成
    if (mounted) {
      setState(() {
        pages[tabItemIndex]++;
      });
      //获取数据
      await getData();
      if (loadFinisheds[tabItemIndex]) {
        //数据加载完毕
        refreshControllers[tabItemIndex].loadNoData();
      } else {
        //下拉加载完成
        refreshControllers[tabItemIndex].loadComplete();
      }
    }
  }

  //获取数据统一方法
  Future getData() async {
    var res = await Request.http(
            url: urlList[tabItemIndex],
            type: 'get',
            data: {"artistid": id, "pn": pages[tabItemIndex], "rn": pageSize})
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
      var data = [];
      setState(() {
        switch (tabItemIndex) {
          case 0:
            data = res.data["data"]["list"] ?? [];
            break;
          case 1:
            data = res.data["data"]["albumList"] ?? [];
            break;
          case 2:
            data = res.data["data"]["mvlist"] ?? [];
            break;
        }
        if (data.isEmpty) {
          loadFinisheds[tabItemIndex] = true;
        } else {
          list[tabItemIndex].addAll(data);
        }
      });
    }
    return res;
  }

  @override
  Widget build(BuildContext context) {
    return artistDetail != null
        ? Scaffold(
            body: Column(children: [
            Expanded(
                flex: 1,
                child: NestedScrollView(
                    floatHeaderSlivers: false,
                    headerSliverBuilder:
                        (BuildContext context, bool innerBoxIsScrolled) {
                      return tabItemIndex == 0
                          ? [
                              //AppBar
                              getSliverAppBar(context, innerBoxIsScrolled),
                              //吸顶工具栏
                              FixToolBarWidget(list: list[0])
                            ]
                          : [
                              //AppBar
                              getSliverAppBar(context, innerBoxIsScrolled),
                            ];
                    },
                    body: (tabItemIndex != 3
                            ? list[tabItemIndex].isNotEmpty
                            : artistDetail != null)
                        ? GetBuilder<Store>(
                            //初始化store控制器
                            init: Store(),
                            builder: (store) {
                              return TabBarView(
                                  //构建
                                  controller: tabController,
                                  children: [
                                    ...tabItemList.asMap().entries.map((entry) {
                                      var item = entry.value;
                                      var index = entry.key;
                                      return Column(children: [
                                        //内容部分
                                        Expanded(
                                          flex: 1,
                                          child: SmartRefresher(
                                              //下拉刷新
                                              enablePullDown: true,
                                              //上拉加载
                                              enablePullUp: true,
                                              //经典header 其他[ClassicHeader],[WaterDropMaterialHeader],[MaterialClassicHeader],[WaterDropHeader],[BezierCircleHeader]
                                              header: const ClassicHeader(
                                                releaseText: "松开刷新",
                                                refreshingText: '刷新中...',
                                                completeText: '刷新完成',
                                                idleText: '下拉刷新',
                                              ),
                                              footer: const ClassicFooter(
                                                canLoadingText: '松开加载',
                                                loadingText: '加载中...',
                                                idleText: '上拉加载',
                                                noDataText: '没有更多了^_^',
                                              ),
                                              controller:
                                                  refreshControllers[index],
                                              onRefresh: onRefresh,
                                              onLoading: onLoading,
                                              child: CustomScrollView(
                                                  slivers: <Widget>[
                                                    Builder(
                                                      builder: (context) {
                                                        if (item == '单曲') {
                                                          return MusicListWidget(
                                                              list: list[0]);
                                                        } else if (item ==
                                                            '专辑') {
                                                          return SliverList(
                                                              delegate:
                                                                  SliverChildListDelegate([
                                                            AlbumListWidget(
                                                                list: list[1])
                                                          ]));
                                                        } else if (item ==
                                                            'MV') {
                                                          return SliverList(
                                                              delegate:
                                                                  SliverChildListDelegate([
                                                            MVListWidget(
                                                                list: list[2])
                                                          ]));
                                                        } else {
                                                          return SliverList(
                                                              delegate:
                                                                  SliverChildListDelegate(
                                                                      []));
                                                        }
                                                      },
                                                    )
                                                  ])),
                                        )
                                      ]);
                                    }).toList(),
                                    getArticleInfoWidget(),
                                  ]);
                            })
                        : const Loading())),
            const PlayMusicBottomBar()
          ]))
        : const Loading();
  }

  //歌手简介
  SingleChildScrollView getArticleInfoWidget() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "出生地",
                      style: TextStyle(fontSize: 18),
                    ),
                    Text(
                      artistDetail["birthplace"],
                      style: const TextStyle(
                          fontSize: 14, color: Color(0xff666666)),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    const Text(
                      "性别",
                      style: TextStyle(fontSize: 18),
                    ),
                    Text(
                      artistDetail["gener"],
                      style: const TextStyle(
                          fontSize: 14, color: Color(0xff666666)),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    const Text(
                      "体重",
                      style: TextStyle(fontSize: 18),
                    ),
                    Text(
                      artistDetail["weight"],
                      style: const TextStyle(
                          fontSize: 14, color: Color(0xff666666)),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "星座",
                      style: TextStyle(fontSize: 18),
                    ),
                    Text(
                      artistDetail["constellation"],
                      style: const TextStyle(
                          fontSize: 14, color: Color(0xff666666)),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    const Text(
                      "身高",
                      style: TextStyle(fontSize: 18),
                    ),
                    Text(
                      artistDetail["tall"],
                      style: const TextStyle(
                          fontSize: 14, color: Color(0xff666666)),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    const Text(
                      "英文名",
                      style: TextStyle(fontSize: 18),
                    ),
                    Text(
                      artistDetail["aartist"]
                          .toString()
                          .replaceAll('&nbsp;', ' '),
                      style: const TextStyle(
                          fontSize: 14, color: Color(0xff666666)),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "语言",
                      style: TextStyle(fontSize: 18),
                    ),
                    Text(
                      artistDetail["language"],
                      style: const TextStyle(
                          fontSize: 14, color: Color(0xff666666)),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    const Text(
                      "粉丝数",
                      style: TextStyle(fontSize: 18),
                    ),
                    Text(
                      artistDetail["artistFans"].toString(),
                      style: const TextStyle(
                          fontSize: 14, color: Color(0xff666666)),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    const Text(
                      "所属",
                      style: TextStyle(fontSize: 18),
                    ),
                    Text(
                      artistDetail["country"].toString(),
                      style: const TextStyle(
                          fontSize: 14, color: Color(0xff666666)),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            const Text(
              "歌手简介",
              style: TextStyle(fontSize: 18),
            ),
            Text(
              artistDetail["info"]
                  .toString()
                  .replaceAll('&nbsp;', ' ')
                  .replaceAll('<br/>', '\n'),
              style: const TextStyle(fontSize: 14, color: Color(0xff666666)),
            ),
          ],
        ),
      ),
    );
  }

  //AppBar
  SliverAppBar getSliverAppBar(BuildContext context, bool innerBoxIsScrolled) {
    return SliverAppBar(
        title: Text(
          artistDetail["name"].toString().replaceAll('&nbsp;', ' '),
        ),
        foregroundColor: Colors.white,
        //appbar滚动后保持可见
        pinned: true,
        //合并后高度
        collapsedHeight: 66,
        //头部总高度
        expandedHeight: Get.width - MediaQuery.of(context).padding.top,
        //根据innerBoxIsScrolled 内部内容滚动后显示阴影 必须传否则他不知道什么时候加阴影
        forceElevated: innerBoxIsScrolled,
        //阴影深度
        elevation: 0,
        //状态栏样式
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarBrightness: Brightness.light,
          statusBarIconBrightness: Brightness.light,
        ),
        //堆栈容器,高度就是expandedHeight的高度
        flexibleSpace: FlexibleSpaceBar(
            //标题缩放
            expandedTitleScale: 1,
            //回弹模式
            stretchModes: const [
              StretchMode.zoomBackground,
              StretchMode.blurBackground
            ],
            background: SizedBox(
              child: Stack(
                //堆叠内容对齐方式
                alignment: Alignment.centerLeft,
                children: [
                  Image.network(
                    artistDetail["pic"].toString().replaceAll('/120/', '/500/'),
                    alignment: Alignment.center,
                    //图片适应父组件方式  cover:等比缩放水平垂直直到2者都填满父组件 其他的没啥用了
                    fit: BoxFit.fill,
                    width: Get.width,
                    height: Get.width,
                  ),
                  Positioned(
                      bottom: 50,
                      left: 50,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [],
                      )),
                ],
              ),
            )),
        bottom: PreferredSize(
            preferredSize: const Size.fromHeight(50),
            child: Material(
              //这里设置tab的背景色
              color: Colors.white,
              child: TabBar(
                controller: tabController,
                indicatorColor: Theme.of(context).colorScheme.primary,
                labelColor: const Color(0xff333333),
                unselectedLabelColor: const Color(0xff999999),
                tabs: [
                  ...tabItemList.map((tabItem) => Tab(text: tabItem)).toList(),
                  const Tab(text: '了解他')
                ],
              ),
            )));
  }
}

//吸顶工具栏
class FixToolBarWidget extends StatelessWidget {
  const FixToolBarWidget({
    Key? key,
    required this.list,
  }) : super(key: key);

  final List list;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<Store>(
        //初始化store控制器
        init: Store(),
        builder: (store) {
          return SliverPersistentHeader(
              pinned: true,
              delegate: StickyContainerComponent(
                  maxHeight: 50,
                  minHeight: 50,
                  builder: (context, offset, overlapsContent) {
                    return Container(
                      height: 50,
                      color: Colors.white,
                      child: SizedBox(
                          height: 50,
                          child: GestureDetector(
                            //保证空白范围可点击 这里点击一行
                            behavior: HitTestBehavior.opaque,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Row(children: [
                                  Container(
                                    margin:
                                        const EdgeInsets.fromLTRB(10, 0, 5, 0),
                                    child: const Icon(Icons.play_circle_outline,
                                        color: Color(0xff333333)),
                                  ),
                                  Text(
                                    '播放全部/' + list.length.toString() + '首',
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ]),
                              ],
                            ),
                            onTap: () {
                              List<PlayListMusic> audioList = [];

                              for (var element in list) {
                                audioList.add(PlayListMusic(
                                    artist: element["artist"],
                                    rid: element["rid"],
                                    name: element["name"],
                                    isLocal: false,
                                    pic120: element["pic120"]));
                              }

                              store.playAudioList(audioList);
                            },
                          )),
                    );
                  }));
        });
  }
}
