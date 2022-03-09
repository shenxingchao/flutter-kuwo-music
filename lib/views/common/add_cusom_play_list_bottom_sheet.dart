import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:sqflite/sqflite.dart';
import '../../utils/db.dart';

//添加到自定义歌单列表
class AddCustomPlayListBottomSheetWidget extends StatefulWidget {
  final dynamic item;
  const AddCustomPlayListBottomSheetWidget({
    Key? key,
    required this.item,
  }) : super(key: key);

  @override
  State<AddCustomPlayListBottomSheetWidget> createState() => _AddCustomPlayListBottomSheetWidgetState();
}

class _AddCustomPlayListBottomSheetWidgetState extends State<AddCustomPlayListBottomSheetWidget> {
  late dynamic musicInfo;
  late Database db;
  List customPlayList = [];

  @override
  void initState() {
    super.initState();
    musicInfo = widget.item;
    initList();
  }

  void initList() async {
    //查询自定义歌单列表
    db = await Db.instance.db;
    List<Map<String, Object?>> res = await db.rawQuery('''
                                  SELECT a.*,b.rowCount,b.pic120
                                  FROM custom_play_list AS a
                                    LEFT JOIN (
                                      SELECT custom_play_list_id,pic120,COUNT(id) AS rowCount FROM custom_play_list_content 
                                      GROUP BY custom_play_list_id
                                    ) AS b
                                    ON a.id = b.custom_play_list_id 
                                ''');
    customPlayList = res.isNotEmpty ? res : [];
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        height: Get.height / 3,
        color: Colors.white,
        child: ListView(
            //垂直列表 水平列表有滚动条哦
            scrollDirection: Axis.vertical,
            //children可以放任意的组件
            children: [
              ...customPlayList.asMap().entries.map((entry) {
                var item = entry.value;
                return ListTile(
                  contentPadding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: item["pic120"] != null
                        ? CachedNetworkImage(
                            imageUrl: item["pic120"],
                            alignment: Alignment.center,
                            fit: BoxFit.cover,
                            width: 56,
                            height: 56,
                            errorWidget: (context, url, error) => Image.asset(
                                  'assets/images/default.png',
                                  alignment: Alignment.center,
                                  fit: BoxFit.cover,
                                  width: 56,
                                  height: 56,
                                ))
                        : Image.asset(
                            'assets/images/music_bg_0.jpg',
                            alignment: Alignment.center,
                            fit: BoxFit.cover,
                            width: 56,
                            height: 56,
                          ),
                  ),
                  title: Text(
                    item["name"],
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text((item["rowCount"] != null
                          ? item["rowCount"].toString()
                          : '0') +
                      '首'),
                  tileColor: Colors.white,
                  onTap: () async {
                    //判断歌曲是否存在
                    List res = await db.query('custom_play_list_content',
                        where: 'custom_play_list_id = ? and rid = ?',
                        whereArgs: [item["id"], musicInfo["rid"]]);
                    if (res.isNotEmpty) {
                      //已存在
                      Fluttertoast.showToast(
                        msg: "当前歌单已存在该歌曲",
                      );
                      return;
                    }
                    //需要添加的数据
                    var musicItem = {
                      "custom_play_list_id": item["id"],
                      "artist": musicInfo["artist"],
                      "pic": musicInfo["pic"],
                      "rid": musicInfo["rid"],
                      "duration": musicInfo["duration"],
                      "mvPlayCnt": musicInfo["mvPlayCnt"],
                      "hasLossless": musicInfo["hasLossless"] ? 1 : 0,
                      "hasmv": musicInfo["hasmv"],
                      "releaseDate": musicInfo["releaseDate"],
                      "album": musicInfo["album"],
                      "albumid": musicInfo["albumid"],
                      "artistid": musicInfo["artistid"],
                      "songTimeMinutes": musicInfo["songTimeMinutes"],
                      "isListenFee": musicInfo["isListenFee"] ? 1 : 0,
                      "pic120": musicInfo["pic120"],
                      "albuminfo": musicInfo["albuminfo"],
                      "name": musicInfo["name"]
                    };
                    //添加到当前歌单的内容列表
                    int insertId =
                        await db.insert('custom_play_list_content', musicItem);
                    if (insertId > 0) {
                      Fluttertoast.showToast(
                        msg: "添加成功",
                      );
                      Get.back();
                    }
                  },
                );
              })
            ]));
  }
}
