# StoryPlay — GitHub + Supabase Real Backend (Setup Guide)

**App:** StoryPlay | **Package:** `com.storyplay.app` | **Version:** 1.0.0
**Owner:** owner@storyplay.app

> **Sach pehle:** Abhi koi Supabase project bana hua NAHI hai, koi credentials save NAHI hain, aur koi live connection NAHI hai. Ye package sirf **taiyaari** hai — neeche ke steps karne ke baad hi backend real hoga.

---

## Is package me kya hai

| File | Kaam |
|---|---|
| `supabase/schema.sql` | Postgres tables + RLS policies (stories, video_nodes, choices, profiles, app_settings) |
| `supabase/seed.sql` | Ekmatra real story — Haveli Ka Raaz (12 nodes, 19 choices, 3 endings), sab video_url NULL |
| `supabase/client.js` | Supabase client + helpers (getLiveStories, getStoryTree, getSettings) — koi key hardcode nahi |
| `.github/workflows/deploy-pages.yml` | Static UI ko GitHub Pages par deploy karta hai (sirf UI, backend nahi) |

---

## Step-by-step — Supabase project banao

### (a) supabase.com par free account + New Project
1. [supabase.com](https://supabase.com) kholo, Sign up / Log in karo (GitHub se bhi login ho jata hai).
2. **New Project** dabao.
3. Project ka naam rakho: `storyplay`
4. Database Password banao aur **kahi safe jagah likh lo** — ye password kisi ko mat do, Muse ko bhi chat me mat bhejo.
5. Region chuno jo India ke paas ho (jaise **Mumbai / ap-south-1** agar dikhe, warna Singapore).
6. **Create new project** dabao — 1-2 minute lagega.

### (b) SQL Editor me pehle schema.sql, phir seed.sql run karo
1. Left sidebar me **SQL Editor** kholo.
2. **New query** dabao, apne computer se `supabase/schema.sql` ki poori file copy karke paste karo, **Run** dabao.
   - Agar koi error na aaye to tables ban gayi.
3. Phir ek aur **New query** me `supabase/seed.sql` paste karke **Run** dabao.
4. Check karo (SQL Editor me ye chalao):
   ```sql
   select count(*) as stories from public.stories;   -- 1 hona chahiye
   select count(*) as nodes from public.video_nodes; -- 12 hona chahiye
   select count(*) as choices from public.choices;   -- 19 hona chahiye
   select count(*) as profiles from public.profiles; -- 0 hona chahiye
   ```
   Agar ye numbers sahi hain to seed sahi hai.

### (c) Storage me 2 buckets banao
1. Left sidebar me **Storage** kholo.
2. **New bucket** dabao:
   - Naam: `story-posters` — **Public bucket** ON rakho — Create.
   - Phir se **New bucket**: Naam: `story-videos` — **Public bucket** ON rakho — Create.
3. Ye buckets poster aur video clips ke liye hain. Upload sirf Owner (Backend Admin) karega.

### (d) Settings > API se Project URL + anon key copy karo
1. Left sidebar neeche **Settings (gear icon)** > **API** kholo.
2. Wahan milega:
   - **Project URL** — jaise `https://xyzcompany.supabase.co`
   - **anon public key** — lamba sa key, `eyJ...` se shuru hota hai.
3. Ye dono copy karke rakho.
4. **service_role key kabhi mat do** — wo secret key hai, use chat, GitHub ya app code me kabhi mat daalo. Sirf **anon key** chahiye hoti hai.

### (e) Wo URL + anon key StoryPlay Backend ke App Connection form me daalo aur Test Connection dabao
1. StoryPlay Backend Admin kholo (owner@storyplay.app se login).
2. Sidebar me **App Connection** kholo.
3. **Supabase Project URL** aur **Anon Key** ke fields me upar wale (d) wale values daalo, **Save** dabao.
4. **Test Connection** dabao:
   - Sahi credentials hain to status **Connected — Real Supabase** dikhega.
   - Galat / khaali ho to saaf **Not Connected — Preview Sync mode** dikhega — koi jhootha "connected" nahi dikhega.
5. Key hamesha masked dikhegi (sirf pehle 6 + aakhri 4 characters), poori key kahin save/show nahi hoti.

### (f) Phir Backend se Publish karte hi story app me dikhegi
1. Backend me **Meri Kahaniyan** me Haveli Ka Raaz **LIVE ON** rakho.
2. Ab app kholo — Home ke **All Stories** me story turant dikhegi, bina Sync dabaye.
3. LIVE OFF karte hi Home se turant chhup jayegi.
4. Nayi story Backend ke 4-step wizard se banao aur Publish karo — wo bhi app me aa jayegi.

---

## GitHub Pages (sirf UI) — optional
1. GitHub par repo banao, is package + StoryPlay ka static UI (`www/` folder) upload karo.
2. Repo **Settings > Pages > Source: GitHub Actions** rakho.
3. `main` par push karte hi `.github/workflows/deploy-pages.yml` UI deploy kar dega.
4. **Yaad rakho:** Pages sirf UI host karta hai, backend nahi. Bina Supabase ke data phir bhi per-browser/session-only rahega.

---

## Abhi kya NAHI hua hai (kuch bhi live nahi hai)
- [ ] Koi Supabase project nahi bana hai
- [ ] Koi credentials save nahi hain
- [ ] Koi live connection nahi hai — jab tak upar ke (a)-(e) steps nahi hote
- [ ] Koi video upload nahi hua hai — sab nodes par video_url NULL hai (Upload Pending)
- [ ] Koi user, views ya coins nahi hain — Dashboard 0 se shuru hota hai

## Play Store ke liye yaad rakho
Play Store par publish ke liye APK nahi, **signed AAB** chahiye hota hai, plus keystore, Play Console ($25) account, privacy policy aur app icon/screenshots. APK banane ka project alag folder `storyplay-android/` me hai — uska README_HINDI.md dekho.
