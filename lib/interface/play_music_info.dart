class PlayMusicInfo {
  //歌手名称
  String artist;
  //歌曲封面图
  String pic;
  // 歌曲id
  int rid;
  // 歌曲时长(s)
  int duration;
  // MV播放次数
  int mvPlayCnt;
  // 无损音质
  bool hasLossless;
  // 是否有MV(1有0没有)
  int hasmv;
  // 发布日期
  String releaseDate;
  // 专辑名称
  String album;
  // 专辑id
  int albumid;
  // 歌手id
  int artistid;
  // 歌曲时长格式化(ii:ss)
  String songTimeMinutes;
  // 是否付费(true付费false免费)
  bool isListenFee;
  // 歌曲封面120px缩略图
  String pic120;
  // 专辑描述
  String albuminfo;
  // 歌曲名称
  String name;
  PlayMusicInfo({
    required this.artist,
    required this.pic,
    required this.rid,
    required this.duration,
    required this.mvPlayCnt,
    required this.hasLossless,
    required this.hasmv,
    required this.releaseDate,
    required this.album,
    required this.albumid,
    required this.artistid,
    required this.songTimeMinutes,
    required this.isListenFee,
    required this.pic120,
    required this.albuminfo,
    required this.name,
  });

  Map<String, dynamic> toMap() {
    return {
      //歌手名称
      "artist": artist,
      //歌曲封面图
      "pic": pic,
      // 歌曲id
      "rid": rid,
      // 歌曲时长(s)
      "duration": duration,
      // MV播放次数
      "mvPlayCnt": mvPlayCnt,
      // 无损音质
      "hasLossless": hasLossless,
      // 是否有MV(1有0没有)
      "hasmv": hasmv,
      // 发布日期
      "releaseDate": releaseDate,
      // 专辑名称
      "album": album,
      // 专辑id
      "albumid": albumid,
      // 歌手id
      "artistid": artistid,
      // 歌曲时长格式化(ii:ss)
      "songTimeMinutes": songTimeMinutes,
      // 是否付费(true付费false免费)
      "isListenFee": isListenFee,
      // 歌曲封面120px缩略图
      "pic120": pic120,
      // 专辑描述
      "albuminfo": albuminfo,
      // 歌曲名称
      "name": name
    };
  }
}
