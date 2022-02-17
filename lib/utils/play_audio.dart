//音频播放类
import 'package:audioplayers/audioplayers.dart';
import 'package:fluttertoast/fluttertoast.dart';

class PlayAudio {
  // 工厂模式
  factory PlayAudio() => _getInstance();
  static PlayAudio get instance => _getInstance();
  static PlayAudio? _instance;

  //音频播放器
  late AudioPlayer audioPlayer;

  PlayAudio._internal() {
    //全局AudioPlayer对象只有一个实例
    audioPlayer = AudioPlayer();
  }

  static PlayAudio _getInstance() {
    _instance ??= PlayAudio._internal();
    return _instance as PlayAudio;
  }

  //开始播放
  //url mp3路径
  Future<int> playAudio({String url = ''}) async {
    int result = await audioPlayer.play(url);
    if (result != 1) {
      Fluttertoast.showToast(
        msg: "播放失败",
      );
    }
    return result;
  }

  //播放本地音乐
  //localPath 本地音乐路径
  Future<int> playLocalAudio({String localPath = ''}) async {
    int result = await audioPlayer.play(localPath, isLocal: true);
    if (result != 1) {
      Fluttertoast.showToast(
        msg: "播放失败",
      );
    }
    return result;
  }

  //暂停播放
  Future<int> pauseAudio() async {
    int result = await audioPlayer.pause();
    if (result != 1) {
      Fluttertoast.showToast(
        msg: "暂停播放失败",
      );
    }
    return result;
  }

  //停止播放
  Future<int> stopAudio() async {
    int result = await audioPlayer.stop();
    if (result != 1) {
      Fluttertoast.showToast(
        msg: "停止播放失败",
      );
    }
    return result;
  }

  //恢复播放
  Future<int> resumeAudio() async {
    int result = await audioPlayer.resume();
    if (result != 1) {
      Fluttertoast.showToast(
        msg: "恢复播放失败",
      );
    }
    return result;
  }

  //跳转到指定位置播放
  //milliseconds 毫秒
  Future<int> seekAudio({int milliseconds = 0}) async {
    int result = await audioPlayer.seek(Duration(milliseconds: milliseconds));
    if (result != 1) {
      Fluttertoast.showToast(
        msg: "跳转播放失败",
      );
    }
    return result;
  }
}
