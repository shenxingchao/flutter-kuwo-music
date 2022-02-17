class PlayMusicInfo {
  //歌手名称
  late String artist;
  //歌曲封面图
  late String pic;
  // 歌曲id
  late int rid;
  // 歌曲时长(s)
  late int duration;
  // MV播放次数
  late int mvPlayCnt;
  // 无损音质
  late bool hasLossless;
  // 是否有MV(1有0没有)
  late int hasmv;
  // 发布日期
  late String releaseDate;
  // 专辑名称
  late String album;
  // 专辑id
  late int albumid;
  // 歌手id
  late int artistid;
  // 歌曲时长格式化(ii:ss)
  late String songTimeMinutes;
  // 是否付费(true付费false免费)
  late bool isListenFee;
  // 歌曲封面120px缩略图
  late String pic120;
  // 专辑描述
  late String albuminfo;
  // 歌曲名称
  late String name;
  PlayMusicInfo({
    required artist,
    required pic,
    required rid,
    required duration,
    required mvPlayCnt,
    required hasLossless,
    required hasmv,
    required releaseDate,
    required album,
    required albumid,
    required artistid,
    required songTimeMinutes,
    required isListenFee,
    required pic120,
    required albuminfo,
    required name,
  });
}
