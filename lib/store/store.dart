import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutterkuwomusic/interface/play_list_music.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../api/common_api.dart';
import '../interface/play_music_info.dart';
import '../utils/play_audio.dart';

//全局变量start
//本地缓存对象
var box = GetStorage();
//主题色列表
List<Color> themeList = [
  const Color(0xffFFDF1F),
  const Color(0xff40A7FF),
  const Color(0xff00ED93),
  const Color(0xffFF9B9D),
  const Color(0xffC986FF),
];
//全局变量end

//类似vuex状态管理类
class Store extends GetxController {
  //主题色
  Color primary = box.read('primary') != null
      ? themeList[box.read('primary')]
      : themeList[0];

  //当前播放的歌曲信息对象
  PlayMusicInfo? playMusicInfo;

  //当前播放列表
  List<PlayListMuisc> playListMuisc = [];

  //正在播放音频的播放状态
  PlayerState audioPlayState = PlayerState.STOPPED;

  //更换主题色
  void changeTheme(Color color) {
    primary = color;
    update();
  }

  //更新播放列表
  void changePlayListMuisc(List<PlayListMuisc> playListMusic) {
    playListMuisc = playListMusic;
    update();
  }

  //播放audio方法统一方法
  void playMusic({required int rid}) async {
    //获取音频地址
    var res = await CommonApi().getMusicListByPlayListId(mid: rid);
    //停止之前播放的音乐
    await PlayAudio.instance.audioPlayer.stop();
    //清空当前播放对象
    playMusicInfo = null;
    //获取音乐详情
    var muisc = await CommonApi().getMusicDetail(mid: rid);
    //变更当前播放对象
    playMusicInfo = PlayMusicInfo(
        artist: muisc.data["data"]["artist"],
        pic: muisc.data["data"]["pic"],
        rid: muisc.data["data"]["rid"],
        duration: muisc.data["data"]["duration"],
        mvPlayCnt: muisc.data["data"]["mvPlayCnt"],
        hasLossless: muisc.data["data"]["hasLossless"],
        hasmv: muisc.data["data"]["hasmv"],
        releaseDate: muisc.data["data"]["releaseDate"],
        album: muisc.data["data"]["album"],
        albumid: muisc.data["data"]["albumid"],
        artistid: muisc.data["data"]["artistid"],
        songTimeMinutes: muisc.data["data"]["songTimeMinutes"],
        isListenFee: muisc.data["data"]["isListenFee"],
        pic120: muisc.data["data"]["pic120"],
        albuminfo: muisc.data["data"]["albuminfo"],
        name: muisc.data["data"]["name"]);
    //播放新的音乐
    await PlayAudio.instance.audioPlayer.play(res.data["data"]["url"]);
    //添加到播放列表，如果已经添加，则不再添加
    var isExsit = false;
    for (var item in playListMuisc) {
      if (item.rid == muisc.data["data"]["rid"]) {
        isExsit = true;
      }
    }
    if (!isExsit) {
      changePlayListMuisc([
        ...playListMuisc,
        PlayListMuisc(
            rid: muisc.data["data"]["rid"],
            name: muisc.data["data"]["name"],
            path: res.data["data"]["url"])
      ]);
    }
    update();
  }

  //改变正在播放音频的播放状态
  changeAudioPlayState(playState) {
    audioPlayState = playState;
    update();
  }

  //播放正在播放列表里的下一首
  void playNextMusic() {
    if (playListMuisc.isNotEmpty) {
      //当前播放歌曲的索引
      int playingIndex = 0;
      //查找正在播放的索引 如果没有则从第一首开始播放 这里只实现了循环播放  后面需要加入单曲播放 顺序播放 和随机播放的判断
      if (playMusicInfo != null) {
        for (var i = 0; i < playListMuisc.length; i++) {
          var item = playListMuisc[i];
          //找到当前播放的id 如果是最后一首 则下一首是第一首
          if (item.rid == playMusicInfo!.rid) {
            playingIndex = i == playListMuisc.length - 1 ? 0 : i+1;
          }
        }
      }
      playMusic(rid: playListMuisc[playingIndex].rid);
    }
  }
}
