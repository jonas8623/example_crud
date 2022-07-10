import 'package:exemplo_banco/models/user_model.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

abstract class UserRepository {

  Future<int> save(UserModel userModel);
  Future<int> delete(int id);
  Future<List<UserModel>> fetchAll();
  Future<int> update(UserModel userModel);

}

class UserRepositoryImp extends UserRepository {

  Future<Database> _initDB() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, "user.db");

    return openDatabase(
        path,
        version: 1,
        onCreate: (Database database, int newVersion) async {
          await database.execute("CREATE TABLE user(id INTEGER PRIMARY KEY, name TEXT, email TEXT, age INTEGER)");
    });
  }

  @override
  Future<int> delete(int id) async {
    try {
      final Database database = await _initDB();
      return await database.delete("user", where: "id = ?", whereArgs: [id]);
    } catch(error) {
      throw Exception('Falha ao deletar o usuário: $error');
    }
  }

  @override
  Future<List<UserModel>> fetchAll() async {
    try {
      final Database database = await _initDB();
      final List<Map<String, dynamic>> listUsers = await database.query("user", orderBy: "name ASC");
      return List.generate(listUsers.length, (index) {
        return UserModel.fromJson(listUsers[index]);
      });
    } catch(error) {
      throw Exception('Falha ao executar a lista: $error');
    }
  }

  @override
  Future<int> save(UserModel userModel) async {
    try {
      final Database database = await _initDB();
      return await database.insert("user", userModel.toMap());
    } catch(error) {
        throw Exception('Falha ao salvar o usuário: $error');
    }
  }

  @override
  Future<int> update(UserModel userModel) async {
    try {
      final Database database = await _initDB();
      return await database.update(
          "user",
          userModel.toMap(),
          where: "id = ?",
          whereArgs: [userModel.id]
      );
    } catch(error) {
        throw Exception('Falha ao atualizar o usuário: $error');
    }
  }
}
