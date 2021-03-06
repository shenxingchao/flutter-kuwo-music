import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../../component/appbar.dart';
import '../../component/input.dart';
import '../../component/loading.dart';
import '../../interface/play_list_music.dart';
import '../../store/store.dart';
import '../../utils/request.dart';
import '../common/album_list.dart';
import '../common/artist_list.dart';
import '../common/bottom_bar.dart';
import '../common/music_list.dart';
import '../common/mv_list.dart';
import '../common/play_list.dart';

class SearchListComponent extends StatefulWidget {
  const SearchListComponent({Key? key}) : super(key: key);

  @override
  _SearchListComponentState createState() => _SearchListComponentState();
}

class _SearchListComponentState extends State<SearchListComponent>
    with SingleTickerProviderStateMixin {
  //搜索关键词
  String keyword = '';
  //是否显示搜索结果 输入框由内容 且不改变字符时显示 否则显示关键词列表
  bool showContent = false;
  //关键词列表
  List keywordList = [];
  //用于失去焦点
  FocusNode inputFocus = FocusNode();
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
    //初始化tab控制器
    tabController = TabController(length: tabItemList.length, vsync: this)
      ..addListener(() {
        setState(() {
          if (tabController.index == tabController.animation?.value) {
            tabItemIndex = tabController.index;
            if (list[tabItemIndex].isEmpty) {
              onRefresh();
            }
          }
        });
      });
    //初始化文本控制器
    textController.text = keyword;
    //获取搜索关键词
    getSearchKey();
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
            data = res.data["data"]["list"] ?? [];
            break;
          case 1:
            data = res.data["data"]["albumList"] ?? [];
            break;
          case 2:
            data = res.data["data"]["mvlist"] ?? [];
            break;
          case 3:
            data = res.data["data"]["list"] ?? [];
            break;
          case 4:
            data = res.data["data"]["list"] ?? [];
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

  //获取关键词
  Future getSearchKey() async {
    var res =
        await Request.http(url: 'search/getSearchKey', type: 'get', data: {
      "key": keyword,
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
        keywordList = res.data["data"];
      });
    }
    return res;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        //flutter 键盘推动Stack子控件上移问题
        resizeToAvoidBottomInset: false,
        appBar: AppBarComponent(
            InputComponent(
                focusNode: inputFocus,
                controller: textController,
                autofocus: true,
                height: 40,
                hasBorder: false,
                isCircle: true,
                showSearchIcon: true,
                showClearIcon: true,
                placeholder: "歌曲/歌手/歌单/MV",
                onSubmitted: (value) {
                  if (keyword != '') {
                    //状态初始化
                    setState(() {
                      list = [[], [], [], [], []];
                      pages = [1, 1, 1, 1, 1];
                      showContent = true;
                    });
                    onRefresh();
                  }
                },
                onTap: () {
                  setState(() {
                    showContent = false;
                  });
                },
                onChanged: (value) {
                  setState(() {
                    keyword = value;
                    getSearchKey();
                  });
                }),
            appBarHeight: showContent ? 120 : 70,
            elevation: 0,
            shadowColor: Colors.transparent,
            backgroundColor: Theme.of(context).colorScheme.primary,
            //状态栏样式
            systemOverlayStyle: const SystemUiOverlayStyle(
              statusBarBrightness: Brightness.light,
              statusBarIconBrightness: Brightness.light,
            ),
            bottom: PreferredSize(
                preferredSize: Size.fromHeight(showContent ? 50 : 0),
                child: Offstage(
                  offstage: !showContent,
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
                  ),
                ))),
        body: showContent
            ? (list[tabItemIndex].isNotEmpty
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
                                //播放全部工具栏
                                PlayMusicListWidget(item: item, list: list[0]),
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
                                      controller: refreshControllers[index],
                                      onRefresh: onRefresh,
                                      onLoading: onLoading,
                                      child: CustomScrollView(slivers: <Widget>[
                                        Builder(
                                          builder: (context) {
                                            if (item == '单曲') {
                                              return MusicListWidget(
                                                  list: list[0]);
                                            } else if (item == '专辑') {
                                              return SliverList(
                                                  delegate:
                                                      SliverChildListDelegate([
                                                AlbumListWidget(list: list[1])
                                              ]));
                                            } else if (item == 'MV') {
                                              return SliverList(
                                                  delegate:
                                                      SliverChildListDelegate([
                                                MVListWidget(list: list[2])
                                              ]));
                                            } else if (item == '歌单') {
                                              return SliverList(
                                                  delegate:
                                                      SliverChildListDelegate([
                                                PlayListWidget(list: list[3])
                                              ]));
                                            } else if (item == '歌手') {
                                              return SliverList(
                                                  delegate:
                                                      SliverChildListDelegate([
                                                ArtistListWidget(list: list[4])
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
                          ),
                        ),
                        const PlayMusicBottomBar()
                      ]);
                    })
                : const Loading())
            : ListView.builder(
                //list长度必填
                itemCount: keywordList.length,
                //创建回调函数
                itemBuilder: (context, index) {
                  RegExp reg = RegExp(r"RELWORD=(.*)\r\nSNUM=.*");
                  RegExpMatch? res = reg.firstMatch(keywordList[index]);
                  String title =
                      res != null ? res.group(1) as String : keywordList[index];

                  return ListTile(
                    title: Text(title),
                    onTap: () {
                      //失去焦点
                      inputFocus.unfocus();
                      //点击直接搜索
                      setState(() {
                        list = [[], [], [], [], []];
                        pages = [1, 1, 1, 1, 1];
                        keyword = title;
                        textController.text = keyword;
                        showContent = true;
                      });
                      onRefresh();
                    },
                  );
                }));
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
  final List list;

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
                            margin: const EdgeInsets.fromLTRB(10, 0, 5, 0),
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
            ),
          );
        });
  }
}
