import 'package:sqflite/sqflite.dart';
//join方法需要
// import 'package:path/path.dart';

class Db {
  //工厂模式
  factory Db() => _getInstance();
  static Db get instance => _getInstance();
  static Db? _instance;

  //数据库对象
  late Future<Database> db;

  Db._internal() {
    //全局只有一个实例
    db = init();
  }

  static Db _getInstance() {
    _instance ??= Db._internal();
    return _instance as Db;
  }

  Future<Database> init() async {
    //删除数据库
    // var databasesPath = await getDatabasesPath();
    // String path = join(databasesPath, 'dbname.db');
    // await deleteDatabase(path);
    return await openDatabase('dbname.db', version: 1, onCreate: _onCreate);
  }

  Future _onCreate(Database db, int version) async {
    //歌单名称表
    await db.execute('''CREATE TABLE custom_play_list (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT comment '歌单名称'
        )''');
    //自定义歌单列表表格
    await db.execute('''CREATE TABLE custom_play_list_content (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        custom_play_list_id INTEGER comment '歌单id',
        artist TEXT comment '歌手名称',
        pic TEXT comment '歌曲封面图',
        rid INTEGER comment '歌曲id',
        duration INTEGER comment '歌曲时长(s)',
        mvPlayCnt INTEGER comment 'MV播放次数',
        hasLossless INTEGER comment '无损音质 1 true 0 false',
        hasmv INTEGER comment '是否有MV(1有0没有)',
        releaseDate TEXT comment '发布日期',
        album TEXT comment '专辑名称',
        albumid INTEGER comment '专辑id',
        artistid INTEGER comment '歌手id',
        songTimeMinutes TEXT comment '歌曲时长格式化(ii:ss)',
        isListenFee INTEGER comment '是否付费(1 true付费 0false免费)',
        pic120 TEXT comment '歌曲封面120px缩略图',
        albuminfo TEXT comment '专辑描述',
        name TEXT comment '歌曲名称',
        FOREIGN KEY (custom_play_list_id) REFERENCES custom_play_list(id)
        )''');
  }
}


//使用 await (await Db.instance.db).close()
