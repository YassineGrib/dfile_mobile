# Google Play readiness checklist (Dfile mobile)

Status as of this commit. "Code" items are in the repo; "You" items need your accounts or decisions.

## In the app (done or in progress)
- [x] In-app account deletion path (Settings > Privacy and data > Delete account), re-authenticated, with progress and a final screen.
- [x] Privacy policy and Terms inside the app, consent checkbox at sign-up, data-usage page, data export (JSON to clipboard).
- [ ] Real backend: today all data is local mock data and a fake sign-in. Play's Data safety answers and the deletion URL depend on the real backend (Firebase). Re-check this list when it is connected.

## Build and signing (Code, needs your keystore)
- [ ] Release signing: android/app/build.gradle.kts still signs release with the DEBUG key. Create an upload keystore (keep the .jks and passwords OUTSIDE git, back them up; losing it blocks updates), add key.properties and a release signingConfig.
- [ ] Build an Android App Bundle: `flutter build appbundle --release` (Play requires .aab, not .apk).
- [ ] App name: android label is "dfile_mobile", change to "Dfile".
- [ ] Application id: `com.dfile.dfile_mobile` is permanent once published; change it now if you want another (e.g. your own domain).
- [ ] Launcher icon: still the default Flutter icon. Needs an adaptive icon (and a 512x512 store icon).
- [ ] Version: pubspec `1.0.0+1`; increase the build number for every upload.
- [ ] Target API: the Flutter template's targetSdk is current; Play requires the latest target level for new apps each year, re-check at upload.
- [ ] Permissions: the manifest declares none besides what Flutter adds. When Firebase is added you need INTERNET only; do not add more without a reason (Play reviews them).

## Play Console (You)
- [ ] Developer account (one-time fee), create the app, choose free or paid.
- [ ] Privacy policy URL: host the policy text from the app on a public page and paste the URL.
- [ ] Account deletion: Data safety form asks for the in-app path (Settings > Privacy and data > Delete account) and a web URL where users can request deletion without the app (host a page, the app text mentions decabyte.dz/delete-account as a placeholder: replace it with your real URL in lib/features/settings strings).
- [ ] Data safety form: personal info (name, email, phone: collected, not shared, encrypted in transit, deletable), financial info entered by the user (collected, not shared), no ads, no data sold. Answer again after the backend is connected.
- [ ] Content rating questionnaire (business / productivity app, no user-generated public content).
- [ ] Target audience: adults, not designed for children.
- [ ] Store listing: short description (80), full description (4000), 2 to 8 phone screenshots, 512x512 icon, 1024x500 feature graphic, contact email.
- [ ] Testing track: new personal developer accounts must run a closed test (12 testers for 14 days) before production.
