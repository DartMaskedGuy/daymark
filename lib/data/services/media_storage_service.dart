import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

/// Copies picked media files into the app's own documents directory so
/// they're actually persisted on local storage, rather than left at
/// whatever path the picker returned.
///
/// image_picker's returned path is frequently a transient cache/tmp file
/// (this is especially true on iOS) — it can be cleared by the OS between
/// launches, which would silently orphan the reference stored in Drift.
/// Copying into `ApplicationDocumentsDirectory/media/` gives each photo a
/// stable, app-owned path that persists for the life of the install.
class MediaStorageService {
  static const _uuid = Uuid();

  Future<String> persistFile(String sourcePath) async {
    final sourceFile = File(sourcePath);
    final docsDir = await getApplicationDocumentsDirectory();
    final mediaDir = Directory(p.join(docsDir.path, 'media'));
    if (!await mediaDir.exists()) {
      await mediaDir.create(recursive: true);
    }

    final fileName = '${_uuid.v4()}${p.extension(sourcePath)}';
    final destination = p.join(mediaDir.path, fileName);
    await sourceFile.copy(destination);
    return destination;
  }

  Future<void> deleteFile(String path) async {
    final file = File(path);
    if (await file.exists()) {
      await file.delete();
    }
  }
}
