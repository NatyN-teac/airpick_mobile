# GuzoMy: Google Play Console setup

Store text and graphics are in `metadata/android/<locale>/` (fastlane `supply` layout).
You can paste them into the Play Console by hand, or upload them with
`fastlane supply --skip_upload_apk --skip_upload_aab`.

| Locale | Title | Short | Full | Release notes |
|---|---|---|---|---|
| en-US (default) | 27/30 | 72/80 | ~2040/4000 | 247/500 |
| fr-FR | 28/30 | 70/80 | ~2120/4000 | 227/500 |
| ar | 25/30 | 65/80 | ~1500/4000 | 172/500 |
| am | 17/30 | 54/80 | ~1250/4000 | 136/500 |

> The Amharic and Arabic text were machine-drafted. Have a native speaker review them before you publish.

---

## 1. App details (Create app)

| Field | Value |
|---|---|
| App name | GuzoMy: Send with Travelers |
| Package name | `com.guzomy.app` |
| Default language | English (United States), en-US |
| App or game | App |
| Free or paid | Free |

## 2. Store settings

| Field | Value |
|---|---|
| Category | **Travel & Local** (alternative: Lifestyle) |
| Tags (up to 5) | Travel, Shipping & delivery, Peer-to-peer, Community, Travel planning |
| Contact email | `support@guzomy.com` ← **replace with a real, monitored inbox** |
| Website | `https://guzomy.com` ← **replace if different** |
| Phone | Optional |

## 3. Graphics

| Asset | Spec | File |
|---|---|---|
| App icon | 512×512 PNG, ≤1 MB | `en-US/images/icon.png` ✅ |
| Feature graphic | 1024×500 PNG/JPG | `en-US/images/featureGraphic.png` ✅ |
| Phone screenshots | 2–8, 9:16, min 1080px on the short side | `en-US/images/phoneScreenshots/` ❌ **to do** |
| 7"/10" tablet screenshots | Optional | — |

Suggested phone screenshots, in order, each with a short caption:
1. Onboarding / home: "Send with travelers. Earn as you fly."
2. Mode selection (Sender / Carrier): "Switch roles anytime"
3. Browse offers on a route: "Find travelers on your route"
4. Offer detail with price per item: "Compare prices and meetup points"
5. Identity verification: "Verified members only"
6. Chat with pickup/delivery actions: "Chat and coordinate the handoff"
7. Delivery tracking: "Track every delivery"
8. Language screen: "English · አማርኛ · Français · العربية"

## 4. App content (Policy section)

### Privacy policy
Play requires a public URL. The app currently links to a Google Doc
(`lib/src/features/auth/screens/auth_screen.dart:251`). That works, but a page on your own domain
(for example `https://guzomy.com/privacy`) is strongly recommended.

### App access
**All or some functionality is restricted.** Sign-in is required, and on Android the only option is Google.
Give reviewers:
- A Google test account (email and password) that is already signed up in GuzoMy
- Ideally, mark that account as **already identity-verified** on the backend so reviewers can
  create offers and requests without going through Veriff
- Instructions such as: "Tap Continue with Google → use the account above → choose Sender or
  Carrier mode → browse offers/requests from the Home tab."

### Ads
**No, my app does not contain ads.**

### Content rating (IARC questionnaire)
- Category: **All other app types**
- Violence, sexuality, language, controlled substances, gambling: **No**
- Users can interact or exchange content: **Yes** (in-app chat between matched users)
- Shares user location with other users: **No** (only city/airport text entered by the user)
- Allows digital purchases: **No**
- Expected result: **Everyone / PEGI 3**, with the "Users Interact" note

### Target audience
- Age groups: **18 and over** (the app handles identity verification, ID documents, and meetups with strangers)
- Appeals to children: **No**

### News app
No.

### Data safety
Data is encrypted in transit: **Yes** (HTTPS/WSS).
Users can request data deletion: **Yes**. In-app: Profile → Close account. Play **also requires a web URL**
where users can request deletion without the app (for example `https://guzomy.com/delete-account`).

| Data type | Collected | Shared | Purpose | Optional? |
|---|---|---|---|---|
| Name | Yes | No | Account management, App functionality | Required |
| Email address | Yes | No | Account management | Required |
| Phone number | Yes | No | App functionality (third-party receiver contact) | Optional |
| User IDs | Yes | No | Account management | Required |
| Photos | Yes | No | App functionality (item photos at pickup, receiver ID upload) | Optional |
| Messages (in-app) | Yes | No | App functionality | Optional |
| Government ID / identity verification | Yes | **Yes, Veriff** (service provider) | Fraud prevention, security | Required to post |
| Device or other IDs | Yes | No | App functionality (push notifications, FCM token) | Required |
| Crash logs / diagnostics | Only if you add Crashlytics or similar | — | — | — |

> Note: data sent to a service provider that processes it on your behalf (Veriff, Firebase) usually does
> **not** count as "sharing" under Play's definitions. Check Veriff's own Play Data safety guidance and
> declare to match.

### Permissions declarations
- `CAMERA`: item photos at pickup, ID capture during verification
- `RECORD_AUDIO`: used by the Veriff SDK during the liveness/video check. If your Veriff flow does not
  record audio, remove this permission to avoid extra review questions.
- `POST_NOTIFICATIONS`: match, proposal, and delivery updates

### Government apps / Financial features / Health
Not applicable. For **Financial features**, choose "My app doesn't provide any financial features",
since prices and payments are arranged between users and the app doesn't process payments.

---

## 5. Blockers to fix before the first production upload

1. **Release signing**: `android/app/build.gradle.kts` still signs release builds with the **debug key**.
   Create an upload keystore, add a `key.properties`-based `signingConfig`, and enroll in Play App Signing.
2. **API base URL**: `lib/src/core/config/app_config.dart` still references `api.airpick.app` and an ngrok
   URL. Make sure the release build points to the production backend.
3. **Phone screenshots**: none have been captured yet (see section 3).
4. **Support email, website, and account-deletion URL** must exist and be live.
5. **Google Sign-In for release**: add the **Play App Signing SHA-1/SHA-256** (from Play Console →
   App integrity) to the Firebase Android app, then download a fresh `google-services.json`. Otherwise,
   sign-in will fail for users who install from Play.
6. **Closed testing requirement**: new personal developer accounts must run a closed test with
   **at least 12 testers for 14 days** before applying for production access.
7. Build the bundle: `flutter build appbundle --release` → `build/app/outputs/bundle/release/app-release.aab`.
