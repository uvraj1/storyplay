# StoryPlay

**Your Choice. Your Story.**

StoryPlay is an interactive branching-story streaming app — a Netflix / ReelShort-style
dark-themed OTT app where the user makes a choice every few seconds and the story
branches to a different ending.

- **App:** StoryPlay
- **Package:** `com.storyplay.app`
- **Version:** 1.0.0
- **Owner:** owner@storyplay.app
- **Design:** Cinematic Dark Glassmorphism — deep obsidian `#090A0F`, Amber-Gold `#F59E0B`, Neon Crimson accents

## The one real story

**'Haveli Ka Raaz — Dhundpura Nights'** (18+ Mature Thriller) — the only story in the
app, LIVE and Home Featured.

- 12 nodes, 9 decision points, 19 choices, 3 endings:
  **Badla Poora**, **Laalach Ka Anjaam**, **Mukti — Golden Ending**
- Characters: Aarav (the main character, controlled by the user), Meera, Vikram Singh,
  Rani Devika
- The 18+ content is mature thriller / betrayal / romance tension in a cinematic
  **non-graphic** style. No explicit graphic content.
- **Honest note: all real video clips are still 'Upload Pending'.** Every node's
  `video_url` is empty until a real video is uploaded through the Backend. No fake
  video URLs are in this repo.

## Repo structure

```
README.md                     — this file
supabase/
  schema.sql                  — Postgres tables + RLS (stories, video_nodes, choices, profiles, app_settings)
  seed.sql                    — the one real story: Haveli Ka Raaz (12 nodes, 19 choices, 3 endings)
  client.js                   — Supabase client + helpers (getLiveStories, getStoryTree, getSettings)
  README_HINDI.md             — Hinglish setup guide for the Supabase backend
android/
  package.json                — Capacitor 8.6.2 wrapper (appId com.storyplay.app)
  capacitor.config.json       — Capacitor config (webDir www)
  README_HINDI.md             — Hinglish guide: build the APK with GitHub Actions and test it
  .github/workflows/build-apk.yml — GitHub Actions: builds the Debug APK (and Release AAB on demand)
  android/                    — native Android project (Manifest, MainActivity, Gradle files)
.github/workflows/
  deploy-pages.yml            — deploys the static UI to GitHub Pages (UI only, not the backend)
```

## How the APK is built (GitHub Actions)

This machine has no Flutter / Java / Android SDK, so no APK is built here and
**no APK file is in this repo**. The APK is built on GitHub:

1. Push to `main` (or run the workflow manually from the **Actions** tab).
2. The **Build StoryPlay APK** workflow runs: Node 20, `npm ci`, JDK 17, Android SDK,
   `npx cap sync android`, `./gradlew assembleDebug`.
3. Download **storyplay-debug-apk** from the run's Artifacts — it contains `app-debug.apk`.
4. For a Play Store Release AAB, run the workflow with `build_aab = true` and set the
   four signing secrets (`ANDROID_KEYSTORE_BASE64`, `ANDROID_KEYSTORE_PASSWORD`,
   `ANDROID_KEY_ALIAS`, `ANDROID_KEY_PASSWORD`). No keystore or password is in this repo.

## How the Supabase backend connects

GitHub cannot host a real backend — no database, auth, users, coins, or video
storage. GitHub holds the code, GitHub Pages holds only the static UI. The real
backend is **Supabase** (Postgres + Auth + Storage, free tier to start):

1. Create a free project at supabase.com named `storyplay` (see `supabase/README_HINDI.md`).
2. In the Supabase SQL Editor, run `supabase/schema.sql`, then `supabase/seed.sql`.
3. Create the Storage buckets `story-posters` and `story-videos`.
4. Copy the **Project URL** and **anon key** (never the service_role key) into the
   StoryPlay Backend Admin → App Connection form and press Test Connection.
5. Publishing a story in the Backend then shows it in the app for all users, and
   users / coins are saved for real.

**Honest status: no live Supabase connection exists yet.** No Supabase project,
Project URL, or anon key has been obtained. Until one is created and connected,
the app runs on its built-in shared database / preview sync, not on a live server.

## What is NOT in this repo (deliberately)

- `android/www/` — the full exported app HTML (`www/index.html`, ~23 MB). It exceeds
  the GitHub connector's 16 MiB snapshot-push limit, so it was not pushed here.
  Add it later via a local `git clone` + commit, or rebuild it with `npx cap sync android`.
  The same applies to `android/android/app/src/main/assets/public/index.html`.
- `node_modules/`, build outputs, `.apk` / `.aab` files, and binary launcher/splash
  images (`.png`) and `gradle-wrapper.jar` — snapshot push accepts UTF-8 text only.
  GitHub Actions installs dependencies and rebuilds these itself. The default
  Capacitor launcher icon/splash still need to be replaced with the StoryPlay logo
  before a Play Store release.
- No fake/demo data: no fake views, users, coins, history, VIP, or test stories.
  Real counts start at zero (Users 0, Stories 1, Nodes 12, Coins 0, Premium 0).
