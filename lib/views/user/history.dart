import 'package:flutter/material.dart';
import '../../component/loading.dart';
import '../../component/appbar.dart';
import '../../utils/request.dart';

class HistroyComponent extends StatefulWidget {
  const HistroyComponent({Key? key}) : super(key: key);

  @override
  _HistroyComponentState createState() => _HistroyComponentState();
}

class _HistroyComponentState extends State<HistroyComponent> {
  //更新日志列表
  List _historyList = [];

  @override
  void initState() {
    super.initState();
    _getUpdateInfo();
  }

  //查询更新日志
  void _getUpdateInfo() async {
    //获取更新日志
    await Request.http(url: '/version/history.json', type: 'get', data: {})
        .then((res) {
      setState(() {
        _historyList = res.data['data'];
      });
    }).catchError((error) {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBarComponent(
          const Text('更新日志'),
          elevation: 0,
          shadowColor: Colors.transparent,
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
        body: _historyList.isNotEmpty
            ? ListView(
                children: _historyList.map((item) {
                  return Card(
                      //外边距
                      margin: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                      //圆角 必须要定义下面2项才能控制4个圆角
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      clipBehavior: Clip.antiAlias,
                      child: Container(
                          color: Colors.white,
                          padding: const EdgeInsets.all(10.0),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item["version"],
                                  style: const TextStyle(
                                      color: Color(0xff333333), fontSize: 18),
                                ),
                                ...item["history_list"].map((element) {
                                  return Text(
                                    element,
                                    style: const TextStyle(
                                        color: Color(0xff666666), fontSize: 16),
                                  );
                                }).toList()
                              ])));
                }).toList(),
              )
            : const Loading());
  }
}
