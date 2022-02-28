//专辑列表
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AlbumListWidget extends StatelessWidget {
  final List list;
  const AlbumListWidget({Key? key, required this.list}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
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
            children: list.map((item) {
              return FractionallySizedBox(
                  widthFactor: 1 / 3,
                  child: Padding(
                    padding: const EdgeInsets.all(5),
                    child: GestureDetector(
                      child: Column(
                        children: [
                          Stack(
                            alignment: Alignment.bottomLeft,
                            children: [
                              AspectRatio(
                                  aspectRatio: 1 / 1,
                                  child: ClipRRect(
                                      borderRadius: BorderRadius.circular(4),
                                      child: FadeInImage.assetNetwork(
                                        alignment: Alignment.center,
                                        //图片适应父组件方式  cover:等比缩放水平垂直直到2者都填满父组件 其他的没啥用了
                                        fit: BoxFit.cover,
                                        placeholder:
                                            'assets/images/default.png',
                                        image: item["pic"],
                                      ))),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(5, 0, 0, 5),
                                child:
                                    //返回类型不一致 这里一致处理
                                    Text(
                                  item["releaseDate"],
                                  style: const TextStyle(color: Colors.white),
                                ),
                              )
                            ],
                          ),
                          Container(
                            margin: const EdgeInsets.fromLTRB(0, 5, 0, 5),
                            child: Text(
                              (item["album"] as String).replaceAll('&nbsp;', ' '),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                      onTap: () {
                        Get.toNamed('/album_detail',
                            arguments: {"id": item["albumid"]});
                      },
                    ),
                  ));
            }).toList()));
  }
}
