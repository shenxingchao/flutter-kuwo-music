import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutterkuwomusic/views/common/mv_list.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../../component/loading.dart';
import '../../component/appbar.dart';
import '../../utils/request.dart';

class MVListComponent extends StatefulWidget {
  const MVListComponent({Key? key}) : super(key: key);

  @override
  _MVListComponentState createState() => _MVListComponentState();
}

class _MVListComponentState extends State<MVListComponent>
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
      "id": 236682871,
      "name": '首播',
    },
    {
      "id": 236682731,
      "name": '华语',
    },
    {
      "id": 236742444,
      "name": '日韩',
    },
    {
      "id": 236682773,
      "name": '网络',
    },
    {
      "id": 236682735,
      "name": '欧美',
    },
    {
      "id": 236742576,
      "name": '现场',
    },
    {
      "id": 36682777,
      "name": '热舞',
    },
    {
      "id": 236742508,
      "name": '伤感',
    },
    {
      "id": 236742578,
      "name": '剧情',
    },
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
      await getMVListByCategoryId();
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
      await getMVListByCategoryId();
      if (loadFinished) {
        //数据加载完毕
        refreshController.loadNoData();
      } else {
        //下拉加载完成
        refreshController.loadComplete();
      }
    }
  }

  //获取MV列表
  Future getMVListByCategoryId() async {
    var res = await Request.http(
        url: 'mv/getMVListByCategoryId',
        type: 'get',
        data: {
          "pid": tabItemList[tabIndex]["id"],
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
        if (res.data["data"]["mvlist"].length == 0) {
          loadFinished = true;
        } else {
          list.addAll(res.data["data"]["mvlist"]);
        }
      });
    }
    return res;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBarComponent(const Text('MV'),
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
                      delegate:
                          SliverChildListDelegate([MVListWidget(list: list)]))
                ]))
            : const Loading());
  }
}
