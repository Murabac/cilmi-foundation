# Upload CILMI FOUNDATION to the Google Play Store

This checklist is for this Flutter app (`com.cilmifoundation.mobile`).  
Play Store requires an **AAB** (Android App Bundle), not only an APK.

---

## 0. Before you start

You need:

- [ ] A **Google Play Console** account ([play.google.com/console](https://play.google.com/console)) — one-time **$25** registration fee
- [ ] A Google account (organization or personal)
- [ ] App icon, screenshots, short + full description (EN and optionally SO)
- [ ] A **privacy policy URL** (required — the app uses phone login, internet, and call)
- [ ] This project built and tested on a real Android phone

**Important for this project today:** release builds still use the **debug signing key** in `android/app/build.gradle.kts`. Play Store will **reject** that. You must create and use a **release keystore** (steps below).

---

## 1. Create a Play Console app

1. Open [Google Play Console](https://play.google.com/console).
2. Click **Create app**.
3. Fill in:
   - **App name:** `CILMI FOUNDATION` (or `Cilmi Foundation`)
   - **Default language:** English (United States) or add Somali later
   - **App or game:** App
   - **Free or paid:** Free
4. Accept the declarations → **Create app**.

---

## 2. Create a release signing key (required)

Do this **once**. Back up the keystore and passwords forever — if you lose them, you cannot update the same app.

### 2.1 Generate the keystore

In PowerShell, from the project root:

```powershell
cd android
keytool -genkey -v -keystore upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

When prompted, enter:

- A strong **keystore password** (save it)
- A strong **key password** (can be the same)
- Your name / org (e.g. Cilmi Foundation)

Move the file to a safe place, e.g.:

```text
android/upload-keystore.jks
```

**Do not commit** `upload-keystore.jks` or passwords to Git.

### 2.2 Create `android/key.properties`

Create `android/key.properties` (also **do not commit**):

```properties
storePassword=YOUR_STORE_PASSWORD
keyPassword=YOUR_KEY_PASSWORD
keyAlias=upload
storeFile=upload-keystore.jks
```

### 2.3 Wire signing into Gradle

Update `android/app/build.gradle.kts` so **release** uses this keystore instead of `debug`.

Typical pattern:

1. Load `key.properties` at the top of the file.
2. Define a `signingConfigs { create("release") { ... } }`.
3. Set `buildTypes.release.signingConfig = signingConfigs.getByName("release")`.

Official Flutter guide:  
[https://docs.flutter.dev/deployment/android#signing-the-app](https://docs.flutter.dev/deployment/android#signing-the-app)

### 2.4 Add to `.gitignore`

Make sure these are ignored:

```text
android/key.properties
android/*.jks
android/*.keystore
```

---

## 3. Set version numbers

In `pubspec.yaml`:

```yaml
version: 1.0.0+1
```

- `1.0.0` → **versionName** (user-visible)
- `+1` → **versionCode** (must increase for every Play upload: 2, 3, 4…)

For each new store upload, bump at least the number after `+`.

---

## 4. Build the Play Store file (AAB)

From the project root:

```powershell
flutter clean
flutter pub get
flutter build appbundle --release
```

Output file:

```text
build\app\outputs\bundle\release\app-release.aab
```

That `.aab` is what you upload to Play Console.

(Optional) Also keep an APK for direct install/testing:

```powershell
flutter build apk --release
```

---

## 5. Complete Play Console “Set up your app”

In the left menu, finish every required item (Play shows a checklist):

### 5.1 Store listing

- [ ] **App name:** CILMI FOUNDATION  
- [ ] **Short description** (≤ 80 characters)  
- [ ] **Full description**  
- [ ] **App icon** 512×512 PNG  
- [ ] **Feature graphic** 1024×500 PNG  
- [ ] **Phone screenshots** (at least 2; usually 4–8)  
- [ ] **Tablet screenshots** (optional but recommended)

Tips:

- Capture screens from a real device or emulator (dashboard, family tree, payments, etc.).
- Keep branding: navy `#102850`, gold `#B89020`, cream `#F1EBD9`.

### 5.2 App category & contact

- [ ] Category (e.g. **Social** or **Lifestyle**)
- [ ] Email contact (required)
- [ ] Phone / website (optional)

### 5.3 Privacy policy (required)

Host a privacy policy page (GitHub Pages, Notion public page, your website) and paste the URL.

It should mention:

- Account / phone number used for login  
- Family profile and contribution data stored in Supabase  
- Internet access  
- Phone call / dialer and WhatsApp links when a member has a number  

### 5.4 App access (if needed)

If reviewers cannot register without an existing family tree name:

- [ ] Provide a **test phone + password**  
- [ ] Or explain that a super admin must approve a profile claim  
- [ ] Optionally provide a demo account already linked  

Without this, review can be delayed or rejected.

### 5.5 Ads

- [ ] Declare whether the app contains ads (**No** for this app, unless you add them later)

### 5.6 Content rating

- [ ] Start the questionnaire  
- [ ] Answer honestly (family data, no gambling, etc.)  
- [ ] Apply the rating

### 5.7 Target audience

- [ ] Age groups  
- [ ] If children are involved in the family tree as *data*, read the children questions carefully (this is not usually a “kids app”)

### 5.8 News / COVID / Data safety

Complete **Data safety**:

Typical for this app (confirm against your real Supabase usage):

| Data | Collected? | Shared? | Purpose |
|------|------------|---------|---------|
| Phone number | Yes | No (your backend only) | Account |
| Name | Yes | No | Account / family tree |
| Photos (avatar / receipts) | Yes if used | No | Profile / payments |
| App activity / financial (contributions) | Yes | No | App features |

Declare encryption in transit (HTTPS / Supabase) if true.

### 5.9 Government apps / other declarations

Answer **No** unless they apply.

---

## 6. Create a production (or testing) release

Recommended path for first upload:

### Option A — Internal testing (best first)

1. **Testing → Internal testing → Create new release**  
2. Upload `app-release.aab`  
3. Add release notes (e.g. “Initial release of CILMI FOUNDATION”)  
4. Save → Review → **Start rollout to Internal testing**  
5. Add tester Gmail accounts  
6. Install from the Play testing link and verify

### Option B — Closed testing

Same idea with a larger tester group. Google often expects testing history before production for new accounts.

### Option C — Production

1. **Production → Create new release**  
2. Upload the same (or newer) AAB  
3. Release notes  
4. **Review release → Start rollout to Production**

First production review can take from hours to several days.

---

## 7. Countries / pricing

- [ ] Select countries (e.g. Somalia + diaspora countries)  
- [ ] Confirm Free  
- [ ] Save

---

## 8. After approval — updates

For every update:

1. Bump version in `pubspec.yaml` (e.g. `1.0.1+2`)  
2. `flutter build appbundle --release`  
3. Upload new AAB to a new release  
4. Roll out (staged % or 100%)

Always sign with the **same** upload keystore.

---

## 9. Project-specific checklist

Things unique to CILMI FOUNDATION:

| Item | Current / action |
|------|------------------|
| Package ID | `com.cilmifoundation.mobile` — keep forever once published |
| App label | `CILMI FOUNDATION` in `AndroidManifest.xml` |
| Signing | Must leave debug signing before Play upload |
| Permissions | `INTERNET`, `CALL_PHONE` — declare in Data safety / policy |
| Login | Phone + password via Supabase — give reviewers access instructions |
| Backend | Supabase must be production-ready (`env.json` / secrets correct) |
| Email confirm | Keep Supabase “Confirm email” **off** for the phone-email login flow |

---

## 10. Quick command summary

```powershell
# 1) After keystore + key.properties + Gradle signing are set:

flutter clean
flutter pub get
flutter build appbundle --release

# 2) Upload this file in Play Console:
# build\app\outputs\bundle\release\app-release.aab
```

---

## 11. Common rejection reasons

- Signed with **debug** key  
- Missing **privacy policy**  
- Incomplete **Data safety** form  
- Reviewers **cannot log in** / claim a profile  
- Crash on open (wrong Supabase URL/keys in release)  
- `versionCode` not increased  
- Misleading screenshots or wrong package name

---

## Helpful links

- [Play Console](https://play.google.com/console)  
- [Flutter Android deployment](https://docs.flutter.dev/deployment/android)  
- [Play app signing](https://support.google.com/googleplay/android-developer/answer/9842756)  
- [Data safety form](https://support.google.com/googleplay/android-developer/answer/10787469)

---

When signing is configured, the only upload artifact you need is:

`build\app\outputs\bundle\release\app-release.aab`
