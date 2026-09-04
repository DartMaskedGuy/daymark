import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../database/app_database.dart';

/// Persists the journal entry attached to a completed bucket-list item.
class MemoryRepository {
  MemoryRepository(this._db);

  final AppDatabase _db;
  static const _uuid = Uuid();

  Future<Memory?> getForItem(String itemId) => _db.memoryDao.getForItem(itemId);

  Future<void> saveMemory({
    required String itemId,
    String? notes,
    DateTime? memoryDate,
  }) async {
    final existing = await _db.memoryDao.getForItem(itemId);
    final now = DateTime.now();
    await _db.memoryDao.upsert(
      MemoriesCompanion.insert(
        id: existing?.id ?? _uuid.v4(),
        itemId: itemId,
        notes: Value(notes),
        memoryDate: Value(memoryDate),
        createdAt: existing?.createdAt ?? now,
        updatedAt: now,
      ),
    );
  }
}
