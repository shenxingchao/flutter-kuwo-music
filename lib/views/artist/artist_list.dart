import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutterkuwomusic/views/common/artist_list.dart';
import 'package:flutterkuwomusic/views/common/mv_list.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../../component/loading.dart';
import '../../component/appbar.dart';
import '../../utils/request.dart';

class ArtistListComponent extends StatefulWidget {
  const ArtistListComponent({Key? key}) : super(key: key);

  @override
  _ArtistListComponentState createState() => _ArtistListComponentState();
}

class _ArtistListComponentState extends State<ArtistListComponent>
    with SingleTickerProviderStateMixin {
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
  //定义刷新控件
  final RefreshController refreshController =
      RefreshController(initialRefresh: false);

  //tab控制器
  late TabController tabController;
  //tabIndex
  int tabIndex = 0;
  //tab选项卡列表
  List tabItemList = [
    {
      "id": 0,
      "name": '全部',
    },
    {
      "id": 1,
      "name": '华语男',
    },
    {
      "id": 2,
      "name": '华语女',
    },
    {
      "id": 3,
      "name": '华语组合',
    },
    {
      "id": 4,
      "name": '日韩男',
    },
    {
      "id": 5,
      "name": '日韩女',
    },
    {
      "id": 6,
      "name": '日韩组合',
    },
    {
      "id": 7,
      "name": '欧美男',
    },
    {
      "id": 8,
      "name": '欧美女',
    },
    {
      "id": 9,
      "name": '欧美组合',
    },
    {
      "id": 10,
      "name": '其他',
    },
  ];

  //字母筛选列表
  List wordList = [];
  //字母筛选条件
  String prefix = '';

  @override
  void initState() {
    super.initState();
    //初始化tab控制器
    tabController = TabController(length: tabItemList.length, vsync: this);
    //初始化字母表
    initWordList();
    //下拉刷新
    onRefresh();
  }

  @override
  void dispose() {
    //释放controller
    tabController.dispose();
    super.dispose();
  }

  //初始化字母表
  void initWordList() {
    for (var i = 65; i <= 90; i++) {
      wordList.add(String.fromCharCode(i));
    }
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
      await getArtistList();
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
      await getArtistList();
      if (loadFinished) {
        //数据加载完毕
        refreshController.loadNoData();
      } else {
        //下拉加载完成
        refreshController.loadComplete();
      }
    }
  }

  //获取歌手列表
  Future getArtistList() async {
    var res =
        await Request.http(url: 'artist/getArtistList', type: 'get', data: {
      "category": tabItemList[tabIndex]["id"],
      "prefix": prefix,
      "pn": page,
      "rn": pageSize
    }).then((res) {
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
        if (res.data["data"]["artistList"].length == 0) {
          loadFinished = true;
        } else {
          list.addAll(res.data["data"]["artistList"]);
        }
      });
    }
    return res;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBarComponent(const Text('歌手'),
            appBarHeight: 116,
            elevation: 0,
            shadowColor: Colors.transparent,
            backgroundColor: Theme.of(context).colorScheme.primary,
            //状态栏样式
            systemOverlayStyle: const SystemUiOverlayStyle(
              statusBarBrightness: Brightness.light,
              statusBarIconBrightness: Brightness.light,
            ),
            bottom: PreferredSize(
                preferredSize: const Size.fromHeight(50),
                child: Material(
                  //这里设置tab的背景色
                  color: Colors.white,
                  child: TabBar(
                    controller: tabController,
                    isScrollable: true,
                    indicatorColor: Theme.of(context).colorScheme.primary,
                    labelColor: const Color(0xff333333),
                    unselectedLabelColor: const Color(0xff999999),
                    tabs: tabItemList
                        .map((tabItem) => Tab(text: tabItem["name"]))
                        .toList(),
                    onTap: (index) {
                      setState(() {
                        tabIndex = index;
                        onRefresh();
                      });
                    },
                  ),
                ))),
        body: list.isNotEmpty
            ? Stack(children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 30, 0),
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
                        SliverList(
                            delegate: SliverChildListDelegate(
                                [ArtistListWidget(list: list)]))
                      ])),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  bottom: 10,
                  child: Container(
                    color: const Color(0x0f000000),
                    child: Column(children: [
                      ...wordList.map((item) {
                        return Expanded(
                          flex: 1,
                          child: GestureDetector(
                              //保证空白范围可点击 这里点击一行
                              behavior: HitTestBehavior.opaque,
                              child: Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(10, 0, 10, 0),
                                child: Center(
                                  child: Text(
                                    item,
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                              onTap: () {
                                setState(() {
                                  prefix = item;
                                  onRefresh();
                                });
                              }),
                        );
                      }).toList()
                    ]),
                  ),
                )
              ])
            : const Loading());
  }
}
