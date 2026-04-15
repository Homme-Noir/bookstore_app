import '../../../core/storage/local_database.dart';
import '../domain/models/reader_annotation.dart';
import '../domain/models/reading_progress.dart';

class LocalReaderRepository {
  LocalReaderRepository({required LocalDatabase database}) : _database = database;

  final LocalDatabase _database;

  Future<Map<String, ReadingProgress>> loadProgress() => _database.listProgress();

  Future<void> saveProgress(ReadingProgress progress) =>
      _database.upsertProgress(progress);

  Future<Map<String, List<ReaderAnnotation>>> loadAnnotations() =>
      _database.listAnnotations();

  Future<void> addAnnotation(ReaderAnnotation annotation) =>
      _database.insertAnnotation(annotation);
}

