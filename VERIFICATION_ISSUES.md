# Identity Verification — Issues Found in Testing

Testing of the in-house verification flow against the dev backend
(`https://airdash-155736728726.us-east4.run.app`), using a `SYS_ROLE` token,
the GuzoMy app (`feature/in-house-verification`) and the GuzoMy Admin app.

---

## 1. Backend bugs (need a fix)

### 1.1 Reviewer queue list always fails — blocking

`GET /api/v1/admin/verifications` returns **500 `SYS_001`** on every call:

| Request | Result |
|---|---|
| `GET /api/v1/admin/verifications` (no parameters) | 500 |
| `?view=pending` | 500 |
| `?view=past` | 500 |
| `?limit=20`, `?q=a`, `?documentType=PASSPORT`, `?suspiciousOnly=true`, `?status=declined&view=past` | 500 |

```json
{"success":false,"content":null,"errors":{"message":"An unexpected error occurred. Please try again later.","errorCode":"SYS_001","details":null}}
```

- There are 0 pending submissions, so it fails even when the result should
  be an empty list.
- `GET /summary` and `GET /reason-codes` work with the same token.
- **Impact:** the admin app's queue can't load, so nothing can be reviewed.
- **Possible cause (unconfirmed, no access to logs):** a nullable
  cursor/filter parameter in the query. Postgres can't infer the type of a
  `null` parameter in `:param IS NULL OR ...` conditions.

Reproduce:

```bash
curl -s -H "Authorization: Bearer <SYS_ROLE token>" "https://airdash-155736728726.us-east4.run.app/api/v1/admin/verifications?view=pending&limit=20"
```

### 1.2 Decision on an unknown submission returns 500 instead of 404

`POST /api/v1/admin/verifications/{unknown id}/decision` returns **500
`SYS_001`**. The guide says it should return `404 DATA_013`. `GET` on the same
unknown id correctly returns `404 DATA_013`.

```bash
curl -s -X POST -H "Authorization: Bearer <SYS_ROLE token>" -H "Content-Type: application/json" -d '{"decision":"RESUBMIT","reviewedByName":"API check","reasonCode":"BLURRY"}' "https://airdash-155736728726.us-east4.run.app/api/v1/admin/verifications/00000000-0000-0000-0000-000000000000/decision"
```

---

## 2. Backend questions (need an answer)

### 2.1 How do reviewers sign in?

- The token we were given is for `admin@airpick.com`. It works on the
  reviewer endpoints, but `GET /users/verification/status` returns
  `404 DATA_003 "User not found: admin@airpick.com"`, so that account has no
  user row.
- The API has no admin login endpoint.
- The admin app signs in the way the guide describes: Google → Firebase →
  `POST /users/register` → keep the account only if `role == SYS_ROLE`. So
  `admin@airpick.com` can't sign in through the app.
- **Question:** which Google accounts will have `SYS_ROLE`, and who sets that
  up?

### 2.2 Signing in to the admin app can create customer accounts

`POST /users/register` creates a new `CUSTOMER` account for any Google
account it hasn't seen. If someone who isn't a reviewer tries the admin app,
an account is created for them before the app turns them away. (Existing
accounts are not changed. Checked against a local copy of the backend code,
which may be older than what's deployed.)

**Question:** is that acceptable, or should there be a sign-in check that
doesn't create accounts?

### 2.3 Which field in reviewer pushes holds the submission id?

The guide lists the push `type` values (`VERIFICATION_SUBMITTED`,
`VERIFICATION_RESUBMITTED`, `VERIFICATION_OVERDUE`) but not the payload. The
admin app opens the request when a push is tapped, reading `submissionId`
(falling back to `refId`).

**Question:** what's the exact field name?

### 2.4 Photo retention

The guide says photos can be `purged` by an expiry job. The agreed rule was to
keep them for as long as the account exists.

**Question:** which is correct?

### 2.5 User-side response formats aren't in the API docs

The OpenAPI docs describe the reviewer responses in full, and every field
name matches the admin app. The user-side endpoints (`/users/verification/session`,
`/files`, `/submit`, `/status`) only declare an untyped `ApiResponseDto`, so
their field names can't be checked against the GuzoMy app.

**Request:** add typed response schemas for these four endpoints.

---

## 3. What has been verified

| Area | Status |
|---|---|
| `GET /admin/verifications/summary` | ✅ Works |
| `GET /admin/verifications/reason-codes` | ✅ Works; all 13 codes match the guide |
| `GET /admin/verifications/{id}` (unknown id) | ✅ Correct `404 DATA_013` |
| `GET /admin/verifications/{id}/files/{kind}/url` (unknown id) | ✅ Correct `404 DATA_013` |
| Reviewer response field names vs admin app | ✅ All match |
| Admin app on Android phone and iOS Simulator | ✅ Opens, signs in; queue blocked by 1.1 |
| GuzoMy Google sign-in on Android phone | ✅ Works |
| GuzoMy verification screens (demo data) | ✅ All screens and states work |
| Admin app screens (demo data) | ✅ Queue, detail, approve, new photos, "already decided" |

---

## 4. Not tested yet

- **The full flow end to end** (user submits → reviewer decides → user sees
  the result). Blocked by 1.1, and the GuzoMy build on the test phone still
  uses demo verification data.
- **Real camera capture** in the GuzoMy app (the camera-only fix is installed
  but not yet tried).
- **Push notifications** for users and reviewers.
- **Admin app screens not exercised**: decline, name/date-of-birth mismatch,
  filters, scrolling to load more, zoomed photo viewer, sign-out, expired
  session.

---

## 5. App-side to-dos before release

### GuzoMy app
- Replace the placeholder support email (`support@guzomy.app` in
  `lib/src/core/config/app_config.dart`).
- Have native speakers review the Amharic, Arabic and French verification
  text, and review the consent wording.
- Update the Play Store and App Store data-safety answers: Veriff and the
  microphone permission are gone.
- `test/widget_test.dart` was already failing before this work and still
  fails.

### GuzoMy Admin app
- Register the Android release signing key (SHA-1 and SHA-256) in Firebase.
- Upload an APNs key to Firebase and enable Push Notifications in Xcode, or
  iOS reviewers won't get pushes.
- Replace the default Flutter app icon and splash screen.
