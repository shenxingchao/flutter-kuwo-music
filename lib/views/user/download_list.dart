import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutterkuwomusic/store/store.dart';
import 'package:flutterkuwomusic/views/common/music_list.dart';
import 'package:path_provider/path_provider.dart';
import '../../component/loading.dart';
import '../../component/appbar.dart';
import '../common/bottom_bar.dart';
import '../common/play_all_music.dart';

class DownloadListComponent extends StatefulWidget {
  const DownloadListComponent({Key? key}) : super(key: key);

  @override
  _DownloadListComponentState createState() => _DownloadListComponentState();
}

class _DownloadListComponentState extends State<DownloadListComponent> {
  //下载的歌曲列表
  List list = [];

  @override
  void initState() {
    super.initState();
    initList();
  }

  //初始化下载文件夹的歌曲列表
  void initList() async {
    list = [];
    var directory = Platform.isAndroid
        ? await getExternalStorageDirectory()
        : await getApplicationDocumentsDirectory();
    String path = directory!.path + "/download/";
    Stream<FileSystemEntity> fileList = Directory(path).list();

    //遍历文件夹下文件
    await for (FileSystemEntity fileSystemEntity in fileList) {
      //正则匹配文件歌曲名称和rid
      RegExp reg = RegExp(r".*/download/(\d+).mp3");

      RegExpMatch? res = reg.firstMatch(fileSystemEntity.path);

      if (res != null) {
        int rid = int.parse(res.group(1).toString());
        String name = box.read(rid.toString()) != null
            ? box.read(rid.toString())["music"]["name"]
            : "未知";

        list.add({
          "artist": "未知",
          "pic": "",
          "rid": rid,
          "duration": 0,
          "mvPlayCnt": 0,
          "hasLossless": false,
          "hasmv": 0,
          "releaseDate": "未知",
          "album": "未知",
          "albumid": 0,
          "artistid": 0,
          "songTimeMinutes": "未知",
          "isListenFee": false,
          "pic120": "",
          "albuminfo": "",
          "name": name,
          "isLocal": true,
        });
      }
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBarComponent(
          const Text('已下载'),
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
                      pageType: 2,
                      callback: () {
                        //删除全部后更新状态
                        setState(() {
                          initList();
                        });
                      }),
                  Expanded(
                    flex: 1,
                    child: CustomScrollView(slivers: <Widget>[
                      MusicListWidget(
                          list: list,
                          pageType: 2,
                          callback: () {
                            //删除一条后更新状态
                            setState(() {
                              initList();
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
