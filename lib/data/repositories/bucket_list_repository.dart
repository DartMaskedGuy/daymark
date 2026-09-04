import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../database/app_database.dart';

/// Keeps all bucket-list persistence behind one API so Cubits never talk to
/// Drift directly.
class BucketListRepository {
  BucketListRepository(this._db);

  final AppDatabase _db;
  static const _uuid = Uuid();

  Stream<List<BucketListItem>> watchAll() => _db.bucketListDao.watchAll();

  Future<BucketListItem?> getById(String id) => _db.bucketListDao.getById(id);

  Future<String> createItem({
    required String title,
    String? description,
    required String category,
    String? country,
    String? state,
    String? city,
    String? place,
    required String priority,
    required String color,
    DateTime? targetDate,
  }) async {
    final id = _uuid.v4();
    final now = DateTime.now();
    await _db.bucketListDao.upsertItem(
      BucketListItemsCompanion.insert(
        id: id,
        title: title,
        description: Value(description),
        category: Value(category),
        country: Value(country),
        state: Value(state),
        city: Value(city),
        place: Value(place),
        priority: Value(priority),
        color: Value(color),
        targetDate: Value(targetDate),
        createdAt: now,
        updatedAt: now,
      ),
    );
    return id;
  }

  Future<void> updateItem(BucketListItem item) => _db.bucketListDao.upsertItem(
        item.toCompanion(true).copyWith(updatedAt: Value(DateTime.now())),
      );

  Future<void> deleteItem(String id) => _db.bucketListDao.deleteItem(id);

  Future<void> setCompleted(String id, bool completed) =>
      _db.bucketListDao.setCompleted(id, completed);

  Stream<List<Link>> watchLinks(String itemId) =>
      _db.bucketListDao.watchLinksForItem(itemId);

  Future<void> replaceLinks(String itemId, List<({String title, String url})> newLinks) {
    final now = DateTime.now();
    return _db.bucketListDao.replaceLinks(
      itemId,
      newLinks
          .map((l) => LinksCompanion.insert(
                id: _uuid.v4(),
                itemId: itemId,
                title: l.title,
                url: l.url,
                createdAt: now,
              ))
          .toList(),
    );
  }

  Future<Map<String, int>> stats() => _db.bucketListDao.stats();
}
