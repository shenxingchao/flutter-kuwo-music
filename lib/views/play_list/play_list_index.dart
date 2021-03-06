import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../../component/loading.dart';
import '../../component/appbar.dart';
import '../../utils/request.dart';
import '../common/play_list.dart';

class PlayListIndexComponent extends StatefulWidget {
  const PlayListIndexComponent({Key? key}) : super(key: key);

  @override
  _PlayListIndexComponentState createState() => _PlayListIndexComponentState();
}

class _PlayListIndexComponentState extends State<PlayListIndexComponent>
    with SingleTickerProviderStateMixin {
  //歌单列表
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

  //搜索条件
  String order = 'hot';

  //tab控制器
  late TabController tabController;
  //tab选项卡列表
  List tabItemList = [
    '最热',
    '最新',
  ];

  @override
  void initState() {
    super.initState();
    //初始化tab控制器
    tabController = TabController(length: tabItemList.length, vsync: this);
    //下拉刷新
    onRefresh();
  }

  @override
  void dispose() {
    //释放controller
    tabController.dispose();
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
      await getGoodPlayList();
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
      await getGoodPlayList();
      if (loadFinished) {
        //数据加载完毕
        refreshController.loadNoData();
      } else {
        //下拉加载完成
        refreshController.loadComplete();
      }
    }
  }

  //获取歌单列表
  Future getGoodPlayList() async {
    var res = await Request.http(
        url: 'playList/getGoodPlayList',
        type: 'get',
        data: {"order": order, "pn": page, "rn": pageSize}).then((res) {
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
        if (res.data["data"]["data"].length == 0) {
          loadFinished = true;
        } else {
          list.addAll(res.data["data"]["data"]);
        }
      });
    }
    return res;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBarComponent(const Text('精选歌单'),
            appBarHeight: 116,
            elevation: 0,
            shadowColor: Colors.transparent,
            backgroundColor: Theme.of(context).colorScheme.primary,
            rightIcon: [
              Material(
                  color: Colors.transparent,
                  child: InkWell(
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      child: const Icon(
                        Icons.menu,
                        color: Colors.white,
                      ),
                    ),
                    onTap: () {
                      Get.toNamed('play_list_category');
                    },
                  )),
            ],
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
                    indicatorColor: Theme.of(context).colorScheme.primary,
                    labelColor: const Color(0xff333333),
                    unselectedLabelColor: const Color(0xff999999),
                    tabs: tabItemList
                        .map((tabItem) => Tab(text: tabItem))
                        .toList(),
                    onTap: (tabIndex) {
                      if (tabIndex == 0 && order != 'hot') {
                        setState(() {
                          order = 'hot';
                          onRefresh();
                        });
                      } else if (tabIndex == 1 && order != 'new') {
                        setState(() {
                          order = 'new';
                          onRefresh();
                        });
                      }
                    },
                  ),
                ))),
        body: list.isNotEmpty
            ? SmartRefresher(
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
                      delegate: SliverChildListDelegate([
                    PlayListWidget(
                      list: list,
                      column: 2,
                    )
                  ]))
                ]))
            : const Loading());
  }
}
