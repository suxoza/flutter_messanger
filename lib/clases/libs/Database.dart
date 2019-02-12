import 'dart:async';
import 'dart:io';
import 'package:notifications_only/clases/libs/UserModel.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DBProvider {
  DBProvider._();

  static final DBProvider db = DBProvider._();

  Database _database;

  Future<Database> get database async {
    if (_database != null) return _database;
    // if _database is null we instantiate it
    _database = await initDB();
    return _database;
  }

  Future initDB() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "user_info.db");
    //await deleteDatabase(path);
    return await openDatabase(path, version: 1, onOpen: (db) {},
        onCreate: (Database db, int version) async {
          await db.execute("CREATE TABLE user_info ("
              "user_id int,"
              "user varchar,"
              "firstName varchar,"
              "lastName varchar"
              ")");

          await db.execute("create table messages ("
              "id int primary key,"
              "insert_date varchar,"
              "title varchar,"
              "body text,"
              "perm TINYINT,"
              "favorited TINYINT,"
              "viewed TINYINT"
              ")");
          await db.execute("CREATE INDEX favorite_index on messages (favorited)");
          await db.execute("CREATE INDEX perm_index on messages (perm)");
        });
  }

  Future<int> newUser(User user) async {
    final db = await database;
    int insertID = await db.insert('user_info', user.toMap());
    return insertID;
  }

  Future<int> getUser() async {
    final db = await database;
    return Sqflite.firstIntValue(await db.rawQuery("select user_id from user_info"));
  }

  Future<int> addMessages(Message message) async {
    final db = await database;
    int insertID = await db.insert('messages', message.toMap());
    return insertID;
  }

  Future<List<Message>> getMessages(List<int> perm, num start, num end, bool favorited) async {
    final db = await database;
    start = start == 1?0:start;
    String query = "";
    if(favorited)
      query = "select * from messages where favorited = 1 and perm in ("+perm.join(',')+") limit ${start}, ${end}";
    else
      query = "select * from messages where perm in ("+perm.join(',')+") limit ${start}, ${end}";

    var res = await db.rawQuery(query);
    print(query);
    List<Message> list = res.isNotEmpty?res.map((c) => Message.fromMap(c)).toList():[];
    return list;
  }

  Future<int> MessagesCount([bool favorited = false]) async {
    final db = await database;
    if(favorited)
      return Sqflite.firstIntValue(await db.rawQuery("select count(*) from messages where favorited = 1"));
    return Sqflite.firstIntValue(await db.rawQuery("select count(*) from messages"));
  }

  Future<void> UpdateMessage([String field = 'favorited', int vls = 0, int id = 0]) async {
    final db = await database;
    await db.rawUpdate("update messages set ${field} = ? where id = ?", [vls, id]);
    print("update messages set ${field} = ${vls} where id = ${id}");
  }

  Future<void> DeleteMessage([int id = 0]) async {
    final db = await database;
    await db.delete("messages", where: "id = ?", whereArgs: [id]);
  }

  Future<int> getMessageField([String field = 'favorited', int id = 0]) async {
    final db = await database;
    return Sqflite.firstIntValue(await db.rawQuery("select ${field} from messages where id = ? ", [id]));
  }


}