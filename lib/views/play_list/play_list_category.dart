import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../../component/loading.dart';
import '../../component/appbar.dart';
import '../../utils/request.dart';

class PlayListCategoryComponent extends StatefulWidget {
  const PlayListCategoryComponent({Key? key}) : super(key: key);

  @override
  _PlayListCategoryComponentState createState() =>
      _PlayListCategoryComponentState();
}

class _PlayListCategoryComponentState extends State<PlayListCategoryComponent> {
  //列表
  List list = [];

  //定义刷新控件
  final RefreshController refreshController =
      RefreshController(initialRefresh: false);

  @override
  void initState() {
    super.initState();
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
        list.clear();
        refreshController.loadComplete();
      });
      await getGoodPlayList();
      //下拉刷新完成
      refreshController.refreshCompleted();
    }
  }

  //获取歌单列表
  Future getGoodPlayList() async {
    var res = await Request.http(
        url: 'playList/getPlayListCategoryList',
        type: 'get',
        data: {}).then((res) {
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
        list = res.data["data"];
      });
    }
    return res;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBarComponent(
          const Text('歌单分类'),
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
                child: CustomScrollView(slivers: <Widget>[
                  SliverList(
                      delegate: SliverChildListDelegate([
                    ...list.map((row) {
                      return Column(
                        children: [
                          Offstage(
                            offstage: row["data"].length == 0,
                            child: Container(
                              padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                              alignment: Alignment.centerLeft,
                              child: Text(
                                row["name"],
                                style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xff999999)),
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
                                children: [
                                  ...row["data"].map((item) {
                                    return FractionallySizedBox(
                                        widthFactor: 1 / 4,
                                        child: GestureDetector(
                                          child: Column(
                                            children: [
                                              Container(
                                                margin:
                                                    const EdgeInsets.fromLTRB(
                                                        0, 5, 0, 5),
                                                padding:
                                                    const EdgeInsets.fromLTRB(
                                                        20, 5, 20, 5),
                                                color: const Color(0xffeeeeee),
                                                child: Text(
                                                  item["name"],
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: const TextStyle(
                                                      fontSize: 14),
                                                ),
                                              ),
                                            ],
                                          ),
                                          onTap: () {
                                            Get.toNamed(
                                                '/play_list_category_list',
                                                arguments: {
                                                  "id": int.parse(
                                                      item["id"].toString()),
                                                  "name": item["name"],
                                                });
                                          },
                                        ));
                                  }).toList(),
                                ]),
                          )
                        ],
                      );
                    }).toList()
                  ]))
                ]))
            : const Loading());
  }
}
