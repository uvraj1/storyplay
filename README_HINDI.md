# StoryPlay — APK kaise banayein aur phone me install karke test karein

Ye folder **StoryPlay** ka real Android project hai. Isme **koi APK abhi nahi hai** — APK GitHub par banega, neeche diye steps se. App ka naam: **StoryPlay**, Package: **com.storyplay.app**, Version: **1.0.0**.

Ye app Capacitor se bana hai — aapne jo StoryPlay web app test kiya tha (Home par All Stories, Haveli Ka Raaz, Settings), wahi app Android ke andar chalega.

## Aapko kya-kya chahiye

- Ek **GitHub account** (free, github.com)
- Ek **Android phone** (APK install karne ke liye)
- Bas. Java / Android Studio aapke computer par install karne ki zaroorat nahi hai.

## Step 1 — GitHub par repo banao

1. GitHub kholo, **New repository** par click karo.
2. Repository ka naam rakho: `storyplay-android`
3. **Private** chuno (public bhi chalega, lekin private behtar hai).
4. **Create repository** par click karo.

## Step 2 — Ye folder GitHub par upload karo

1. Apne computer par is `storyplay-android` folder ko kholo.
2. GitHub repo page par **"uploading an existing file"** par click karo.
3. Folder ke andar ki **saari files aur folders** drag-and-drop karo — `www/`, `android/`, `package.json`, `capacitor.config.json`, `.github/` sab.
4. Neeche commit message me likho: `StoryPlay Android v1.0.0` aur **Commit changes** par click karo.

> Dhyaan do: `node_modules/` folder upload karne ki zaroorat nahi hai — GitHub Actions khud install kar lega. Agar upload me wo folder dikhe to use chhod do.

## Step 3 — GitHub Actions se APK banao

1. GitHub repo me upar **Actions** tab kholo.
2. Left side me **"Build StoryPlay APK"** workflow chuno.
3. **Run workflow** button dabao, phir green **Run workflow** dabao.
4. 3–7 minute wait karo. Kaam khatam hone par green tick aayega.
5. Us run ko kholo, neeche **Artifacts** me **storyplay-debug-apk** dikhega — use download karo. Uske andar **app-debug.apk** milega.

> Agar workflow red (fail) ho jaye to Actions ke log me error dekho aur Muse ko batao — error ka screenshot / text bhej do, Muse fix karke dega.

## Step 4 — Phone me install karke test karo

1. **app-debug.apk** ko apne phone me bhejo (WhatsApp / USB / Google Drive — jaisa aasan lage).
2. Phone me APK file par tap karo. Agar phone poochhe to **"Install unknown apps" / "Unknown Sources"** ko Allow karo (sirf is install ke liye).
3. **Install** dabao. Home screen par **StoryPlay** icon aayega.
4. App kholo aur test karo — Home par All Stories, Haveli Ka Raaz kholo, choices dabao, Settings kholo.

## Step 5 — Changes karne hon to

- App me koi change karna ho (naam, story, design, Settings) to **Muse ko batao** — Muse web app badal kar is folder ki `www/index.html` aur `android/app/src/main/assets/public/index.html` update kar dega.
- Phir dobara Step 2 (upload) aur Step 3 (Run workflow) karo — naya APK ban jayega.
- Apne aap `android/` folder ke andar haath se kuch mat badlo, warna `npx cap sync android` par overwrite ho sakta hai.

## Play Store par publish karna ho to (baad me)

Debug APK Play Store par nahi chadhta. Uske liye ye chahiye:

1. **Release AAB** — isi workflow me `build_aab` option hai, lekin uske liye **signing keystore** chahiye:
   - Apne computer par `keytool` se ek keystore banao (kabhi kisi ko mat do, backup sambhal kar rakho).
   - GitHub repo ke **Settings → Secrets → Actions** me 4 secrets daalo: `ANDROID_KEYSTORE_BASE64`, `ANDROID_KEYSTORE_PASSWORD`, `ANDROID_KEY_ALIAS`, `ANDROID_KEY_PASSWORD`.
   - Phir Actions me **Run workflow** karte waqt `build_aab` ko **true** karo.
2. **Google Play Console account** — $25 ek baar ki fee, play.google.com/console.
3. **Privacy Policy** ka link, app icon (512×512), feature graphic aur kam se kam 2 phone screenshots.
4. Play Console me app banao, AAB upload karo, store listing bharo, review ke liye submit karo.

## Sach — kya hai, kya nahi hai

- ✅ Ye folder build ke liye poora taiyaar hai: Capacitor 8.6.2, Android project, workflow — sab check kiya gaya hai.
- ✅ Jo APK banega wo wahi StoryPlay hoga jo aapne test kiya tha.
- ❌ Is folder me **abhi koi APK nahi hai** — APK sirf GitHub Actions run karne ke baad milega.
- ❌ Backend abhi real live server se connected nahi hai — app aur Backend Admin Preview Sync mode me hain. Play Store par daalne se pehle real Supabase connection karna hoga, warna har user ko alag data dikhega.
- ❌ Koi keystore, password ya Play Console account is folder me nahi hai — ye sab aapko khud banana hoga, Muse aapse password kabhi nahi maangega.
