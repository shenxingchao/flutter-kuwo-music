import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../../component/loading.dart';
import '../../component/appbar.dart';
import '../../utils/request.dart';
import '../../views/common/play_list.dart';

class PlayListCategoryListComponent extends StatefulWidget {
  const PlayListCategoryListComponent({Key? key}) : super(key: key);

  @override
  _PlayListCategoryListComponentState createState() =>
      _PlayListCategoryListComponentState();
}

class _PlayListCategoryListComponentState
    extends State<PlayListCategoryListComponent> {
  //路由参数
  late int id;
  late String categoryTitle;
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

  @override
  void initState() {
    super.initState();
    //获取路由参数
    id = Get.arguments["id"];
    categoryTitle = Get.arguments["name"];
    //下拉刷新
    onRefresh();
  }

  @override
  void dispose() {
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
        url: 'playList/getPlayListByCategoryId',
        type: 'get',
        data: {"id": id, "pn": page, "rn": pageSize}).then((res) {
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

  //查询更新日志
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBarComponent(
          Text(categoryTitle),
          elevation: 0,
          shadowColor: Colors.transparent,
          backgroundColor: Theme.of(context).colorScheme.primary,
          //状态栏样式
          systemOverlayStyle: const SystemUiOverlayStyle(
            statusBarBrightness: Brightness.light,
            statusBarIconBrightness: Brightness.light,
          ),
        ),
        body: list.isNotEmpty
            ? SmartRefresher(
                //下拉刷新
                enablePullDown: true,
                //上拉加载
                enablePullUp: true,
                //经典header 其他[ClassicHeader],[WaterDropMaterialHeader],[MaterialClassicHeader],[WaterDropHeader],[BezierCircleHeader]
                header: WaterDropMaterialHeader(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    color: Colors.white),
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
                          SliverChildListDelegate([PlayListWidget(list: list)]))
                ]))
            : const Loading());
  }
}
