// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'db.dart';

// **************************************************************************
// DatabaseGenerator
// **************************************************************************

//Type (Account)
//Account
//$AccountSql
MyDatabase openMyDatabase({String path = ':memory:'}) => _$MyDatabase(path);

class _$MyDatabase extends MyDatabase {
  final DatabaseHelper _helper;
  _$MyDatabase(String path)
      : _helper = DatabaseHelper(path, 1, (db, version) async {
          await db.execute($AccountSql);
        });
  @override
  AccountDao accountDao() {
    return _$AccountDao(_helper);
  }
}

// **************************************************************************
// EntityGenerator
// **************************************************************************

String get $AccountSql => 'create table Account('
    'id integer'
    ',name text'
    ')';
Account getAccountFromMap(Map<String, dynamic> map, {prefix = ''}) {
  var entity = Account();
  entity.id = map['${prefix}id'];
  entity.name = map['${prefix}name'];
  return entity;
}

List<Account> getAccountFromList(List<Map<String, dynamic>> maps,
    {prefix = ''}) {
  List<Account> entities = [];
  maps.forEach((map) {
    entities.add(getAccountFromMap(map, prefix: prefix));
  });
  return entities;
}

Map<String, dynamic> getAccountToMap(Account entity) {
  return {
    'id': entity.id,
    'name': entity.name,
  };
}

// **************************************************************************
// DaoGenerator
// **************************************************************************

class _$AccountDao extends AccountDao {
  final DatabaseHelper _helper;
  _$AccountDao(this._helper);
  @override
  Future<List<Account>> getAll() async {
    var executor = await _helper.getExecutor();
    var result = await executor.query('select * from Account');
    return getAccountFromList(result);
  }

  @override
  Future<Account> getById(int id) async {
    var executor = await _helper.getExecutor();
    var result =
        await executor.query('select * from Account where id=$id limit 1');
    var entities = getAccountFromList(result);
    return entities.isEmpty ? null : entities[0];
  }

  @override
  Future<int> insert(Account account) async {
    var executor = await _helper.getExecutor();
    return await executor.insert(
        'insert into Account(id, name) values(${account.id}, \'${account.name}\')');
  }

  @override
  Future<dynamic> insertAll(List<Account> accounts) {
    return _helper.transaction((action) => super.insertAll(accounts));
  }
}
