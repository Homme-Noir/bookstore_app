import '../../library/domain/models/library_item.dart';
import '../../reader/domain/models/reader_annotation.dart';
import '../../reader/domain/models/reading_progress.dart';

/// Deterministic merge rules for library rows, progress, and annotations.
class ConflictResolver {
  const ConflictResolver();

  LibraryItem mergeLibraryItem({
    required LibraryItem local,
    required LibraryItem remote,
  }) {
    if (remote.updatedAt.isAfter(local.updatedAt)) {
      return local.copyWith(
        title: remote.title.isNotEmpty ? remote.title : local.title,
        author: remote.author.isNotEmpty ? remote.author : local.author,
        format: remote.format.isNotEmpty ? remote.format : local.format,
        sourceUrl: remote.sourceUrl ?? local.sourceUrl,
        checksum: remote.checksum ?? local.checksum,
        // Keep local file path because remote never carries device-local paths.
        filePath: local.filePath,
        // Prefer monotonic progress.
        progress: remote.progress > local.progress ? remote.progress : local.progress,
        isFinished: local.isFinished || remote.isFinished,
        updatedAt: remote.updatedAt,
        tags: _mergeTags(local.tags, remote.tags),
      );
    }
    return local;
  }

  ReadingProgress mergeReadingProgress({
    required ReadingProgress local,
    required ReadingProgress remote,
  }) {
    final localPct = local.percentage;
    final remotePct = remote.percentage;

    if (remotePct > localPct + 0.02) {
      return remote;
    }
    if (localPct > remotePct + 0.02) {
      return local;
    }
    return remote.updatedAt.isAfter(local.updatedAt) ? remote : local;
  }

  ReaderAnnotation mergeAnnotation({
    required ReaderAnnotation local,
    required ReaderAnnotation remote,
  }) {
    if (remote.version > local.version) {
      return remote;
    }
    if (remote.version < local.version) {
      return local;
    }
    return remote.updatedAt.isAfter(local.updatedAt) ? remote : local;
  }

  List<String> _mergeTags(List<String> local, List<String> remote) {
    return {...local, ...remote}.toList();
  }
}

