import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';
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
  const Color(0xff1295ED),
  const Color(0xffC62F2F),
  const Color(0xffC6318E),
  const Color(0xff8331C6),
  const Color(0xff24AFB9),
  const Color(0xff24B46C),
  const Color(0xff90B41A),
  const Color(0xffC66231),
  const Color(0xff333333),
];
//全局变量end

//类似vuex状态管理类
class Store extends GetxController {
  //首屏缓存
  Map<String, List> homeCache = {
    "homeBannerList": [],
    "homePlayList": [],
  };

  //通知插件
  FlutterLocalNotificationsPlugin? flutterLocalNotificationsPlugin;

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

  //更换首屏缓存
  void changeHomeCache(Map<String, List> homeCacheObj) {
    homeCache = homeCacheObj;
    update();
  }

  //初始化通知插件
  void changeFlutterLocalNotificationsPlugin(
      FlutterLocalNotificationsPlugin
          changeFlutterLocalNotificationsPluginObj) {
    flutterLocalNotificationsPlugin = changeFlutterLocalNotificationsPluginObj;
    update();
  }

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
    //判断是否在播放列表里，找到他是否本地音频
    var isExsit = false;
    for (var item in playListMusic) {
      if (item.rid == rid) {
        isExsit = true;
        isLocal = item.isLocal;
      }
    }

    //网络音乐播放
    if (!isLocal) {
      //获取音频地址
      var res = await CommonApi().getMusicListByPlayListId(mid: rid);
      //停止之前播放的音乐
      await PlayAudio.instance.audioPlayer.stop();
      //清空当前播放对象
      playMusicInfo = null;
      //请求失败了
      if (res == null || res.data == null) {
        return;
      }
      //获取音乐详情
      var music = await CommonApi().getMusicDetail(mid: rid);
      if (music == null || music.data == null) {
        return;
      }
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
      try {
        //播放新的音乐
        await PlayAudio.instance.audioPlayer.play(res.data["data"]["url"]);
      } catch (e) {
        Fluttertoast.showToast(
          msg: "播放接口出错，按太快了",
        );
      }

      //添加到播放列表，如果已经添加，则不再添加
      if (!isExsit) {
        changePlayListMusic([
          ...playListMusic,
          PlayListMusic(
              artist: music.data["data"]["artist"],
              rid: music.data["data"]["rid"],
              name: music.data["data"]["name"],
              isLocal: false,
              pic120: music.data["data"]["pic120"])
        ]);
      }
    } else {
      //本地音频播放
      //添加到播放列表，如果已经添加，则不再添加
      if (!isExsit) {}
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

  //查询歌曲是否已经收藏
  bool getMusicLikeState(int? rid) {
    var isLike = false;
    if (rid == null) {
      return isLike;
    }
    if (box.read('favouriteMusicList') != null) {
      var favouriteMusicList = box.read('favouriteMusicList');
      //每次进入清除null歌曲
      favouriteMusicList.removeWhere((item) {
        return item == null;
      });
      //查找当前歌曲是否在收藏列表
      for (var item in favouriteMusicList) {
        if (item["rid"] == rid) {
          isLike = true;
        }
      }
    }
    return isLike;
  }

  //设置歌曲加入收藏
  Future setLikeState(int? rid) async {
    if (rid == null) {
      return;
    }
    //获取音乐详情
    var music = await CommonApi().getMusicDetail(mid: rid);
    if (music == null || music.data == null) {
      return;
    }

    //变更当前播放对象
    PlayMusicInfo muiscInfo = PlayMusicInfo(
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

    var favouriteMusicList = await box.read('favouriteMusicList') ?? [];

    //记录缓存
    if (!getMusicLikeState(rid)) {
      favouriteMusicList.add(muiscInfo.toMap());
      await box.write('favouriteMusicList', favouriteMusicList);
    }
    //删除缓存
    else {
      favouriteMusicList.removeWhere((item) {
        return item == null || item["rid"] == rid;
      });
      await box.write('favouriteMusicList', favouriteMusicList);
    }
  }

  //删除指定idList的收藏歌曲
  Future deleteFavouriteMusicList({List? idList}) async {
    if (idList == null) {
      //删除全部
      await box.write('favouriteMusicList', []);
    } else {
      var favouriteMusicList = await box.read('favouriteMusicList') ?? [];
      favouriteMusicList.removeWhere((item) {
        return idList.contains(item["rid"]);
      });
      await box.write('favouriteMusicList', favouriteMusicList);
    }
    return true;
  }
}
