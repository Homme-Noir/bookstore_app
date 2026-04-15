import 'package:personal_library/features/library/domain/models/library_item.dart';
import 'package:personal_library/features/reader/domain/models/reader_annotation.dart';
import 'package:personal_library/features/reader/domain/models/reading_progress.dart';
import 'package:personal_library/features/sync/domain/conflict_resolver.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const resolver = ConflictResolver();

  test('library merge keeps local path and highest progress', () {
    final local = LibraryItem(
      id: 'id1',
      title: 'Local',
      author: 'Author',
      filePath: '/local/path.epub',
      format: 'epub',
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 2),
      progress: 0.7,
      tags: const ['local'],
    );
    final remote = local.copyWith(
      title: 'Remote',
      progress: 0.5,
      tags: const ['remote'],
      updatedAt: DateTime(2026, 1, 3),
    );

    final merged = resolver.mergeLibraryItem(local: local, remote: remote);

    expect(merged.filePath, '/local/path.epub');
    expect(merged.progress, 0.7);
    expect(merged.tags.toSet(), {'local', 'remote'});
    expect(merged.title, 'Remote');
  });

  test('reading progress merge is monotonic unless close then recency', () {
    final local = ReadingProgress(
      itemId: 'id1',
      percentage: 0.8,
      position: 800,
      updatedAt: DateTime(2026, 1, 5),
    );
    final remoteLower = ReadingProgress(
      itemId: 'id1',
      percentage: 0.3,
      position: 300,
      updatedAt: DateTime(2026, 1, 6),
    );
    final remoteCloseNewer = ReadingProgress(
      itemId: 'id1',
      percentage: 0.79,
      position: 790,
      updatedAt: DateTime(2026, 1, 7),
    );

    expect(
      resolver.mergeReadingProgress(local: local, remote: remoteLower).percentage,
      0.8,
    );
    expect(
      resolver
          .mergeReadingProgress(local: local, remote: remoteCloseNewer)
          .updatedAt,
      DateTime(2026, 1, 7),
    );
  });

  test('annotation merge prefers version then recency', () {
    final local = ReaderAnnotation(
      id: 'a1',
      itemId: 'id1',
      annotationId: 'a1',
      note: 'note1',
      start: 1,
      end: 2,
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 2),
      version: 2,
    );
    final remoteHigher = local.copyWith(
      note: 'note2',
      version: 3,
      updatedAt: DateTime(2026, 1, 1),
    );
    final remoteSameVersionNewer = local.copyWith(
      note: 'note3',
      version: 2,
      updatedAt: DateTime(2026, 1, 3),
    );

    expect(
      resolver.mergeAnnotation(local: local, remote: remoteHigher).note,
      'note2',
    );
    expect(
      resolver.mergeAnnotation(local: local, remote: remoteSameVersionNewer).note,
      'note3',
    );
  });
}

