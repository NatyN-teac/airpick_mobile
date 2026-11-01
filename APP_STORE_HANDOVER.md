# Handover: GuzoMy — Apple App Store setup

Paste everything below the line into a new Claude Code session opened in
`/Users/pompidou/Documents/Masresha/airpick_mobile`.

---

I need you to set up GuzoMy for the Apple App Store: App Store Connect listing, signing, an archive build, and TestFlight. The Google Play side is already done in a previous session; reuse its work wherever it fits. Confirm with me before anything that publishes, submits for review, accepts agreements, or changes my Apple account settings. I'll type any passwords and handle 2FA myself.

## The app

- **GuzoMy**, a Flutter app for peer-to-peer airport delivery. Senders are matched with verified travelers ("carriers") flying the same route. Features: Sender/Carrier modes, offers and requests, proposals, matching, real-time chat (STOMP), push notifications (FCM), photo confirmation at pickup, identity verification with the Veriff SDK, and 4 languages (en, am, fr, ar).
- Publisher: **Merkavah Labs, LLC**. Contact email: tesfahunkebede336@gmail.com. Website (also used as privacy policy and account-deletion URL): https://www.airdashapp.com/
- Repo branch: `Nate-fix`. It has about 31 uncommitted changes from the rebrand (Airpick → GuzoMy) and the Play setup. Don't commit unless I ask.

## Current iOS state (verified)

- Bundle ID **`com.guzomy.app`**, team **`G97KQK66N6`**, automatic signing, display name "GuzoMy", MARKETING_VERSION 1.0, build 1.
- `TARGETED_DEVICE_FAMILY = "1,2"`: **iPad is enabled**, so App Store Connect will require iPad screenshots. Ask me whether to keep iPad support or go iPhone-only.
- Deployment target mismatch: project `IPHONEOS_DEPLOYMENT_TARGET = 13.0`, but `ios/Podfile` says `platform :ios, '15.0'`. Align them (15.0 is probably right; check the Veriff and Firebase minimums).
- `ios/Runner/Runner.entitlements`: Sign in with Apple, plus `aps-environment = development`. Distribution builds need production push; check that the archive's provisioning profile handles this.
- `Info.plist` background mode is `remote-notification`. Usage strings exist for camera, microphone and photo library. **The camera string only mentions Veriff, but the camera is also used to photograph items at pickup**, so update it before App Review.
- Google Sign-In on iOS: the URL scheme in `ios/Runner/Info.plist` is already updated to the new iOS client (`com.googleusercontent.apps.960865698662-i3a66gps1eluqh5p7kr929mhtfvgubs0`).
- Login on iOS offers both Google and Apple (`lib/src/features/auth/screens/auth_screen.dart`). Because Google sign-in exists, Apple requires Sign in with Apple too, and it's already there.
- Xcode 26.2 is installed.

## Firebase (project `airpick-a022d`)

- An iOS app for `com.guzomy.app` was registered by `flutterfire configure` (app ID `1:960865698662:ios:1b189df310dd896d183ea7`). `ios/Runner/GoogleService-Info.plist` and `lib/firebase_options.dart` are regenerated; both are git-ignored.
- **Still to do for iOS:**
  1. Upload an **APNs auth key (.p8)** under Firebase → Project settings → Cloud Messaging for the iOS app; otherwise push won't work.
  2. Enable **Sign in with Apple** on the `com.guzomy.app` App ID in the Apple Developer portal, and check that the Apple provider in Firebase Auth is configured.
- The Firebase CLI is logged in (`firebase` command works), and `flutterfire` is installed.

## Known issues to fix or flag before review

1. **Backend URL:** `lib/main.dart:68` sets `AppEnvironment.dev`, which points to `https://airdash-155736728726.us-east4.run.app`. The `prod` value (`api.airpick.app`) is a placeholder marked "replace when live". Ask me which one ships.
2. **No in-app report/block for users.** The app has user-to-user chat; Apple guideline 1.2 requires reporting, blocking and a way to act on objectionable content. This is likely to be rejected unless it's added.
3. **airdashapp.com has no privacy policy or account-deletion page** and is branded Air-Dash. Apple requires a working privacy policy URL, and in-app account deletion (the app has Profile → Close account, which is good).
4. The App Store screenshots I have show iPhone frames (fine for Apple). They're the originals, 925×2000; Apple needs exact sizes (6.9" 1320×2868 or 1290×2796, and 6.5" 1242×2688). Source images are in the previous session; ask me for them again, or capture new ones from the iOS Simulator.

## Reusable from the Play setup

- Store copy in 4 languages: `android/fastlane/metadata/android/{en-US,fr-FR,ar,am}/` (title, short/full description, release notes). Adapt for Apple:
  - **Name** ≤ 30 chars: "GuzoMy: Send with Travelers"
  - **Subtitle** ≤ 30 chars (new; write one)
  - **Promotional text** ≤ 170
  - **Description** ≤ 4000; remove the `<b>` tags, since Apple doesn't render HTML
  - **Keywords** ≤ 100 chars, comma-separated, no spaces (new)
  - **What's New**
  - Apple doesn't list Amharic as a store localization, so skip it or map it to English.
- `android/fastlane/PLAY_STORE_LISTING.md` has the data inventory used for Play Data safety. Reuse it for Apple's **App Privacy** labels: name, email, user ID, phone (optional), government ID/photos/video via Veriff, in-app messages, user content (offers and requests), and a device push token. No tracking, no ads, no advertising ID.
- Content rating answers used on Play: unmoderated user chat; no violence, sex, drugs, gambling or location sharing; target audience 18+. Apple's age rating will probably come out at 12+ or 17+ because of the unrestricted user communication.
- App icon: `assets/logo_icon_ios.png` (1024px, opaque, already used by `flutter_launcher_icons`).

## What I want from this session

1. Fix the project-level iOS issues (deployment target, camera usage string), confirming with me first.
2. Walk me through or do the Apple Developer portal steps: App ID capabilities (Sign in with Apple, Push), APNs key for Firebase.
3. Create the app in App Store Connect (I'll confirm before creation) and fill in the listing, App Privacy, age rating, category (Travel), and review notes with demo account instructions. Leave the password field for me.
4. Build and upload: `flutter build ipa --release`, then upload via Xcode Organizer or Transporter. Verify the bundle ID and signing before upload.
5. Set up TestFlight internal testing for tesfahunkebede336@gmail.com.
6. Stop before **Submit for Review** and give me a checklist of anything still blocking approval.

Browser work: the App Store Connect / Apple Developer pages need me signed in; I'll sign in when you open them.
