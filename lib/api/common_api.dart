//公共API
import 'package:fluttertoast/fluttertoast.dart';

import '../utils/request.dart';

class CommonApi {
  /* 
  通过歌曲Id 获取播放地址
  @param mid 歌曲id
  @param type 	类型(默认music|mv|mp3|convert_url3) mp3|convert_url3付费收费都可以 music只能返回免费的 默认会返回最佳音质(128|192|320kmp3) 不需要传格式因为无效
  */
  Future getPlayUrlById({required mid, type = "convert_url3"}) async {
    var res = await Request.http(
        url: 'play/getPlayUrl',
        type: 'get',
        data: {"mid": mid, "type": type}).then((res) {
      if (res.data["code"] != 200) {
        Fluttertoast.showToast(
          msg: res.data["msg"],
        );
      }
      return res;
    }).catchError((error) {
      //PS：这里请求前用了取消请求，防止快速点击，会弹出这个错误，所以注释掉了
      // Fluttertoast.showToast(
      //   msg: "请求服务器错误",
      // );
    });
    return res;
  }


  /* 
  通过歌曲Id 获取歌曲详情
  @param mid 歌曲id
  @param type 	类型(默认music|mv|mp3|convert_url3) mp3|convert_url3付费收费都可以 music只能返回免费的 默认会返回最佳音质(128|192|320kmp3) 不需要传格式因为无效
  */
  Future getMusicDetail({required mid}) async {
    var res = await Request.http(
        url: 'music/getMusicDetail',
        type: 'get',
        data: {"mid": mid}).then((res) {
      if (res.data["code"] != 200) {
        Fluttertoast.showToast(
          msg: res.data["msg"],
        );
      }
      return res;
    }).catchError((error) {
      //PS：这里请求前用了取消请求，防止快速点击，会弹出这个错误，所以注释掉了
      // Fluttertoast.showToast(
      //   msg: "请求服务器错误",
      // );
    });
    return res;
  }
}
