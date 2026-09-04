import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'app/app.dart';
import 'data/database/app_database.dart';
import 'data/repositories/bucket_list_repository.dart';
import 'data/repositories/media_repository.dart';
import 'data/repositories/memory_repository.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final database = AppDatabase();

  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AppDatabase>.value(value: database),
        RepositoryProvider<BucketListRepository>(
          create: (_) => BucketListRepository(database),
        ),
        RepositoryProvider<MediaRepository>(
          create: (_) => MediaRepository(database),
        ),
        RepositoryProvider<MemoryRepository>(
          create: (_) => MemoryRepository(database),
        ),
      ],
      child: const DaymarkApp(),
    ),
  );
}
