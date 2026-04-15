/// Marks a [ReaderAnnotation] as a position bookmark (no user-typed note).
const String kBookmarkMarker = '__PL_BOOKMARK__';

bool isBookmarkNote(String note) => note.trim() == kBookmarkMarker;
