-- ============================================================================
-- StoryPlay — Supabase / Postgres schema
-- App: StoryPlay | Package: com.storyplay.app | Version: 1.0.0
-- Owner: owner@storyplay.app
-- ----------------------------------------------------------------------------
-- KAISE CHALAYEIN:
--   1. Supabase Dashboard > SQL Editor me pehle ye file (schema.sql) run karo.
--   2. Uske baad seed.sql run karo.
--   3. Storage me 2 buckets banao (neeche notes dekho).
-- Ye file koi fake/demo data NAHI banati. Sirf khaali tables + RLS policies.
-- ============================================================================

-- UUID banane ke liye extension (Supabase me aam taur par pehle se on hota hai)
create extension if not exists "pgcrypto";

-- ----------------------------------------------------------------------------
-- 1. stories — ek row = ek branching story
-- ----------------------------------------------------------------------------
create table if not exists public.stories (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  description text,
  cover_image text,
  category text not null default 'Thriller',
  is_mature boolean not null default false,
  is_live boolean not null default false,
  is_featured boolean not null default false,
  start_node_id uuid,
  created_at timestamptz not null default now()
);

-- ----------------------------------------------------------------------------
-- 2. video_nodes — ek row = story ka ek scene / node (clip)
--    video_url NULL matlab: "Video Clip: Upload Pending" — kabhi fake CDN URL
--    yahan mat bharo. Real video upload hone par hi URL aayega.
-- ----------------------------------------------------------------------------
create table if not exists public.video_nodes (
  id uuid primary key default gen_random_uuid(),
  story_id uuid not null references public.stories(id) on delete cascade,
  node_name text not null,
  video_url text, -- nullable, NULL = Upload Pending
  trigger_timestamp_seconds integer not null default 5,
  is_ending boolean not null default false,
  ending_name text, -- sirf ending nodes par: Badla Poora / Laalach Ka Anjaam / Mukti — Golden Ending
  sort_order integer not null default 0,
  created_at timestamptz not null default now()
);

-- start_node_id ko video_nodes se jodne ke liye foreign key
-- (video_nodes table banne ke baad hi lag sakti hai, isliye alag se)
do $$
begin
  if not exists (
    select 1 from pg_constraint where conname = 'stories_start_node_id_fkey'
  ) then
    alter table public.stories
      add constraint stories_start_node_id_fkey
      foreign key (start_node_id) references public.video_nodes(id) on delete set null;
  end if;
end $$;

-- ----------------------------------------------------------------------------
-- 3. choices — ek row = ek decision button
--    source_node_id = jis node par choice dikhti hai
--    target_node_id = choice dabane par kis node par jana hai
-- ----------------------------------------------------------------------------
create table if not exists public.choices (
  id uuid primary key default gen_random_uuid(),
  source_node_id uuid not null references public.video_nodes(id) on delete cascade,
  choice_label text not null,
  target_node_id uuid not null references public.video_nodes(id) on delete cascade,
  created_at timestamptz not null default now()
);

-- ----------------------------------------------------------------------------
-- 4. profiles — users table
--    id = Supabase Auth user id (auth.users.id). Koi demo/fake user yahan
--    seed me NAHI dala jata — row tabhi banti hai jab koi real user sign up kare.
-- ----------------------------------------------------------------------------
create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  display_name text,
  coin_balance integer not null default 0,
  is_premium boolean not null default false,
  status text not null default 'active',
  created_at timestamptz not null default now()
);

-- ----------------------------------------------------------------------------
-- 5. app_settings — key/value settings (coins, free episodes, VIP plans)
--    value JSONB hai, taaki plan/price jaise structured data bhi save ho sake.
-- ----------------------------------------------------------------------------
create table if not exists public.app_settings (
  key text primary key,
  value jsonb not null,
  updated_at timestamptz not null default now()
);

-- ----------------------------------------------------------------------------
-- Indexes — Home list, story tree aur choices ko fast rakhne ke liye
-- ----------------------------------------------------------------------------
create index if not exists idx_video_nodes_story_id on public.video_nodes(story_id);
create index if not exists idx_video_nodes_story_sort on public.video_nodes(story_id, sort_order);
create index if not exists idx_choices_source_node_id on public.choices(source_node_id);
create index if not exists idx_choices_target_node_id on public.choices(target_node_id);
create index if not exists idx_stories_is_live on public.stories(is_live);

-- ----------------------------------------------------------------------------
-- Row Level Security (RLS) — sab tables par ON
-- ----------------------------------------------------------------------------
alter table public.stories enable row level security;
alter table public.video_nodes enable row level security;
alter table public.choices enable row level security;
alter table public.profiles enable row level security;
alter table public.app_settings enable row level security;

-- --- stories ---
-- Anon (bina login) aur logged-in users: sirf LIVE stories padh sakte hain.
create policy "stories_select_live"
  on public.stories for select
  to anon, authenticated
  using (is_live = true);

-- Owner ko apni stories padhne ka haq (LIVE OFF wali bhi, Backend ke liye)
create policy "stories_select_owner"
  on public.stories for select
  to authenticated
  using ((auth.jwt() ->> 'email') = 'owner@storyplay.app');

-- Write (INSERT/UPDATE/DELETE) sirf Owner: owner@storyplay.app
create policy "stories_write_owner"
  on public.stories for all
  to authenticated
  using ((auth.jwt() ->> 'email') = 'owner@storyplay.app')
  with check ((auth.jwt() ->> 'email') = 'owner@storyplay.app');

-- --- video_nodes ---
-- Sirf LIVE story ke nodes padhe ja sakte hain.
create policy "video_nodes_select_live"
  on public.video_nodes for select
  to anon, authenticated
  using (
    exists (
      select 1 from public.stories s
      where s.id = video_nodes.story_id and s.is_live = true
    )
  );

create policy "video_nodes_select_owner"
  on public.video_nodes for select
  to authenticated
  using ((auth.jwt() ->> 'email') = 'owner@storyplay.app');

create policy "video_nodes_write_owner"
  on public.video_nodes for all
  to authenticated
  using ((auth.jwt() ->> 'email') = 'owner@storyplay.app')
  with check ((auth.jwt() ->> 'email') = 'owner@storyplay.app');

-- --- choices ---
-- Sirf LIVE story ke choices padhe ja sakte hain.
create policy "choices_select_live"
  on public.choices for select
  to anon, authenticated
  using (
    exists (
      select 1
      from public.video_nodes vn
      join public.stories s on s.id = vn.story_id
      where vn.id = choices.source_node_id and s.is_live = true
    )
  );

create policy "choices_select_owner"
  on public.choices for select
  to authenticated
  using ((auth.jwt() ->> 'email') = 'owner@storyplay.app');

create policy "choices_write_owner"
  on public.choices for all
  to authenticated
  using ((auth.jwt() ->> 'email') = 'owner@storyplay.app')
  with check ((auth.jwt() ->> 'email') = 'owner@storyplay.app');

-- --- profiles ---
-- Har user sirf apni row padh / update kar sakta hai. Dusre ki row nahi.
create policy "profiles_select_own"
  on public.profiles for select
  to authenticated
  using (auth.uid() = id);

create policy "profiles_insert_own"
  on public.profiles for insert
  to authenticated
  with check (auth.uid() = id);

create policy "profiles_update_own"
  on public.profiles for update
  to authenticated
  using (auth.uid() = id)
  with check (auth.uid() = id);

-- Owner ko users dekhne / manage karne ka haq (Backend ke liye)
create policy "profiles_select_owner"
  on public.profiles for select
  to authenticated
  using ((auth.jwt() ->> 'email') = 'owner@storyplay.app');

create policy "profiles_update_owner"
  on public.profiles for update
  to authenticated
  using ((auth.jwt() ->> 'email') = 'owner@storyplay.app')
  with check ((auth.jwt() ->> 'email') = 'owner@storyplay.app');

-- --- app_settings ---
-- Settings sab padh sakte hain (free episodes, coin cost, VIP plans).
create policy "app_settings_select_all"
  on public.app_settings for select
  to anon, authenticated
  using (true);

-- Badalna sirf Owner kar sakta hai.
create policy "app_settings_write_owner"
  on public.app_settings for all
  to authenticated
  using ((auth.jwt() ->> 'email') = 'owner@storyplay.app')
  with check ((auth.jwt() ->> 'email') = 'owner@storyplay.app');

-- ----------------------------------------------------------------------------
-- Storage buckets — NOTES (SQL comments)
-- ----------------------------------------------------------------------------
-- Supabase Dashboard > Storage me ye 2 buckets banao, dono Public:
--   1. story-posters — story ke poster/cover images ke liye (public read)
--   2. story-videos  — story ke video clips (nodes) ke liye (public read)
--
-- Upload sirf Owner (owner@storyplay.app) karega — Backend Admin se.
-- Storage policies Dashboard me bucket banate waqt / Storage > Policies se
-- lagao: SELECT public (sab padh sakte hain), INSERT/UPDATE/DELETE sirf
-- authenticated Owner. Yahan SQL me storage.buckets insert NAHI kiya gaya,
-- kyunki bucket creation Dashboard se karna zyada safe aur clear hai.
--
-- Agar SQL se hi banana ho to (sirf reference, pehle Dashboard check karo):
--   insert into storage.buckets (id, name, public)
--   values ('story-posters', 'story-posters', true),
--          ('story-videos', 'story-videos', true)
--   on conflict (id) do nothing;
-- ----------------------------------------------------------------------------
