import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'tables/bucket_list_items_table.dart';
import 'tables/links_table.dart';
import 'tables/media_table.dart';
import 'tables/memories_table.dart';
import 'daos/bucket_list_dao.dart';
import 'daos/media_dao.dart';
import 'daos/memory_dao.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [BucketListItems, Links, Media, Memories],
  daos: [BucketListDao, MediaDao, MemoryDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 1;

  static QueryExecutor _openConnection() {
    return driftDatabase(name: 'daymark');
  }
}
