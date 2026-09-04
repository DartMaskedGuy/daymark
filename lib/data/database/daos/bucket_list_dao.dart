import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/bucket_list_items_table.dart';
import '../tables/links_table.dart';

part 'bucket_list_dao.g.dart';

@DriftAccessor(tables: [BucketListItems, Links])
class BucketListDao extends DatabaseAccessor<AppDatabase>
    with _$BucketListDaoMixin {
  BucketListDao(super.db);

  Stream<List<BucketListItem>> watchAll() => select(bucketListItems).watch();

  Future<BucketListItem?> getById(String id) => (select(
    bucketListItems,
  )..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<void> upsertItem(BucketListItemsCompanion item) =>
      into(bucketListItems).insertOnConflictUpdate(item);

  Future<void> deleteItem(String id) =>
      (delete(bucketListItems)..where((t) => t.id.equals(id))).go();

  Future<void> setCompleted(String id, bool completed) {
    final now = DateTime.now();
    return (update(bucketListItems)..where((t) => t.id.equals(id))).write(
      BucketListItemsCompanion(
        isCompleted: Value(completed),
        completedAt: Value(completed ? now : null),
        updatedAt: Value(now),
      ),
    );
  }

  Stream<List<Link>> watchLinksForItem(String itemId) =>
      (select(links)..where((t) => t.itemId.equals(itemId))).watch();

  Future<void> replaceLinks(String itemId, List<LinksCompanion> newLinks) {
    return transaction(() async {
      await (delete(links)..where((t) => t.itemId.equals(itemId))).go();
      for (final link in newLinks) {
        await into(links).insert(link);
      }
    });
  }

  Future<Map<String, int>> stats() async {
    final all = await select(bucketListItems).get();
    final completed = all.where((i) => i.isCompleted).length;
    final countries = all
        .map((i) => i.country)
        .whereType<String>()
        .where((c) => c.isNotEmpty)
        .toSet()
        .length;
    final states = all
        .map((i) => i.state)
        .whereType<String>()
        .where((s) => s.isNotEmpty)
        .toSet()
        .length;
    return {
      'total': all.length,
      'completed': completed,
      'remaining': all.length - completed,
      'countries': countries,
      'states': states,
    };
  }
}
