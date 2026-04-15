alter table profiles enable row level security;
alter table library_items enable row level security;
alter table book_files enable row level security;
alter table reading_progress enable row level security;
alter table annotations enable row level security;
alter table sync_events enable row level security;
-- Internal migration ledger: explicit deny for API roles (service_role bypasses RLS).
alter table schema_migrations enable row level security;

drop policy if exists "schema_migrations_deny_all" on schema_migrations;
create policy "schema_migrations_deny_all" on schema_migrations
  for all using (false) with check (false);

-- Idempotent: safe to re-run after policies already exist.
-- auth.uid() wrapped in (select ...) so it is not re-evaluated per row (Supabase RLS perf).
drop policy if exists "profiles_own_rows" on profiles;
create policy "profiles_own_rows" on profiles
  for all using (id = (select auth.uid())) with check (id = (select auth.uid()));

drop policy if exists "library_items_own_rows" on library_items;
create policy "library_items_own_rows" on library_items
  for all using (user_id = (select auth.uid())) with check (user_id = (select auth.uid()));

drop policy if exists "book_files_own_rows" on book_files;
create policy "book_files_own_rows" on book_files
  for all using (user_id = (select auth.uid())) with check (user_id = (select auth.uid()));

drop policy if exists "reading_progress_own_rows" on reading_progress;
create policy "reading_progress_own_rows" on reading_progress
  for all using (user_id = (select auth.uid())) with check (user_id = (select auth.uid()));

drop policy if exists "annotations_own_rows" on annotations;
create policy "annotations_own_rows" on annotations
  for all using (user_id = (select auth.uid())) with check (user_id = (select auth.uid()));

drop policy if exists "sync_events_own_rows" on sync_events;
create policy "sync_events_own_rows" on sync_events
  for all using (user_id = (select auth.uid())) with check (user_id = (select auth.uid()));
