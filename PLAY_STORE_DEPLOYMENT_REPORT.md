# Ledgo: Freelance Ledger — Google Play Deployment Report

**Date:** October 31, 2026  
**App Title:** Ledgo: Freelance Ledger  
**Package ID (`applicationId`):** `com.dfile.dfile_mobile`  
**Google Play App ID:** `4974189300351318323`  
**Google Play Developer Account:** `4962102428621215276` (`gribyassine@gmail.com`)  
**Release Version:** `1.0.0` (`versionCode: 1`)

---

## 1. Live Links

| Resource | URL |
| :--- | :--- |
| **Google Play Console — App Dashboard** | https://play.google.com/console/u/0/developers/4962102428621215276/app/4974189300351318323/app-dashboard |
| **Google Play Console — Store Listing** | https://play.google.com/console/u/0/developers/4962102428621215276/app/4974189300351318323/store-listings |
| **Google Play Console — App Content** | https://play.google.com/console/u/0/developers/4962102428621215276/app/4974189300351318323/app-content/overview |
| **Google Play Console — Internal Testing** | https://play.google.com/console/u/0/developers/4962102428621215276/app/4974189300351318323/tracks/internal-testing |
| **Google Play Console — Closed Testing** | https://play.google.com/console/u/0/developers/4962102428621215276/app/4974189300351318323/closed-testing |
| **GitHub Pages Repository** | https://github.com/YassineGrib/ledgo |
| **Compliance Landing Page** | https://yassinegrib.github.io/ledgo/ |
| **Privacy Policy** | https://yassinegrib.github.io/ledgo/privacy-policy/ |
| **Account & Data Deletion** | https://yassinegrib.github.io/ledgo/delete-account/ |
| **Terms of Service** | https://yassinegrib.github.io/ledgo/terms/ |

---

## 2. Build, Keystore & Firebase Certificates

### Project Files Updated / Created
- **Android Manifest Label:** `android/app/src/main/AndroidManifest.xml` (`android:label="Ledgo"`)
- **Launcher Icons:** `android/app/src/main/res/mipmap-*/ic_launcher.png` (`mdpi` through `xxxhdpi`, generated from `ledgo_play_store/1-app-icon/ledgo-icon-512.png`)
- **Release Signing Config:** `android/app/build.gradle.kts`
- **Upload Keystore (Git-Ignored — Back Up Safely):** `android/upload-keystore.jks` & `android/key.properties`
- **In-App Web Deletion Constant:** `lib/features/settings/settings_privacy_strings.dart`
- **Static Compliance Site Source:** `pages/` (`index.html`, `privacy-policy/index.html`, `delete-account/index.html`, `terms/index.html`, `styles.css`, `site.js`, `.nojekyll`)
- **Signed Release Bundle:** `build/app/outputs/bundle/release/app-release.aab` (`61.9 MB` bundle → ~`15 MB` Play Store install size)

> **Important:** Back up `android/upload-keystore.jks` and `android/key.properties` to secure offline storage. You will need this upload key to sign every future update to `com.dfile.dfile_mobile`.

### Certificate Fingerprints (Add to Firebase `fintask-app`)
To ensure **Google Sign-In** works on builds installed from Google Play, add both `SHA-1` (and `SHA-256`) fingerprints in **Firebase Console → Project Settings → Android App (`com.dfile.dfile_mobile`)**, then re-download `google-services.json` if needed:

- **Google Play App Signing Key (Primary — Used on User Devices):**
  - `SHA-1`: `8A:FD:05:A4:F3:A0:E4:17:F8:6D:03:CA:61:9F:94:5D:F3:AE:78:20`
  - `SHA-256`: `CD:6C:08:9D:81:86:11:C9:7A:47:F6:68:6B:A7:03:57:D2:90:6F:7B:66:5D:83:E4:55:2F:04:83:AB:96:97:BF`
- **Local Upload Key (`android/upload-keystore.jks`, alias `upload`):**
  - `SHA-1`: `6E:2E:E4:D7:B3:2F:90:58:17:D8:84:80:54:DF:83:DE:9D:0A:EE:E3`
  - `SHA-256`: `51:25:F8:92:E4:2E:78:44:B3:51:42:48:F9:A1:1D:CA:3C:2A:5F:B1:93:25:4E:4C:82:5B:BA:CC:48:81:ED:A4`

---

## 3. Completed Google Play Console Sections

### Store Settings & Main Store Listing (`Ready to send for review`)
- **Category:** `Business`
- **Contact Details:** `gribyassine@gmail.com` | `https://yassinegrib.github.io/ledgo/`
- **Store Listing Copy:** Populated from `ledgo_play_store/5-listing-text/` (`title.txt`, `short_description.txt`, `full_description.txt`)
- **Graphics Uploaded:**
  - App Icon (`ledgo-icon-512.png`, `512×512`)
  - Feature Graphic (`ledgo-feature-graphic-1024x500.png`, `1024×500`)
  - Phone Screenshots (`ledgo-phone-01.png` through `ledgo-phone-08.png` in exact `01..08` order)

### App Content Declarations
- [x] **Privacy Policy:** `https://yassinegrib.github.io/ledgo/privacy-policy/`
- [x] **Ads:** `No, my app does not contain ads`
- [x] **Advertising ID:** `No`
- [x] **Government Apps:** `No`
- [x] **Health Apps:** `My app does not have any health features`
- [x] **Financial Features:** `My app doesn't provide any financial features` (manual freelance bookkeeping/ledger)
- [x] **Content Ratings (IARC):** Submitted (`ESRB Everyone`, `PEGI 3`, `USK All ages`, `Rated for 3+`)
- [x] **Data Safety:** All 5 steps + Account & Data Deletion URL (`https://yassinegrib.github.io/ledgo/delete-account/`) imported, validated, and saved as draft

### Release Tracks
- [x] **Internal Testing:** `app-release.aab` (`1 (1.0.0)`, API `24+`, Target SDK `36`) uploaded and **published** (`Available to internal testers`)
- [x] **Closed Testing — Alpha:** Release `1 (1.0.0)` attached from artifact library with `en-GB` release notes and saved as draft

---

## 4. Remaining Manual Steps (~2 Minutes)

1. **Enter Reviewer Login (`App content → Sign-in details`):**
   - Select *All or some functionality in my app is restricted* → *Add instructions* and enter a demo/reviewer email and password for Google Play reviewers, then click **Save**.
2. **Submit Target Audience & Pre-Filled Data Safety:**
   - Open **App content → Target audience and content** (unlocked as soon as `Sign-in details` is saved), select **`18 and over`** → **Next** → **Save**.
   - Open **App content → Data safety** (already pre-filled and saved as draft) and click **Next** through to **Save**.
3. **Add Testers & Roll Out Closed Testing:**
   - **Internal Testing → Testers:** Tick an email list and click **Save**, then click **Copy link** under *How testers join your test* to install immediately from Google Play.
   - **Closed Testing → Closed testing - Alpha:** Select countries/regions, add at least **12 opted-in testers** (required for 14 days on Personal Play Console accounts before applying for Production access), open the saved `1 (1.0.0)` release draft, and click **Next → Save and publish**.

