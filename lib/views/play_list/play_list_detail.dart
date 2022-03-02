import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutterkuwomusic/views/common/bottom_bar.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../../component/loading.dart';
import '../../component/sticky_container.dart';
import '../../interface/play_list_music.dart';
import '../../store/store.dart';
import '../../utils/request.dart';
import '../common/music_list.dart';

class PlayListDetailComponent extends StatefulWidget {
  const PlayListDetailComponent({Key? key}) : super(key: key);

  @override
  _PlayListDetailComponentState createState() =>
      _PlayListDetailComponentState();
}

class _PlayListDetailComponentState extends State<PlayListDetailComponent> {
  //路由参数
  late int id;
  //歌曲列表
  List list = [];
  //歌单信息
  dynamic playList;
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
  //标题和状态栏颜色 收缩时显示黑色 展开式显示白色
  bool lightTheme = true;

  @override
  void initState() {
    super.initState();
    //获取路由参数
    id = Get.arguments["id"];
    onRefresh();
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
      await getMusicListByPlayListId();
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
      await getMusicListByPlayListId();
      if (loadFinished) {
        //数据加载完毕
        refreshController.loadNoData();
      } else {
        //下拉加载完成
        refreshController.loadComplete();
      }
    }
  }

  //通过歌单Id获取音乐列表
  Future getMusicListByPlayListId() async {
    var res = await Request.http(
        url: 'playList/getMusicListByPlayListId',
        type: 'get',
        data: {"pid": id, "pn": page, "rn": pageSize}).then((res) {
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
        playList ??= res.data["data"];
        if (res.data["data"]["musicList"].length == 0) {
          loadFinished = true;
        } else {
          list.addAll(res.data["data"]["musicList"]);
        }
      });
    }
    return res;
  }

  @override
  Widget build(BuildContext context) {
    return playList != null
        ? Scaffold(
            body: Column(children: [
            Expanded(
                flex: 1,
                child:
                    // NotificationListener(
                    // onNotification: (ScrollNotification notification) {
                    //   if (notification is ScrollUpdateNotification &&
                    //       notification.depth == 0) {
                    //     double maxHight =
                    //         Get.width - MediaQuery.of(context).padding.top - 66;
                    //     //尽量不要每次滚动都去setState
                    //     if (notification.metrics.pixels >= maxHight &&
                    //         lightTheme) {
                    //       setState(() {
                    //         lightTheme = false;
                    //       });
                    //     } else if (notification.metrics.pixels < maxHight &&
                    //         !lightTheme) {
                    //       setState(() {
                    //         lightTheme = true;
                    //       });
                    //     }
                    //   }
                    //   return true;
                    // },
                    // child:       // ),
                    NestedScrollView(
                        floatHeaderSlivers: false,
                        headerSliverBuilder:
                            (BuildContext context, bool innerBoxIsScrolled) {
                          return [
                            //AppBar
                            getSliverAppBar(context, innerBoxIsScrolled),
                            //吸顶工具栏
                            FixToolBarWidget(list: list)
                          ];
                        },
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
                                  MusicListWidget(list: list)
                                ]))
                            : const Loading())),
            const PlayMusicBottomBar()
          ]))
        : const Loading();
  }

  //AppBar
  SliverAppBar getSliverAppBar(BuildContext context, bool innerBoxIsScrolled) {
    return SliverAppBar(
      title: Text(
        playList["name"],
      ),
      foregroundColor: lightTheme ? Colors.white : Colors.white,
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
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarBrightness: lightTheme ? Brightness.light : Brightness.light,
        statusBarIconBrightness:
            lightTheme ? Brightness.light : Brightness.light,
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
                  playList["img700"],
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
                      children: [
                        ClipOval(
                          child: Image.network(
                            playList["uPic"],
                            alignment: Alignment.center,
                            //图片适应父组件方式  cover:等比缩放水平垂直直到2者都填满父组件 其他的没啥用了
                            fit: BoxFit.cover,
                            width: 50,
                            height: 50,
                            errorBuilder: (BuildContext context,
                                Object exception, StackTrace? stackTrace) {
                              return Image.asset(
                                'assets/images/default.png',
                                fit: BoxFit.cover,
                                width: 50,
                                height: 50,
                              );
                            },
                          ),
                        ),
                        Text(
                          playList["uname"],
                          style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                        Text(
                          '共' + playList["total"].toString() + "首",
                          style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                        Text(
                          '播放' +
                              (playList["listencnt"] / 10000)
                                  .toStringAsFixed(2) +
                              "万",
                          style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                      ],
                    )),
              ],
            ),
          )),
    );
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
                                    pic120:  element["pic120"] ?? ''));
                              }

                              store.playAudioList(audioList);
                            },
                          )),
                    );
                  }));
        });
  }
}
