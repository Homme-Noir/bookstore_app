-- Run on existing databases if these indexes were not applied yet (idempotent).
create index if not exists idx_library_items_user_id on library_items (user_id);
create index if not exists idx_book_files_user_id on book_files (user_id);
create index if not exists idx_book_files_library_item_id on book_files (library_item_id);
create index if not exists idx_reading_progress_library_item_id on reading_progress (library_item_id);
create index if not exists idx_annotations_library_item_id on annotations (library_item_id);
create index if not exists idx_sync_events_user_id on sync_events (user_id);
