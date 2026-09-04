import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/memories_table.dart';

part 'memory_dao.g.dart';

@DriftAccessor(tables: [Memories])
class MemoryDao extends DatabaseAccessor<AppDatabase> with _$MemoryDaoMixin {
  MemoryDao(super.db);

  Future<Memory?> getForItem(String itemId) => (select(
    memories,
  )..where((t) => t.itemId.equals(itemId))).getSingleOrNull();

  Stream<List<Memory>> watchAll() => select(memories).watch();

  Future<void> upsert(MemoriesCompanion memory) =>
      into(memories).insertOnConflictUpdate(memory);
}
