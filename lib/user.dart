import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutterkuwomusic/component/input.dart';
import 'package:flutterkuwomusic/utils/db.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:package_info/package_info.dart';
import 'package:sqflite/sqflite.dart';

import './component/loading.dart';

class UserCommponent extends StatefulWidget {
  const UserCommponent({Key? key}) : super(key: key);

  @override
  _UserCommponentState createState() => _UserCommponentState();
}

class _UserCommponentState extends State<UserCommponent> {
  late PackageInfo packageInfo;

  bool _showLoading = true;

  //显示自定义歌单
  bool showCustomPlayList = true;
  //自定义歌单
  List customPlayList = [];

  @override
  void initState() {
    super.initState();
    _getPackageInfo();
    //获取自定义歌单
    getCustomPlayList();
  }

  //获取版本信息
  void _getPackageInfo() async {
    packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      _showLoading = false;
    });
  }

  //获取自定义歌单
  void getCustomPlayList() async {
    Database db = await Db.instance.db;
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
    return !_showLoading
        ? Column(
            children: [
              Container(
                color: Colors.white,
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('当前版本：' +
                        packageInfo.version +
                        "." +
                        packageInfo.buildNumber +
                        " ©by sxc 2022/2/13"),
                    const Text(
                        "本软件仅用于学习用途，接口皆来自于网络，版权归酷我所有，请在法律允许的范围内使用。如有侵权，请联系本人删除",
                        style:
                            TextStyle(fontSize: 12, color: Color(0xff999999)))
                  ],
                ),
              ),
              ListTile(
                contentPadding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      //背景颜色
                      color: const Color(0xffFE9EB3),
                      borderRadius: BorderRadius.circular(4)),
                  child: const Icon(
                    Icons.favorite_rounded,
                    size: 30,
                    color: Colors.red,
                  ),
                ),
                trailing: const Icon(Icons.keyboard_arrow_right,
                    color: Color(0xff999999)),
                title: const Text('我喜欢'),
                tileColor: Colors.white,
                onTap: () {
                  Get.toNamed(
                    '/favourite_list',
                  );
                },
              ),
              ListTile(
                contentPadding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      //背景颜色
                      color: const Color(0xfff7f7f7),
                      borderRadius: BorderRadius.circular(4)),
                  child: Icon(
                    Icons.download,
                    size: 30,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                trailing: const Icon(Icons.keyboard_arrow_right,
                    color: Color(0xff999999)),
                title: const Text('已下载'),
                tileColor: Colors.white,
                onTap: () {
                  Get.toNamed(
                    '/download_list',
                  );
                },
              ),
              ListTile(
                contentPadding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      //背景颜色
                      color: const Color(0xfff7f7f7),
                      borderRadius: BorderRadius.circular(4)),
                  child: Icon(
                    Icons.history,
                    size: 30,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                trailing: const Icon(Icons.keyboard_arrow_right,
                    color: Color(0xff999999)),
                title: const Text('更新日志'),
                tileColor: Colors.white,
                onTap: () {
                  Get.toNamed(
                    '/history',
                  );
                },
              ),
              ListTile(
                contentPadding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                leading: GestureDetector(
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        //背景颜色
                        color: const Color(0xfff7f7f7),
                        borderRadius: BorderRadius.circular(4)),
                    child: const Icon(
                      Icons.add,
                      size: 30,
                      color: Color(0xff333333),
                    ),
                  ),
                  onTap: () {
                    String customPlayListName = '';
                    //新建歌单
                    showDialog<String>(
                        context: context,
                        builder: (BuildContext context) => AlertDialog(
                              title: const Text('新建歌单'),
                              content: InputComponent(
                                autofocus: true,
                                height: 40,
                                hasBorder: false,
                                isCircle: true,
                                showSearchIcon: false,
                                showClearIcon: false,
                                placeholder: "请输入歌单名称",
                                onChanged: (value) {
                                  customPlayListName = value;
                                },
                              ),
                              actions: <Widget>[
                                TextButton(
                                  onPressed: () => Get.back(),
                                  child: const Text('取消'),
                                ),
                                TextButton(
                                  onPressed: () async {
                                    if (customPlayListName == '') {
                                      Fluttertoast.showToast(
                                        msg: "至少输入一个字符",
                                      );
                                      return;
                                    }

                                    Database db = await Db.instance.db;

                                    //判断歌单是否存在
                                    List res = await db.query(
                                        'custom_play_list',
                                        where: 'name = ?',
                                        whereArgs: [customPlayListName]);
                                    if (res.isNotEmpty) {
                                      //已存在
                                      Fluttertoast.showToast(
                                        msg: "歌单名称重复",
                                      );
                                      return;
                                    }

                                    //创建歌单
                                    int insertId = await db.insert(
                                        'custom_play_list',
                                        {"name": customPlayListName});
                                    if (insertId > 0) {
                                      //重置歌单列表
                                      getCustomPlayList();
                                      Get.back();
                                    }
                                  },
                                  child: const Text('确定'),
                                ),
                              ],
                            ));
                  },
                ),
                trailing: Icon(
                    showCustomPlayList
                        ? Icons.keyboard_arrow_up_outlined
                        : Icons.keyboard_arrow_down_outlined,
                    color: const Color(0xff999999)),
                title: const Text('自定义歌单'),
                tileColor: Colors.white,
                onTap: () {
                  setState(() {
                    showCustomPlayList = !showCustomPlayList;
                  });
                },
              ),
              Expanded(
                flex: 1,
                child: Offstage(
                  offstage: !showCustomPlayList,
                  child: ListView(
                    //垂直列表 水平列表有滚动条哦
                    scrollDirection: Axis.vertical,
                    children: [
                      ...customPlayList.asMap().entries.map((entry) {
                        var item = entry.value;
                        return ListTile(
                          contentPadding:
                              const EdgeInsets.fromLTRB(20, 0, 20, 0),
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: item["pic120"] != null
                                ? CachedNetworkImage(
                                    imageUrl: item["pic120"],
                                    alignment: Alignment.center,
                                    fit: BoxFit.cover,
                                    width: 56,
                                    height: 56,
                                    errorWidget: (context, url, error) =>
                                        Image.asset(
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
                          onTap: () {
                            //自定义歌单详情
                            Get.toNamed('/custom_play_list_detail',
                                arguments: {"id": item["id"]})?.then((value) {
                              //刷新
                              getCustomPlayList();
                            });
                          },
                          onLongPress: () {
                            //删除
                            showDialog<String>(
                                context: context,
                                builder: (BuildContext context) => AlertDialog(
                                      title: const Text('提示'),
                                      content: const Text('确定要删除整个歌单吗'),
                                      actions: <Widget>[
                                        TextButton(
                                          onPressed: () => Get.back(),
                                          child: const Text('取消'),
                                        ),
                                        TextButton(
                                          onPressed: () async {
                                            Database db = await Db.instance.db;

                                            int deleteCount = await db.delete(
                                                'custom_play_list',
                                                where: 'id = ?',
                                                whereArgs: [item["id"]]);

                                            if (deleteCount > 0) {
                                              Fluttertoast.showToast(
                                                msg: "删除成功",
                                              );
                                              getCustomPlayList();
                                              Get.back();
                                            }
                                          },
                                          child: const Text('确定'),
                                        ),
                                      ],
                                    ));
                          },
                        );
                      }).toList()
                    ],
                  ),
                ),
              )
            ],
          )
        : const Loading();
  }
}
