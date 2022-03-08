//专辑列表
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ArtistListWidget extends StatelessWidget {
  final List list;
  const ArtistListWidget({Key? key, required this.list}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Wrap(
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
        children: list.map((item) {
          return ListTile(
            contentPadding: const EdgeInsets.all(10),
            leading: ClipOval(
                child: FadeInImage.assetNetwork(
              alignment: Alignment.center,
              //图片适应父组件方式  cover:等比缩放水平垂直直到2者都填满父组件 其他的没啥用了
              fit: BoxFit.cover,
              placeholder: 'assets/images/default_cricle.png',
              image: item["pic"],
            )),
            title: Text(
              item["name"],
              style: const TextStyle(fontSize: 16),
            ),
            subtitle: Row(
                children: item["aartist"] != null
                    ? [
                        Text(item["aartist"]),
                        Text(" 专辑 " + item["albumNum"].toString()),
                        Text(" 歌曲 " + item["musicNum"].toString()),
                      ]
                    : [
                        Text(item["country"]),
                        Text(" 歌曲 " + item["musicNum"].toString()),
                      ]),
            trailing: Offstage(
              offstage: item["aartist"] != null,
              child: const Icon(Icons.keyboard_arrow_right,
                  color: Color(0xff999999)),
            ),
            onTap: () {
              Get.toNamed('/artist_detail', arguments: {"id": item["id"]});
            },
          );
        }).toList());
  }
}
