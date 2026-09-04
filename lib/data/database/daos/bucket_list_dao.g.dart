// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bucket_list_dao.dart';

// ignore_for_file: type=lint
mixin _$BucketListDaoMixin on DatabaseAccessor<AppDatabase> {
  $BucketListItemsTable get bucketListItems => attachedDatabase.bucketListItems;
  $LinksTable get links => attachedDatabase.links;
  BucketListDaoManager get managers => BucketListDaoManager(this);
}

class BucketListDaoManager {
  final _$BucketListDaoMixin _db;
  BucketListDaoManager(this._db);
  $$BucketListItemsTableTableManager get bucketListItems =>
      $$BucketListItemsTableTableManager(
        _db.attachedDatabase,
        _db.bucketListItems,
      );
  $$LinksTableTableManager get links =>
      $$LinksTableTableManager(_db.attachedDatabase, _db.links);
}
