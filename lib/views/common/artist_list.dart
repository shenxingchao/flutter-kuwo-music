//专辑列表
import 'package:flutter/material.dart';

class ArtistListWidget extends StatelessWidget {
  final List list;
  const ArtistListWidget({Key? key, required this.list}) : super(key: key);

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
                  widthFactor: 1 / 4,
                  child: Padding(
                    padding: const EdgeInsets.all(5),
                    child: GestureDetector(
                      child: Column(
                        children: [
                          AspectRatio(
                              aspectRatio: 1 / 1,
                              child: Container(
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(50),
                                      boxShadow: const [
                                        BoxShadow(
                                          offset: Offset(0, 0), //x,y轴
                                          color: Color(0xffcccccc), //投影颜色
                                          blurRadius: 4, //投影距离
                                        )
                                      ]),
                                  child: ClipOval(
                                      child: FadeInImage.assetNetwork(
                                    alignment: Alignment.topRight,
                                    //图片适应父组件方式  cover:等比缩放水平垂直直到2者都填满父组件 其他的没啥用了
                                    fit: BoxFit.cover,
                                    placeholder: 'assets/images/default.png',
                                    image: item["pic"],
                                  )))),
                          Container(
                            margin: const EdgeInsets.fromLTRB(0, 5, 0, 5),
                            child: Text(
                              item["name"],
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                        ],
                      ),
                      onTap: () {
                        // Get.toNamed('/artist_detail',
                        //     arguments: {"id": item["id"].toString()});
                      },
                    ),
                  ));
            }).toList()));
  }
}
