// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'memory_dao.dart';

// ignore_for_file: type=lint
mixin _$MemoryDaoMixin on DatabaseAccessor<AppDatabase> {
  $MemoriesTable get memories => attachedDatabase.memories;
  MemoryDaoManager get managers => MemoryDaoManager(this);
}

class MemoryDaoManager {
  final _$MemoryDaoMixin _db;
  MemoryDaoManager(this._db);
  $$MemoriesTableTableManager get memories =>
      $$MemoriesTableTableManager(_db.attachedDatabase, _db.memories);
}
