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
  List<PlayListMusic> playListMusic = [];

  //正在播放音频的播放状态
  PlayerState audioPlayState = PlayerState.STOPPED;

  //更换主题色
  void changeTheme(Color color) {
    primary = color;
    update();
  }

  //更新播放列表
  void changePlayListMusic(List<PlayListMusic> playListMusicObj) {
    playListMusic = playListMusicObj;
    update();
  }

  //播放audio方法统一方法
  void playMusic({required int rid, bool isLocal = false}) async {
    //网络音乐播放
    if (!isLocal) {
      //获取音频地址
      var res = await CommonApi().getMusicListByPlayListId(mid: rid);
      //停止之前播放的音乐
      await PlayAudio.instance.audioPlayer.stop();
      //清空当前播放对象
      playMusicInfo = null;
      //获取音乐详情
      var music = await CommonApi().getMusicDetail(mid: rid);
      //变更当前播放对象
      playMusicInfo = PlayMusicInfo(
          artist: music.data["data"]["artist"],
          pic: music.data["data"]["pic"],
          rid: music.data["data"]["rid"],
          duration: music.data["data"]["duration"],
          mvPlayCnt: music.data["data"]["mvPlayCnt"],
          hasLossless: music.data["data"]["hasLossless"],
          hasmv: music.data["data"]["hasmv"],
          releaseDate: music.data["data"]["releaseDate"],
          album: music.data["data"]["album"],
          albumid: music.data["data"]["albumid"],
          artistid: music.data["data"]["artistid"],
          songTimeMinutes: music.data["data"]["songTimeMinutes"],
          isListenFee: music.data["data"]["isListenFee"],
          pic120: music.data["data"]["pic120"],
          albuminfo: music.data["data"]["albuminfo"],
          name: music.data["data"]["name"]);
      //播放新的音乐
      await PlayAudio.instance.audioPlayer.play(res.data["data"]["url"]);
      //添加到播放列表，如果已经添加，则不再添加
      var isExsit = false;
      for (var item in playListMusic) {
        if (item.rid == music.data["data"]["rid"]) {
          isExsit = true;
        }
      }
      if (!isExsit) {
        changePlayListMusic([
          ...playListMusic,
          PlayListMusic(
              artist: music.data["data"]["artist"],
              rid: music.data["data"]["rid"],
              name: music.data["data"]["name"],
              isLocal: isLocal,
              pic120: music.data["data"]["pic120"])
        ]);
      }
    } else {
      //本地音乐播放 通过rid去查询本地mp3文件和lrc文件
    }

    update();
  }

  //改变正在播放音频的播放状态
  changeAudioPlayState(playState) {
    audioPlayState = playState;
    //播放完毕后 在这里根据播放模式来判断是否需要切换下一首
    if(audioPlayState == PlayerState.COMPLETED){
      playNextMusic();
    }
    update();
  }

  //播放正在播放列表里的下一首 这里的下一首需要根据播放模式
  void playNextMusic() {
    if (playListMusic.isNotEmpty) {
      //当前播放歌曲的索引
      int playingIndex = 0;
      //查找正在播放的索引 如果没有则从第一首开始播放 这里只实现了循环播放  后面需要加入单曲播放 顺序播放 和随机播放的判断
      if (playMusicInfo != null) {
        for (var i = 0; i < playListMusic.length; i++) {
          var item = playListMusic[i];
          //找到当前播放的id 如果是最后一首 则下一首是第一首
          if (item.rid == playMusicInfo!.rid) {
            playingIndex = i == playListMusic.length - 1 ? 0 : i + 1;
          }
        }
      }
      playMusic(rid: playListMusic[playingIndex].rid);
    }
  }

  //播放一个列表的歌曲
  void playAudioList(audioList) {
    //清除前面重复的歌曲
    for (var i = playListMusic.length - 1; i >= 0; i--) {
      var item = playListMusic[i];
      audioList.forEach((element) {
        if (item.rid == element.rid) {
          playListMusic.remove(item);
          return;
        }
      });
    }

    //整个列表添加到正在播放列表中
    changePlayListMusic([...playListMusic, ...audioList]);
    //播放列表的第一首
    playMusic(rid: audioList[0].rid);
  }
}
