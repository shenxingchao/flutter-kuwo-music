import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../../component/loading.dart';
import '../../component/appbar.dart';
import '../../utils/request.dart';

class RankListIndexComponent extends StatefulWidget {
  const RankListIndexComponent({Key? key}) : super(key: key);

  @override
  _RankListIndexComponentState createState() => _RankListIndexComponentState();
}

class _RankListIndexComponentState extends State<RankListIndexComponent> {
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
    var res = await Request.http(url: 'rank/getRankList', type: 'get', data: {})
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
        list = res.data["data"];
      });
    }
    return res;
  }

  //查询更新日志
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBarComponent(
          const Text('排行榜'),
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
                controller: refreshController,
                onRefresh: onRefresh,
                child: CustomScrollView(slivers: <Widget>[
                  SliverList(
                      delegate: SliverChildListDelegate([
                    ...list.map((row) {
                      return Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                            alignment: Alignment.centerLeft,
                            child: Text(
                              row["name"],
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
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
                                  ...row["list"].map((item) {
                                    return FractionallySizedBox(
                                        widthFactor: 1 / 3,
                                        child: Padding(
                                          padding: const EdgeInsets.all(5),
                                          child: GestureDetector(
                                            child: Column(
                                              children: [
                                                Stack(
                                                  alignment:
                                                      Alignment.bottomRight,
                                                  children: [
                                                    AspectRatio(
                                                        aspectRatio: 1 / 1,
                                                        child: ClipRRect(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        4),
                                                            child: FadeInImage
                                                                .assetNetwork(
                                                              alignment:
                                                                  Alignment
                                                                      .center,
                                                              //图片适应父组件方式  cover:等比缩放水平垂直直到2者都填满父组件 其他的没啥用了
                                                              fit: BoxFit.cover,
                                                              placeholder:
                                                                  'assets/images/default.png',
                                                              image:
                                                                  item["pic"],
                                                            ))),
                                                    Padding(
                                                      padding: const EdgeInsets.all(5.0),
                                                      child: Row(
                                                        mainAxisAlignment: MainAxisAlignment.end,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .center,
                                                          children: [
                                                            Text(
                                                              item["pub"],
                                                              style: const TextStyle(
                                                                  color: Colors
                                                                      .white),
                                                            ),
                                                          ]),
                                                    ),
                                                  ],
                                                ),
                                                Container(
                                                  margin:
                                                      const EdgeInsets.fromLTRB(
                                                          0, 5, 0, 5),
                                                  child: Text(
                                                    (item["name"] as String)
                                                        .replaceAll(
                                                            '&nbsp;', ' '),
                                                    maxLines: 2,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: const TextStyle(
                                                        fontSize: 14),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            onTap: () {
                                              // Get.toNamed('/rank_list_detail',
                                              //     arguments: {
                                              //       "id": int.parse(
                                              //           item["id"].toString())
                                              //     });
                                            },
                                          ),
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
