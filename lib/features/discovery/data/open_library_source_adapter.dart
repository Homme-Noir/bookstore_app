import '../../../services/open_library_service.dart';
import '../domain/models/discovery_result.dart';
import 'internet_archive_download_resolver.dart';
import 'source_adapter.dart';

class OpenLibrarySourceAdapter implements SourceAdapter {
  OpenLibrarySourceAdapter({
    required OpenLibraryService service,
    InternetArchiveDownloadResolver? archiveResolver,
  })  : _service = service,
        _archiveResolver = archiveResolver ?? InternetArchiveDownloadResolver();

  final OpenLibraryService _service;
  final InternetArchiveDownloadResolver _archiveResolver;

  @override
  String get name => 'openlibrary';

  @override
  Future<List<DiscoveryResult>> search(String query) async {
    final trimmed = query.trim();
    final olBooks = trimmed.isEmpty
        ? await _service.defaultOpenLibraryRaw()
        : await _service.searchOpenLibraryRaw(query);
    final resolveArchives = trimmed.isNotEmpty;

    const batchSize = 5;
    final out = <DiscoveryResult>[];
    for (var i = 0; i < olBooks.length; i += batchSize) {
      final slice = olBooks.skip(i).take(batchSize).toList();
      final batch = await Future.wait(
        slice.map((b) => _toDiscoveryResult(b, resolveArchives: resolveArchives)),
      );
      out.addAll(batch);
    }
    return out;
  }

  Future<DiscoveryResult> _toDiscoveryResult(
    OpenLibraryBook book, {
    required bool resolveArchives,
  }) async {
    final downloadUrl = !resolveArchives || book.internetArchiveIds.isEmpty
        ? null
        : await _archiveResolver.firstDirectDownloadUrl(book.internetArchiveIds);

    final key = book.openLibraryId ?? '';
    final catalogUrl = key.startsWith('/works/') || key.startsWith('/books/')
        ? 'https://openlibrary.org$key'
        : null;

    final cover = book.coverImage;
    final coverUrl =
        (cover == null || cover.isEmpty) ? null : cover;

    final formatLabel = downloadUrl == null
        ? 'metadata'
        : (downloadUrl.toLowerCase().contains('.pdf') ? 'pdf' : 'epub');

    return DiscoveryResult(
      id: book.openLibraryId ?? 'ol-${book.title.hashCode}',
      title: book.title,
      author: book.authors.isNotEmpty ? book.authors.first : 'Unknown',
      source: 'OpenLibrary',
      format: formatLabel,
      coverUrl: coverUrl,
      downloadUrl: downloadUrl,
      catalogUrl: catalogUrl,
      confidence: downloadUrl != null ? 0.9 : 0.82,
      formatVerified: downloadUrl != null,
      qualityFlags: downloadUrl != null
          ? const ['internet-archive']
          : const ['metadata-only'],
    );
  }
}
