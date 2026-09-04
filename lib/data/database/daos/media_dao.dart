import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/media_table.dart';

part 'media_dao.g.dart';

@DriftAccessor(tables: [Media])
class MediaDao extends DatabaseAccessor<AppDatabase> with _$MediaDaoMixin {
  MediaDao(super.db);

  Stream<List<MediaItem>> watchForItem(String itemId) =>
      (select(media)..where((t) => t.itemId.equals(itemId))).watch();

  Future<void> add(MediaCompanion entry) => into(media).insert(entry);

  Future<void> remove(String id) =>
      (delete(media)..where((t) => t.id.equals(id))).go();
}
