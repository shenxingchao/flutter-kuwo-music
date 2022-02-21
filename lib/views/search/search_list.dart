import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../../component/appbar.dart';
import '../../component/input.dart';
import '../../component/loading.dart';
import '../../interface/play_list_music.dart';
import '../../store/store.dart';
import '../../utils/request.dart';
import '../common/bottom_bar.dart';
import '../common/music_list.dart';

class SearchListComponent extends StatefulWidget {
  const SearchListComponent({Key? key}) : super(key: key);

  @override
  _SearchListComponentState createState() => _SearchListComponentState();
}

class _SearchListComponentState extends State<SearchListComponent>
    with SingleTickerProviderStateMixin {
  //搜索关键词
  String keyword = '';
  //tab控制器
  late TabController tabController;
  //文本默认值控制器
  TextEditingController textController = TextEditingController();
  //tab选项卡列表
  List tabItemList = [
    '单曲',
    '专辑',
    'MV',
    '歌单',
    '歌手',
  ];
  //tab激活项
  int tabItemIndex = 0;
  //请求的url列表
  List<String> urlList = [
    'search/getSearchMusicList',
    'search/getSearchAlbumList',
    'search/getSearchMVList',
    'search/getSearchPlayList',
    'search/getSearchArtistList',
  ];
  //5个列表
  List<List> list = [[], [], [], [], []];
  //当前页
  List<int> pages = [1, 1, 1, 1, 1];
  //分页数
  final int pageSize = 20;
  //列表是否全部加载完成
  List<bool> loadFinisheds = [false, false, false, false, false];
  //定义刷新控件 多个
  final List<RefreshController> refreshControllers = [
    RefreshController(initialRefresh: false),
    RefreshController(initialRefresh: false),
    RefreshController(initialRefresh: false),
    RefreshController(initialRefresh: false),
    RefreshController(initialRefresh: false),
  ];

  @override
  void initState() {
    super.initState();
    //获取搜索关键词
    keyword = Get.arguments;
    //初始化tab控制器
    tabController = TabController(length: tabItemList.length, vsync: this)
      ..addListener(() {
        setState(() {
          tabItemIndex = tabController.index;
          if (list[tabItemIndex].isEmpty) {
            onRefresh();
          }
        });
      });

    //初始化文本控制器
    textController.text = keyword;
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
            data: {"key": keyword, "pn": pages[tabItemIndex], "rn": pageSize})
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
            data = res.data["data"]["list"];
            break;
          case 1:
            data = res.data["data"]["albumList"];
            break;
          case 2:
            data = res.data["data"]["mvlist"];
            break;
          case 3:
            data = res.data["data"]["list"];
            break;
          case 4:
            data = res.data["data"]["list"];
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
    return Scaffold(
        appBar: AppBarComponent(
            InputComponent(
                controller: textController,
                height: 40,
                hasBorder: false,
                isCircle: true,
                showSearchIcon: true,
                placeholder: "歌曲/歌手/歌单/MV",
                onSubmitted: (value) {
                  setState(() {
                    keyword = value;
                  });
                  onRefresh();
                }),
            appBarHeight: 120.0,
            elevation: 0,
            shadowColor: Colors.transparent,
            backgroundColor: Theme.of(context).colorScheme.primary,
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
                    tabs: tabItemList
                        .map((tabItem) => Tab(text: tabItem))
                        .toList(),
                  ),
                ))),
        body: list[tabItemIndex].isNotEmpty
            ? GetBuilder<Store>(
                //初始化store控制器
                init: Store(),
                builder: (store) {
                  return Column(children: [
                    Expanded(
                      flex: 1,
                      child: TabBarView(
                        //构建
                        controller: tabController,
                        children: tabItemList.asMap().entries.map((entry) {
                          var item = entry.value;
                          var index = entry.key;
                          return Column(children: [
                            PlayMusicListWidget(item: item, list: list),
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
                                  controller: refreshControllers[index],
                                  onRefresh: onRefresh,
                                  onLoading: onLoading,
                                  child: CustomScrollView(slivers: <Widget>[
                                    Builder(
                                      builder: (context) {
                                        if (item == '单曲') {
                                          return ListWidget(list: list[0]);
                                        } else if (item == '专辑') {
                                          return SliverList(
                                              delegate:
                                                  SliverChildListDelegate([
                                            Column(children: [
                                              ...list[1]
                                                  .asMap()
                                                  .entries
                                                  .map((entry) =>
                                                      const Text('3333'))
                                                  .toList()
                                            ])
                                          ]));
                                        } else {
                                          return SliverList(
                                              delegate:
                                                  SliverChildListDelegate([
                                            Column(
                                                children: const [Text('未完成')])
                                          ]));
                                        }
                                      },
                                    )
                                  ])),
                            )
                          ]);
                        }).toList(),
                      ),
                    ),
                    const PlayMusicBottomBar()
                  ]);
                })
            : const Loading());
  }
}

//播放全部工具栏
class PlayMusicListWidget extends StatelessWidget {
  const PlayMusicListWidget({
    Key? key,
    required this.item,
    required this.list,
  }) : super(key: key);

  final dynamic item;
  final List<List> list;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<Store>(
        //初始化store控制器
        init: Store(),
        builder: (store) {
          return Offstage(
            offstage: item != '单曲',
            child: Container(
              height: 50,
              color: Colors.white,
              child: Container(
                  height: 49.5,
                  //定义样式
                  decoration: const BoxDecoration(
                    //边框
                    border: Border(
                      bottom: BorderSide(
                        width: 0.5, //宽度
                        color: Color(0xffcccccc), //边框颜色
                      ),
                    ),
                  ),
                  child: GestureDetector(
                    //保证空白范围可点击 这里点击一行
                    behavior: HitTestBehavior.opaque,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(children: [
                          Container(
                            margin: const EdgeInsets.fromLTRB(10, 0, 5, 0),
                            child: const Icon(Icons.play_circle_outline,
                                color: Color(0xff999999)),
                          ),
                          Text('播放全部(' + list[0].length.toString() + ')首'),
                        ]),
                      ],
                    ),
                    onTap: () {
                      List<PlayListMusic> audioList = [];
                      for (var element in list[0]) {
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
            ),
          );
        });
  }
}
