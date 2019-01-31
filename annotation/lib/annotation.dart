class Database {
  final List<Type> entities;
  final int version;
  const Database({
    this.entities,
    this.version,
  });
}

class Entity {
  const Entity();
}

class Dao {
  const Dao();
}

class Query {
  final String sql;
  const Query(this.sql);
}

class Insert {
  final String sql;
  const Insert(this.sql);
}

class Update {
  final String sql;
  const Update(this.sql);
}

class Delete {
  final String sql;
  const Delete(this.sql);
}

class Transaction {
  const Transaction();
}
