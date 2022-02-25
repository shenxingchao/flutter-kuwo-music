import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutterkuwomusic/views/common/music_list.dart';
import '../../component/loading.dart';
import '../../component/appbar.dart';
import '../../store/store.dart';
import '../common/bottom_bar.dart';
import '../common/play_all_music.dart';

class FavouriteListComponent extends StatefulWidget {
  const FavouriteListComponent({Key? key}) : super(key: key);

  @override
  _FavouriteListComponentState createState() => _FavouriteListComponentState();
}

class _FavouriteListComponentState extends State<FavouriteListComponent> {
  //收藏的歌曲列表
  List list = [];

  @override
  void initState() {
    super.initState();
    initList();
  }

  //初始化缓存中收藏的歌曲列表
  void initList() async {
    list = box.read('favouriteMusicList') ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBarComponent(
          const Text('收藏的歌曲列表'),
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
            ? Column(
                children: [
                  PlayAllMusicWidget(
                      list: list,
                      pageType: 1,
                      callback: () {
                        //删除全部后更新状态
                        setState(() {
                          list = box.read('favouriteMusicList') ?? [];
                        });
                      }),
                  Expanded(
                    flex: 1,
                    child: CustomScrollView(slivers: <Widget>[
                      MusicListWidget(
                          list: list,
                          pageType: 1,
                          callback: () {
                            //删除一条后更新状态
                            setState(() {
                              list = box.read('favouriteMusicList') ?? [];
                            });
                          })
                    ]),
                  ),
                  const PlayMusicBottomBar()
                ],
              )
            : const Loading());
  }
}
