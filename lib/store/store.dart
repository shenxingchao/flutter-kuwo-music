import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../api/common_api.dart';
import '../interface/play_list_music.dart';
import '../interface/play_music_info.dart';
import '../interface/play_mode.dart';
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

  //播放模式 默认列表循环
  PlayMode playMode = PlayMode.LIST_FOR_MODE;

  //更换主题色
  void changeTheme(Color color) {
    primary = color;
    update();
  }

  //更新播放列表
  void changePlayListMusic(List<PlayListMusic> playListMusicObj) async {
    playListMusic = playListMusicObj;
    if (playListMusic.isEmpty) {
      //清空播放列表 停止所有播放音乐 并设置当前播放对象为空
      //停止之前播放的音乐
      await PlayAudio.instance.audioPlayer.stop();
      //清空当前播放对象
      playMusicInfo = null;
    }
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
      //请求失败了
      if (res.data == null) {
        return;
      }
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
    //播放完毕后 只要不是单曲播放就切换下一首
    if (audioPlayState == PlayerState.COMPLETED &&
        playMode != PlayMode.SINGLE_MODE) {
      playNextMusic();
    }
    update();
  }

  //查找当前播放歌曲在播放列表里的索引
  int getPlayingIndex() {
    //当前播放歌曲的索引
    int playingIndex = 0;
    //查找正在播放的索引 如果没有则从第一首开始播放
    if (playMusicInfo != null) {
      for (var i = 0; i < playListMusic.length; i++) {
        var item = playListMusic[i];
        //找到当前播放的id
        if (item.rid == playMusicInfo!.rid) {
          playingIndex = i;
          break;
        }
      }
    }
    return playingIndex;
  }

  //播放正在播放列表里的下一首 这里的下一首需要根据播放模式
  void playNextMusic() {
    if (playListMusic.isNotEmpty) {
      //当前播放歌曲的索引
      int playingIndex = 0;
      switch (playMode) {
        case PlayMode.SINGLE_MODE:
        case PlayMode.LIST_FOR_MODE:
        case PlayMode.LIST_MODE:
          if (playMusicInfo != null) {
            //查找正在播放的索引 如果没有则从第一首开始播放
            playingIndex = getPlayingIndex();
            if (playingIndex == playListMusic.length - 1) {
              playingIndex = 0;
              if (playMode == PlayMode.LIST_MODE) {
                //如果是顺序播放到最后一首就不播放了
                playingIndex = -1;
              }
            } else {
              playingIndex = playingIndex + 1;
            }
          }
          break;
        case PlayMode.SINGLE_FOR_MODE:
          playMusic(rid: playListMusic[playingIndex].rid);
          break;
        case PlayMode.RANDOM_MODE:
          var rid = playMusicInfo?.rid;
          do {
            playingIndex = Random().nextInt(playListMusic.length);
          } while (rid == playListMusic[playingIndex].rid);
          break;
      }

      if (playingIndex != -1) {
        playMusic(rid: playListMusic[playingIndex].rid);
      }
    }
  }

  //播放正在播放列表里的上一首 这里需要根据播放模式
  void playPrevMusic() {
    if (playListMusic.isNotEmpty) {
      //当前播放歌曲的索引
      int playingIndex = 0;
      switch (playMode) {
        case PlayMode.SINGLE_MODE:
        case PlayMode.LIST_FOR_MODE:
        case PlayMode.LIST_MODE:
          if (playMusicInfo != null) {
            //查找正在播放的索引 如果没有则从第一首开始播放
            playingIndex = getPlayingIndex();
            if (playingIndex == 0) {
              //如果是第一首 则转到最后一首
              playingIndex = playListMusic.length - 1;
            } else {
              playingIndex = playingIndex - 1;
            }
          }
          break;
        case PlayMode.SINGLE_FOR_MODE:
          playMusic(rid: playListMusic[playingIndex].rid);
          break;
        case PlayMode.RANDOM_MODE:
          var rid = playMusicInfo?.rid;
          do {
            playingIndex = Random().nextInt(playListMusic.length);
          } while (rid != playListMusic[playingIndex].rid);
          break;
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

  //切换播放模式
  void changePlayMode() {
    var playModeList = [
      PlayMode.SINGLE_MODE,
      PlayMode.SINGLE_FOR_MODE,
      PlayMode.LIST_MODE,
      PlayMode.LIST_FOR_MODE,
      PlayMode.RANDOM_MODE,
    ];

    var index = 0;
    for (var i = 0; i < playModeList.length; i++) {
      if (playMode == playModeList[i]) {
        index = i + 1;
        if (index == playModeList.length) {
          index = 0;
        }
      }
    }
    playMode = playModeList[index];
  }
}
