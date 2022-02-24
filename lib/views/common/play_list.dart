//歌单列表
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PlayListWidget extends StatelessWidget {
  const PlayListWidget({
    Key? key,
    required this.list,
  }) : super(key: key);

  final List list;

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
          if (item["listencnt"] == null) {
            return const SizedBox();
          }
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
                                    placeholder: 'assets/images/default.png',
                                    image: item["img"],
                                  ))),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(5, 0, 0, 5),
                            child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.play_arrow_outlined,
                                    size: 18,
                                    color: Colors.white,
                                  ),
                                  //返回类型不一致 这里一致处理
                                  Text(
                                    (int.parse(item["listencnt"].toString()) /
                                                10000)
                                            .toStringAsFixed(2) +
                                        "万",
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ]),
                          ),
                        ],
                      ),
                      Container(
                        margin: const EdgeInsets.fromLTRB(0, 5, 0, 5),
                        child: Text(
                          (item["name"] as String).replaceAll('&nbsp;', ' '),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                  onTap: () {
                    Get.toNamed('/play_list_detail',
                        arguments: {"id": int.parse(item["id"].toString())});
                  },
                ),
              ));
        }).toList(),
      ),
    );
  }
}
