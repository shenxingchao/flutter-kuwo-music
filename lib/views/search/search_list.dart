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

  //列表
  List list = [];
  //当前页
  int page = 1;
  //分页数
  final int pageSize = 20;
  //初次进入页面显示加载动画 后续显示下拉刷新动画
  bool showLoading = true;
  //列表是否全部加载完成
  bool loadFinished = false;
  //定义刷新控件 多个
  final RefreshController refreshController =
      RefreshController(initialRefresh: false);

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
          onRefresh();
        });
      });

    //初始化文本控制器
    textController.text = keyword;
    //下拉刷新获取数据
    onRefresh();
  }

  @override
  void dispose() {
    //释放controller
    tabController.dispose();
    refreshController.dispose();
    super.dispose();
  }

  //下拉刷新方法
  void onRefresh() async {
    if (mounted) {
      setState(() {
        //重置加载状态
        loadFinished = false;
        page = 1;
        list.clear();
        refreshController.loadComplete();
      });
      //获取数据
      getData();
      //下拉刷新完成
      refreshController.refreshCompleted();
      //首次渲染完成
      showLoading = false;
    }
  }

//上拉加载方法
  void onLoading() async {
    //模拟请求完成
    if (mounted) {
      setState(() {
        page++;
      });
      //获取数据
      getData();
      if (loadFinished) {
        //数据加载完毕
        refreshController.loadNoData();
      } else {
        //下拉加载完成
        refreshController.loadComplete();
      }
    }
  }

  //获取数据统一方法
  void getData() async {
    switch (tabItemIndex) {
      case 0:
        //获取搜索列表-歌曲
        await getSearchMusicList();
        break;
      case 1:
        //获取搜索列表-专辑
        await getSearchAlbumList();
        break;
      default:
        break;
    }
  }

  //获取搜索列表-歌曲
  Future getSearchMusicList() async {
    var res = await Request.http(
        url: 'search/getSearchMusicList',
        type: 'get',
        data: {"key": keyword, "pn": page, "rn": pageSize}).then((res) {
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
        if (res.data["data"]["list"].length == 0) {
          loadFinished = true;
        } else {
          list.addAll(res.data["data"]["list"]);
        }
      });
    }
    return res;
  }

  //获取搜索列表-歌曲
  Future getSearchAlbumList() async {
    var res = await Request.http(
        url: 'search/getSearchAlbumList',
        type: 'get',
        data: {"key": keyword, "pn": page, "rn": pageSize}).then((res) {
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
        if (res.data["data"]["albumList"].length == 0) {
          loadFinished = true;
        } else {
          list.addAll(res.data["data"]["albumList"]);
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
                    onTap: (e) {
                      setState(() {
                        tabItemIndex = e;
                        onRefresh();
                      });
                    },
                  ),
                ))),
        body: list.isNotEmpty
            ? GetBuilder<Store>(
                //初始化store控制器
                init: Store(),
                builder: (store) {
                  return TabBarView(
                    //构建
                    controller: tabController,
                    children: tabItemList.map((e) {
                      return Column(children: [
                        Offstage(
                          offstage: e != '单曲',
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Row(children: [
                                        Container(
                                          margin: const EdgeInsets.fromLTRB(
                                              10, 0, 5, 0),
                                          child: const Icon(
                                              Icons.play_circle_outline,
                                              color: Color(0xff999999)),
                                        ),
                                        Text('播放全部(' +
                                            list.length.toString() +
                                            ')首'),
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
                          ),
                        ),
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
                              controller: refreshController,
                              onRefresh: onRefresh,
                              onLoading: onLoading,
                              child: CustomScrollView(slivers: <Widget>[
                                Builder(builder: (context) {
                                  if (e == '单曲') {
                                    return ListWidget(list: list);
                                  } else {
                                    return SliverList(
                                        delegate: SliverChildListDelegate([
                                      Column(children: [
                                        ...list
                                            .asMap()
                                            .entries
                                            .map((entry) => Text('3333'))
                                            .toList()
                                      ])
                                    ]));
                                  }
                                })
                              ])),
                        ),
                      ]);
                    }).toList(),
                  );
                })
            : const Loading());
  }
}
