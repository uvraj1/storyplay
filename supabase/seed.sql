-- ============================================================================
-- StoryPlay — Seed data (seed.sql)
-- ----------------------------------------------------------------------------
-- schema.sql ke BAAD run karo (SQL Editor me, pehle schema, phir seed).
-- Sirf EK real story daali jaati hai: 'Haveli Ka Raaz — Dhundpura Nights'.
--   * 12 video_nodes  (9 decision + 3 ending)
--   * 19 choices     (saare valid node ids se linked)
--   * 3 endings: Badla Poora / Laalach Ka Anjaam / Mukti — Golden Ending
--   * Sab video_url = NULL  (Video Clip: Upload Pending — kabhi fake CDN
--     URL mat bharo. Real video Backend se upload hone par hi URL aayega.)
--   * Koi demo/fake user, fake views ya fake coins NAHI daale jaate.
--   * Characters: Aarav (main character, user control karta hai), Meera,
--     Vikram Singh, Rani Devika.
-- Idempotent hai: dobara run karne par purani seed rows delete karke
-- phir se daalta hai, duplicate nahi banta.
-- ============================================================================

begin;

-- Purani seed story ho to pehle saaf karo (story_id se cascade hoga)
delete from public.stories
where id = '11111111-2222-4333-8444-555555555555';

-- ----------------------------------------------------------------------------
-- 1. Story (pehle bina start_node_id ke, nodes ke baad update karenge)
-- ----------------------------------------------------------------------------
insert into public.stories (
  id, title, description, cover_image, category,
  is_mature, is_live, is_featured, start_node_id
) values (
  '11111111-2222-4333-8444-555555555555',
  'Haveli Ka Raaz — Dhundpura Nights',
  'Dhundpura ki purani haveli me Aarav ek raaz kholne aata hai. Meera, Vikram Singh aur Rani Devika — har faisla story ko badal deta hai. 18+ Mature Thriller, cinematic non-graphic style. Har mor par 2-3 options, 3 alag endings.',
  null,
  'Thriller',
  true,   -- is_mature
  true,   -- is_live (Home par dikhegi)
  true,   -- is_featured
  null    -- start_node_id neeche update hoga
);

-- ----------------------------------------------------------------------------
-- 2. video_nodes — exactly 12
--    N1..N9  = decision nodes (is_ending = false)
--    E1..E3  = ending nodes   (is_ending = true)
--    trigger_timestamp_seconds = choice kab dikhe (seconds)
--    video_url = NULL (Upload Pending)
-- ----------------------------------------------------------------------------
insert into public.video_nodes (
  id, story_id, node_name, video_url,
  trigger_timestamp_seconds, is_ending, ending_name, sort_order
) values
  ('10000000-0000-4000-8000-000000000001', '11111111-2222-4333-8444-555555555555', 'Scene 1 - Intro', null, 5, false, null, 1),
  ('10000000-0000-4000-8000-000000000002', '11111111-2222-4333-8444-555555555555', 'Scene 2A - Meera Se Mulaqat', null, 5, false, null, 2),
  ('10000000-0000-4000-8000-000000000003', '11111111-2222-4333-8444-555555555555', 'Scene 2B - Budhe Ki Warning', null, 5, false, null, 3),
  ('10000000-0000-4000-8000-000000000004', '11111111-2222-4333-8444-555555555555', 'Scene 3A - Haveli Ke Andar', null, 6, false, null, 4),
  ('10000000-0000-4000-8000-000000000005', '11111111-2222-4333-8444-555555555555', 'Scene 3B - Gaon Walon Se Raaz', null, 6, false, null, 5),
  ('10000000-0000-4000-8000-000000000006', '11111111-2222-4333-8444-555555555555', 'Scene 4A - Vikram Ka Dhokha', null, 6, false, null, 6),
  ('10000000-0000-4000-8000-000000000007', '11111111-2222-4333-8444-555555555555', 'Scene 4B - Rani Devika Ka Raaz', null, 7, false, null, 7),
  ('10000000-0000-4000-8000-000000000008', '11111111-2222-4333-8444-555555555555', 'Scene 5A - Aakhri Faisla', null, 7, false, null, 8),
  ('10000000-0000-4000-8000-000000000009', '11111111-2222-4333-8444-555555555555', 'Scene 5B - Badle Ki Taiyaari', null, 8, false, null, 9),
  ('10000000-0000-4000-8000-000000000010', '11111111-2222-4333-8444-555555555555', 'Ending - Badla Poora', null, 0, true, 'Badla Poora', 10),
  ('10000000-0000-4000-8000-000000000011', '11111111-2222-4333-8444-555555555555', 'Ending - Laalach Ka Anjaam', null, 0, true, 'Laalach Ka Anjaam', 11),
  ('10000000-0000-4000-8000-000000000012', '11111111-2222-4333-8444-555555555555', 'Ending - Mukti — Golden Ending', null, 0, true, 'Mukti — Golden Ending', 12);

-- Start node = Scene 1 - Intro
update public.stories
set start_node_id = '10000000-0000-4000-8000-000000000001'
where id = '11111111-2222-4333-8444-555555555555';

-- ----------------------------------------------------------------------------
-- 3. choices — exactly 19
--    N1: 2, N2: 2, N3: 2, N4: 2, N5: 2, N6: 2, N7: 2, N8: 2, N9: 3 = 19
--    Saare labels Haveli-consistent hain. Kurukshetra / Pandav jaisa koi
--    text yahan nahi hai.
-- ----------------------------------------------------------------------------
insert into public.choices (id, source_node_id, choice_label, target_node_id) values
  -- Scene 1 - Intro (N1)
  ('c0000000-0000-4000-8000-000000000001', '10000000-0000-4000-8000-000000000001', 'Andar chalo', '10000000-0000-4000-8000-000000000002'),
  ('c0000000-0000-4000-8000-000000000002', '10000000-0000-4000-8000-000000000001', 'Pehle gaon walon se haveli ka raaz poochho', '10000000-0000-4000-8000-000000000003'),
  -- Scene 2A - Meera Se Mulaqat (N2)
  ('c0000000-0000-4000-8000-000000000003', '10000000-0000-4000-8000-000000000002', 'Meera par bharosa karo', '10000000-0000-4000-8000-000000000004'),
  ('c0000000-0000-4000-8000-000000000004', '10000000-0000-4000-8000-000000000002', 'Meera se sach poochho', '10000000-0000-4000-8000-000000000006'),
  -- Scene 2B - Budhe Ki Warning (N3)
  ('c0000000-0000-4000-8000-000000000005', '10000000-0000-4000-8000-000000000003', 'Warning ko nazarandaaz karke andar jao', '10000000-0000-4000-8000-000000000004'),
  ('c0000000-0000-4000-8000-000000000006', '10000000-0000-4000-8000-000000000003', 'Gaon walon se aur poochho', '10000000-0000-4000-8000-000000000005'),
  -- Scene 3A - Haveli Ke Andar (N4)
  ('c0000000-0000-4000-8000-000000000007', '10000000-0000-4000-8000-000000000004', 'Upar wali seedhi chadho', '10000000-0000-4000-8000-000000000006'),
  ('c0000000-0000-4000-8000-000000000008', '10000000-0000-4000-8000-000000000004', 'Neeche tahkhana dekho', '10000000-0000-4000-8000-000000000007'),
  -- Scene 3B - Gaon Walon Se Raaz (N5)
  ('c0000000-0000-4000-8000-000000000009', '10000000-0000-4000-8000-000000000005', 'Vikram se milo', '10000000-0000-4000-8000-000000000006'),
  ('c0000000-0000-4000-8000-000000000010', '10000000-0000-4000-8000-000000000005', 'Rani Devika ke baare me poochho', '10000000-0000-4000-8000-000000000007'),
  -- Scene 4A - Vikram Ka Dhokha (N6)
  ('c0000000-0000-4000-8000-000000000011', '10000000-0000-4000-8000-000000000006', 'Vikram ka saath do', '10000000-0000-4000-8000-000000000008'),
  ('c0000000-0000-4000-8000-000000000012', '10000000-0000-4000-8000-000000000006', 'Vikram par shaq karo, Meera ko bulao', '10000000-0000-4000-8000-000000000009'),
  -- Scene 4B - Rani Devika Ka Raaz (N7)
  ('c0000000-0000-4000-8000-000000000013', '10000000-0000-4000-8000-000000000007', 'Rani Devika ka raaz kholo', '10000000-0000-4000-8000-000000000008'),
  ('c0000000-0000-4000-8000-000000000014', '10000000-0000-4000-8000-000000000007', 'Tahkhana me chhupa sach dhoondho', '10000000-0000-4000-8000-000000000009'),
  -- Scene 5A - Aakhri Faisla (N8)
  ('c0000000-0000-4000-8000-000000000015', '10000000-0000-4000-8000-000000000008', 'Sach saamne lao, Vikram ko expose karo', '10000000-0000-4000-8000-000000000010'),
  ('c0000000-0000-4000-8000-000000000016', '10000000-0000-4000-8000-000000000008', 'Haveli chhod kar bhaag jao', '10000000-0000-4000-8000-000000000009'),
  -- Scene 5B - Badle Ki Taiyaari (N9) — 3 choices, 3 endings
  ('c0000000-0000-4000-8000-000000000017', '10000000-0000-4000-8000-000000000009', 'Badla poora karo', '10000000-0000-4000-8000-000000000010'),
  ('c0000000-0000-4000-8000-000000000018', '10000000-0000-4000-8000-000000000009', 'Laalach me pad kar khazana lo', '10000000-0000-4000-8000-000000000011'),
  ('c0000000-0000-4000-8000-000000000019', '10000000-0000-4000-8000-000000000009', 'Meera ko bachakar mukti pao', '10000000-0000-4000-8000-000000000012');

-- ----------------------------------------------------------------------------
-- 4. app_settings — defaults (ye fake data nahi, app ke real settings hain)
--    on conflict: dobara run karne par update ho jaye, duplicate na bane.
-- ----------------------------------------------------------------------------
insert into public.app_settings (key, value) values
  ('free_episodes', '5'::jsonb),
  ('coin_cost', '5'::jsonb),
  ('ad_reward', '30'::jsonb),
  ('vip_plans', '[{"plan":"Weekly","price":49,"duration_days":7},{"plan":"Monthly","price":149,"duration_days":30},{"plan":"Yearly","price":999,"duration_days":365}]'::jsonb),
  ('app_banner', '{"enabled": false, "text": ""}'::jsonb)
on conflict (key) do update set value = excluded.value, updated_at = now();

commit;

-- ----------------------------------------------------------------------------
-- Verify karne ke liye (SQL Editor me alag se chalao):
--   select count(*) as stories from public.stories;              -- 1 hona chahiye
--   select count(*) as nodes from public.video_nodes;            -- 12 hona chahiye
--   select count(*) as choices from public.choices;              -- 19 hona chahiye
--   select count(*) as endings from public.video_nodes where is_ending; -- 3
--   select count(*) as profiles from public.profiles;            -- 0 hona chahiye
--   select count(*) as pending_videos from public.video_nodes where video_url is null; -- 12
-- ----------------------------------------------------------------------------
