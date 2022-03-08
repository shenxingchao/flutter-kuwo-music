import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutterkuwomusic/views/common/music_list.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:sqflite/sqflite.dart';
import '../../component/loading.dart';
import '../../component/appbar.dart';
import '../../utils/db.dart';
import '../common/bottom_bar.dart';
import '../common/play_all_music.dart';

class CustomPlayListDetailComponent extends StatefulWidget {
  const CustomPlayListDetailComponent({Key? key}) : super(key: key);

  @override
  _CustomPlayListDetailComponentState createState() =>
      _CustomPlayListDetailComponentState();
}

class _CustomPlayListDetailComponentState
    extends State<CustomPlayListDetailComponent> {
  //路由参数
  late int id;

  //歌单的歌曲列表
  List list = [];

  @override
  void initState() {
    super.initState();
    //获取路由参数
    id = Get.arguments["id"];
    initList();
  }

  //初始化歌曲列表
  void initList() async {
    Database db = await Db.instance.db;
    List<Map<String, Object?>> res = await db.query('custom_play_list_content',
        where: 'custom_play_list_id = ?', whereArgs: [id]);
    list = [];

    for (var item in res) {
      var map = Map<String, Object?>.from(item);
      map["hasLossless"] = map["hasLossless"] == 1 ? true : false;
      map["isListenFee"] = map["isListenFee"] == 1 ? true : false;
      list.add(map);
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBarComponent(
          const Text('歌单详情'),
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
                      pageType: 3,
                      callback: () async {
                        Database db = await Db.instance.db;

                        int deleteCount = await db.delete(
                            'custom_play_list_content',
                            where: 'custom_play_list_id = ?',
                            whereArgs: [id]);
                        if (deleteCount > 0) {
                          Fluttertoast.showToast(
                            msg: "删除成功",
                          );

                          //删除全部后更新状态
                          initList();
                        }
                      }),
                  Expanded(
                    flex: 1,
                    child: CustomScrollView(slivers: <Widget>[
                      MusicListWidget(
                          list: list,
                          pageType: 3,
                          callback: (int rid) async {
                            Database db = await Db.instance.db;

                            int deleteCount = await db.delete(
                                'custom_play_list_content',
                                where: 'custom_play_list_id = ? and rid = ?',
                                whereArgs: [id, rid]);

                            if (deleteCount > 0) {
                              Fluttertoast.showToast(
                                msg: "删除成功",
                              );

                              //删除一条后更新状态
                              initList();
                            }
                          })
                    ]),
                  ),
                  const PlayMusicBottomBar()
                ],
              )
            : const Loading());
  }
}
