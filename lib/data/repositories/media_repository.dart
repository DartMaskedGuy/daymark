import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../database/app_database.dart';

/// Persists references to local photo/video files. Actual bytes stay on
/// disk (see MediaService); only paths and metadata live in Drift.
class MediaRepository {
  MediaRepository(this._db);

  final AppDatabase _db;
  static const _uuid = Uuid();

  Stream<List<MediaItem>> watchForItem(String itemId) =>
      _db.mediaDao.watchForItem(itemId);

  Future<void> addMedia({
    required String itemId,
    required String type,
    required String path,
    String? thumbnailPath,
  }) {
    return _db.mediaDao.add(
      MediaCompanion.insert(
        id: _uuid.v4(),
        itemId: itemId,
        type: type,
        path: path,
        thumbnailPath: Value(thumbnailPath),
        createdAt: DateTime.now(),
      ),
    );
  }

  Future<void> removeMedia(String id) => _db.mediaDao.remove(id);
}
