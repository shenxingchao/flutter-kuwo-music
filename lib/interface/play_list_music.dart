class PlayListMusic {
  //歌曲id
  int rid;
  //歌曲名称
  String name;
  //是否是本地歌曲 本地歌曲播放的时候播放地址和播放信息从本地读取
  bool isLocal;

  PlayListMusic({required this.rid, required this.name, required this.isLocal});
}
