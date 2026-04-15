create table if not exists profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  display_name text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists library_items (
  id text primary key,
  user_id uuid not null references auth.users(id) on delete cascade,
  title text not null,
  author text,
  format text not null,
  source text,
  source_url text,
  checksum text,
  is_deleted boolean not null default false,
  tags text[] not null default '{}',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists book_files (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  library_item_id text not null references library_items(id) on delete cascade,
  storage_path text not null,
  checksum text,
  mime_type text,
  size_bytes bigint,
  created_at timestamptz not null default now()
);

create table if not exists reading_progress (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  library_item_id text not null references library_items(id) on delete cascade,
  percentage numeric not null default 0,
  position integer not null default 0,
  device_id text,
  version bigint not null default 1,
  updated_at timestamptz not null default now(),
  unique (user_id, library_item_id)
);

create table if not exists annotations (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  library_item_id text not null references library_items(id) on delete cascade,
  annotation_id text not null,
  note text,
  start_position integer not null default 0,
  end_position integer not null default 0,
  version bigint not null default 1,
  is_deleted boolean not null default false,
  updated_at timestamptz not null default now(),
  unique (user_id, annotation_id)
);

create table if not exists schema_migrations (
  version text primary key,
  applied_at timestamptz not null default now()
);

create table if not exists sync_events (
  id bigint generated always as identity primary key,
  user_id uuid not null references auth.users(id) on delete cascade,
  entity_type text not null,
  entity_id text not null,
  operation text not null,
  created_at timestamptz not null default now()
);

-- Foreign-key covering indexes (Supabase performance linter).
create index if not exists idx_library_items_user_id on library_items (user_id);
create index if not exists idx_book_files_user_id on book_files (user_id);
create index if not exists idx_book_files_library_item_id on book_files (library_item_id);
create index if not exists idx_reading_progress_library_item_id on reading_progress (library_item_id);
create index if not exists idx_annotations_library_item_id on annotations (library_item_id);
create index if not exists idx_sync_events_user_id on sync_events (user_id);
