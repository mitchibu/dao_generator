import 'package:dao_generator_annotation/annotation.dart';
import 'package:dao_generator_sqlite/sqlite.dart';

part 'db.g.dart';

class DatabaseFactory<T> {
  static dynamic _db;
  static T getDatabase<T>() {
    if(_db == null) {
      _db = openMyDatabase();
    }
    return _db;
  }
}

@Database(entities: [Account], version: 1)
abstract class MyDatabase {
  AccountDao accountDao();
}

@Entity()
class Account {
  int id;
  String name;
}

@Dao()
abstract class AccountDao {
  @Query('select * from Account')
  Future<List<Account>> getAll();

  @Query('select * from Account where id=\$id limit 1')
  Future<Account> getById(int id);

  @Insert('insert into Account(id, name) values(\${account.id}, \\\'\${account.name}\\\')')
  Future<int> insert(Account account);

  @Transaction()
  Future insertAll(List<Account> accounts) {
    accounts.forEach((account) async {
      await insert(account);
    });
    return Future.value(null);
  }
}
