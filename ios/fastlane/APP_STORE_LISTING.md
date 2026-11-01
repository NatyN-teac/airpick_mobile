# GuzoMy: App Store Connect setup

## Status (2026-10-22)

**App Store Connect app:** "GuzoMy: Send with Travelers", Apple ID `6825872348`, team MERKAVAH LABS, LLC
(`B82K4238LC`), bundle `com.guzomy.app`, SKU `guzomy-ios`, version 1.0.0.

| Item | State |
|---|---|
| App ID capabilities (Push, Sign in with Apple) | ✅ |
| APNs key `PYQ9M685Z8` in Firebase (development + production) | ✅ |
| Apple Distribution certificate (expires 2027-10-22) + "GuzoMy App Store" profile | ✅ Release builds sign manually with these |
| Listing en-US / fr-FR / ar-SA (name, subtitle, description, keywords, promo text, URLs) | ✅ |
| Category Travel / Lifestyle, copyright, content rights, price Free (base territory USA) | ✅ |
| Age rating questionnaire + override to 18+ | ✅ |
| App Privacy: 10 data types, App Functionality, linked, not tracked | ✅ saved, **not published** |
| App Review contact + notes | ✅; demo account user name and password still empty |
| TestFlight internal group "Merkavah Internal" with tesfahunkebede336@gmail.com | ✅ (the invite goes out once a build has processed) |
| Build 1.0.0 (58) uploaded | ⏳ see below |
| Screenshots (6.9" iPhone) | ❌ |
| Availability (countries) / EU trader status | ❌ |

### Rebuild and upload

```
flutter build ios --config-only --release
cd ios && xcodebuild -workspace Runner.xcworkspace -scheme Runner -configuration Release \
  -destination 'generic/platform=iOS' -archivePath ../build/ios/archive/Runner.xcarchive archive
xcodebuild -exportArchive -archivePath ../build/ios/archive/Runner.xcarchive \
  -exportOptionsPlist ExportOptions.plist -exportPath ../build/ios/ipa
```

The build number comes from `version:` in pubspec.yaml (the `+N` part). Build 58 is already on App Store Connect, so increase
`+N` before each upload. The next one is `1.0.0+59`. Upload with Transporter or Xcode Organizer, or set `destination` to `upload`
in a copy of `ExportOptions.plist`. For that, Xcode must be signed in under Settings → Accounts.

Store text is in `metadata/<locale>/` (fastlane `deliver` layout), adapted from
`android/fastlane/metadata/android/`. Paste it into App Store Connect by hand, or upload it with
`fastlane deliver --skip_binary_upload --skip_screenshots`.

| Locale | Name | Subtitle | Promo | Keywords | Description |
|---|---|---|---|---|---|
| en-US (primary) | 27/30 | 29/30 | 129/170 | 94/100 | ~2010/4000 |
| fr-FR | 28/30 | 28/30 | 121/170 | 90/100 | ~2090/4000 |
| ar-SA | 25/30 | 26/30 | 94/170 | 63/100 | ~1470/4000 |

Amharic is not an App Store localization, so Ethiopian storefronts show en-US.
The Arabic text was machine-drafted. Have a native speaker review it before you publish.
Words in the name and subtitle are already indexed, so the keywords leave them out.

---

## 1. New app

| Field | Value |
|---|---|
| Platform | iOS |
| Name | GuzoMy: Send with Travelers |
| Primary language | English (U.S.) |
| Bundle ID | `com.guzomy.app` |
| SKU | `guzomy-ios` |
| User access | Full access |

## 2. App information

| Field | Value |
|---|---|
| Category | Primary **Travel**, secondary **Lifestyle** |
| Content rights | Contains no third-party content: **No** (users upload their own photos and messages) |
| Copyright | 2026 Merkavah Labs, LLC |
| Privacy policy URL | `https://www.airdashapp.com/` ← **must show a real privacy policy before review** |
| Support URL | `https://www.airdashapp.com/` |
| Price | Free, all territories |

## 3. Age rating (questionnaire)

All content categories (violence, sexual content, profanity, drugs, gambling, horror, medical, and so on): **None**.

| Question | Answer |
|---|---|
| Unrestricted web access | No |
| User-generated content / messaging between users | **Yes** |
| Advertising | No |
| Age assurance / parental controls | No |
| Contests | No |

The expected result is **13+** or **16+** on Apple's 2025 rating scale, because users can message each other freely.
The app is intended for adults (ID verification, meetups with strangers). Consider **overriding to 18+**
to match the Play target audience.

## 4. App Privacy (nutrition label)

- Tracking: **No**. There is no ATT prompt, no IDFA, and no data broker sharing.
- Every data type below is **Linked to the user** and **not used for tracking**.

| Apple data type | Purpose(s) | Notes |
|---|---|---|
| Contact Info → Name | App Functionality | From Google/Apple sign-in and the profile |
| Contact Info → Email Address | App Functionality | Sign-in |
| Contact Info → Phone Number | App Functionality | Optional, third-party receiver contact |
| Identifiers → User ID | App Functionality | Account ID |
| Identifiers → Device ID | App Functionality | FCM push token |
| User Content → Photos or Videos | App Functionality | Item photos, chat images, ID image upload |
| User Content → Emails or Text Messages | App Functionality | In-app chat (Apple puts in-app messages here) |
| User Content → Other User Content | App Functionality | Offers, requests, proposals |
| Sensitive Info | App Functionality | Government ID and selfie/biometric check via Veriff. If you only receive the verification result, check Veriff's App Store privacy guidance |
| Location → Coarse Location | **Do not declare** | Only typed city/airport text, no device location |

Not collected: financial info, health, browsing history, search history, purchases, diagnostics
(add **Diagnostics → Crash Data** if Crashlytics or a similar tool is added later).

## 5. App Review information

- Sign-in required: **Yes**
- Contact: Tesfahun Kebede, tesfahunkebede336@gmail.com, phone ________
- Demo account: user name `________`, password **(you fill this in)**

Notes for the reviewer (paste this):

```
GuzoMy connects people who need items delivered with verified travelers flying the same route.

SIGN IN
Tap "Continue with Google" and use the demo account above. "Continue with Apple" also works
with any Apple ID, but new accounts must finish identity verification (Veriff) before they can
create offers or requests. The demo account is already verified, so reviewers can use every
feature without submitting an ID.

WHAT TO TRY
1. Pick Sender or Carrier mode (switch any time from the profile).
2. Home: browse offers (travelers) and requests (senders), and filter by airport or city.
3. Open an offer and send a match request, or create your own offer or request with "+".
4. Chat: open Messages to talk with a matched user. The camera/photo library is used to
   attach item photos.
5. Account deletion: Profile → Close account.

PERMISSIONS
Camera / microphone / photo library: identity verification (Veriff) and item photos at
pickup, delivery and in chat. Notifications: new proposals, matches and delivery updates.

The app does not process payments. Prices are arranged between users.
```

## 6. Version 1.0: "What's New"

See `metadata/<locale>/release_notes.txt`. Apple hides this field on the first version, so it is used from 1.0.1 onward.

## 7. Screenshots

The device family is iPhone only (`TARGETED_DEVICE_FAMILY = 1`), so no iPad screenshots are needed.

| Size | Pixels | Required |
|---|---|---|
| 6.9" | 1320×2868 (or 1290×2796) | **Yes** (Apple scales it down for smaller iPhones) |
| 6.5" | 1242×2688 | Only if you don't provide 6.9" |

Use the shot list in `android/fastlane/PLAY_STORE_LISTING.md` §3. Capture them from an iPhone 17 Pro Max simulator
(native 1320×2868).
