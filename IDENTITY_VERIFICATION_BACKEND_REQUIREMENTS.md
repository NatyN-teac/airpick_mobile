# Identity Verification: Replace Veriff with Human Review

Backend requirements for `airpick_backendservice` (Spring Boot, Postgres, Flyway, GCS, FCM).

## 1. Summary

We are removing the Veriff integration. Identity verification will be done in-house by human reviewers using a **separate admin mobile app**, helped by automatic reading of the ID fields.

1. The GuzoMy user app captures photos of the ID document (front, and back where needed) and a selfie of the user holding the document.
2. The backend stores the files privately and adds the request to the review queue.
3. The backend reads the document fields automatically with **Google Cloud Vision** (name, date of birth, document number, expiry, nationality).
4. Every reviewer gets a push notification for each new request.
5. In the admin app, a reviewer opens the request, checks the photos, confirms or corrects the pre-filled fields, types their name, and records a decision.
6. The backend validates the confirmed fields, updates the user's verified flag, and notifies the user by push.

### Goals

- Keep the existing user-facing endpoints and status values so the user app's verification gate keeps working.
- Provide a separate, isolated API for the admin review app with its own accounts and login.
- Reduce reviewer typing by reading the document fields automatically.
- Keep a full history of every attempt, browsable by reviewers.
- Prevent one identity document from verifying more than one account.
- Record who decided every request, both the signed-in reviewer account and the name they type.
- Make every reviewer action auditable.
- Scale from 5 reviewers to many without redesign.

### Out of scope

- Automated face matching or liveness detection. The reviewer compares the selfie with the ID photo by eye.
- Automatic approval. Every request is decided by a person.
- The admin mobile app UI itself (this document defines the API it uses).
- Self-service admin account management (admin accounts are created by developers, see section 7.5).

---

## 2. Current implementation (to be replaced)

| Area | File / location |
|---|---|
| Session creation | `IdentityVerificationService.createSession` calls `VeriffClient.createSession` and stores `veriff_session_id` |
| Webhooks | `VeriffWebhookController` → `handleDecisionWebhook`, `handleEventWebhook` (HMAC via `VeriffHmacService`) |
| Status | `GET /api/v1/users/verification/status` reads `user_verifications` |
| Admin | `AdminVerificationController` (`SYS_ROLE` users): list, get by Veriff session id, `PATCH` free-text `overrideStatus` |
| Storage table | `user_verifications` (one row per profile, unique on `user_profile_id`) |

Known problems in the current code that the new design must fix:

- No attempt history: each new session overwrites the single row.
- Nothing prevents two concurrent sessions for the same user.
- The admin override accepts any string. Anything other than `approved`/`verified` is treated as denied, and the raw string is written as the status.

---

## 3. Status model

Status strings are lowercase and must stay exactly as below. The user app already understands them. `NOT_STARTED` (uppercase) is returned only when the user has no verification record.

| Status | Meaning | Set by |
|---|---|---|
| `NOT_STARTED` | No attempt yet, or verification was reset | default / system |
| `created` | Attempt created, nothing uploaded yet | user `POST /session` |
| `started` | At least one file uploaded | user file upload |
| `submitted` | All files uploaded, waiting in the review queue | user `POST /submit` |
| `review` | A reviewer has opened the request at least once | first time any reviewer opens the detail page |
| `approved` | Identity verified | reviewer decision |
| `declined` | Rejected (fraud, mismatch, expired document, etc.) | reviewer decision |
| `resubmission_requested` | Photos unusable (blurry, cut off); user should try again | reviewer decision |
| `expired` | Attempt not submitted within the session time limit | scheduled job |

### Allowed transitions

```
NOT_STARTED ─► created ─► started ─► submitted ─► review ─► approved
                 │           │           │          ├──► declined
                 └───────────┴──► expired│          └──► resubmission_requested
                                         └──► approved | declined | resubmission_requested
                                              (a reviewer may decide without the review step)

declined | resubmission_requested | expired ─► created   (new attempt, subject to limits)
approved ─► NOT_STARTED   (verified document has expired)
```

Any other transition MUST be rejected with `INVALID_STATUS_TRANSITION` (`BIZ_001`).

There is **no locking**: several reviewers can open the same request at the same time. The first decision wins; any later decision on the same attempt is rejected (section 8.5).

---

## 4. Data model

Add one Flyway migration: `V21__manual_identity_verification.sql`.

### 4.1 `verification_submissions` (new): one row per attempt

| Column | Type | Notes |
|---|---|---|
| `id` | UUID PK | `gen_random_uuid()` |
| `user_profile_id` | UUID FK → `user_profiles(id)` | not null |
| `status` | VARCHAR(50) | not null, values from section 3 |
| `attempt_no` | INT | not null, 1-based per user |
| `is_resubmission` | BOOLEAN | not null, default false. True when the user's previous attempt ended in `resubmission_requested` |
| `document_type` | VARCHAR(30) | not null: `PASSPORT`, `NATIONAL_ID`, `DRIVER_LICENSE`, `RESIDENCE_PERMIT` |
| `issuing_country` | VARCHAR(3) | ISO 3166-1 alpha-3 |
| `consent_version` | VARCHAR(20) | version of the consent text the user accepted |
| `consent_at` | TIMESTAMP | |
| `expires_at` | TIMESTAMP | not null, deadline to finish capture and submit |
| `submitted_at` | TIMESTAMP | |
| `suspicious` | BOOLEAN | not null, default false |
| `suspicious_reasons` | VARCHAR(200) | comma-separated: `REUSED_FILE`, `MRZ_CHECK_FAILED`, `DOCUMENT_TYPE_MISMATCH` |
| `first_opened_by` | UUID FK → `admin_accounts(id)` | first reviewer who opened it |
| `first_opened_at` | TIMESTAMP | |
| `decided_by` | UUID FK → `admin_accounts(id)` | signed-in reviewer who made the decision (automatic) |
| `reviewed_by_name` | VARCHAR(100) | name typed by the reviewer on the decision screen (required for every decision) |
| `decided_at` | TIMESTAMP | |
| `reason_code` | VARCHAR(50) | see section 9 |
| `reviewer_note` | TEXT | internal only, never returned to the user |
| `corrected_fields` | VARCHAR(200) | fields the reviewer changed from the automatic reading, e.g. `fullName,documentExpiry` (measures reading accuracy) |
| `overdue_alert_sent_at` | TIMESTAMP | set when the "waiting too long" alert has been sent for this attempt |
| `created_at` | TIMESTAMP | not null, default `now()` |
| `version` | BIGINT | not null, default 0, JPA `@Version` |

Indexes:

```sql
-- At most one open attempt per user, enforced by the database
CREATE UNIQUE INDEX uq_verification_open_submission
    ON verification_submissions (user_profile_id)
    WHERE status IN ('created', 'started', 'submitted', 'review');

-- Pending list (oldest first)
CREATE INDEX idx_verification_pending
    ON verification_submissions (submitted_at, id)
    WHERE status IN ('submitted', 'review');

-- Past list (most recent decision first)
CREATE INDEX idx_verification_decided
    ON verification_submissions (decided_at DESC, id DESC)
    WHERE decided_at IS NOT NULL;

CREATE INDEX idx_verification_user ON verification_submissions (user_profile_id, created_at DESC);
CREATE INDEX idx_verification_decided_by ON verification_submissions (decided_by);
```

### 4.2 `verification_files` (new): uploaded photos

| Column | Type | Notes |
|---|---|---|
| `id` | UUID PK | |
| `submission_id` | UUID FK → `verification_submissions(id)` ON DELETE CASCADE | not null |
| `kind` | VARCHAR(20) | `DOC_FRONT`, `DOC_BACK`, `SELFIE_WITH_DOC` |
| `object_path` | TEXT | GCS object path, not null |
| `content_type` | VARCHAR(100) | not null |
| `size_bytes` | BIGINT | not null |
| `sha256` | CHAR(64) | not null, hex |
| `uploaded_at` | TIMESTAMP | not null |
| `purged_at` | TIMESTAMP | set when the GCS object is deleted |

Constraints: `UNIQUE (submission_id, kind)`, index on `sha256`.

### 4.3 `verification_extractions` (new): fields read automatically from the document

One row per submitted attempt. Also acts as the work queue for the extraction worker (section 6).

| Column | Type | Notes |
|---|---|---|
| `submission_id` | UUID PK FK → `verification_submissions(id)` ON DELETE CASCADE | |
| `status` | VARCHAR(20) | not null: `PENDING`, `PROCESSING`, `COMPLETED`, `FAILED` |
| `attempts` | INT | not null, default 0 |
| `next_attempt_at` | TIMESTAMP | not null, default `now()` |
| `processing_started_at` | TIMESTAMP | used to recover stuck jobs |
| `engine` | VARCHAR(30) | `GOOGLE_VISION` |
| `source` | VARCHAR(10) | `MRZ` (passport machine-readable lines), `OCR` (printed text), `NONE` |
| `mrz_valid` | BOOLEAN | null when there is no MRZ; false when check digits fail |
| `detected_document_type` | VARCHAR(30) | what the document looks like, compared with what the user selected |
| `full_name` | TEXT | |
| `date_of_birth` | DATE | Gregorian |
| `nationality` | VARCHAR(3) | |
| `issuing_country` | VARCHAR(3) | |
| `document_number_enc` | TEXT | **encrypted** (section 4.4) |
| `document_expiry` | DATE | Gregorian |
| `original_calendar` | VARCHAR(12) | `GREGORIAN` or `ETHIOPIAN` (dates are always stored converted to Gregorian) |
| `field_confidence` | JSONB | e.g. `{"fullName":0.97,"dateOfBirth":0.62}` |
| `error_code` | VARCHAR(50) | on failure; no personal data |
| `completed_at` | TIMESTAMP | |

Index: `(status, next_attempt_at)`.

The raw OCR text returned by Cloud Vision MUST NOT be stored or logged. Only the parsed fields are kept.

### 4.4 `verified_identities` (new): confirmed data kept after approval

| Column | Type | Notes |
|---|---|---|
| `user_profile_id` | UUID PK FK → `user_profiles(id)` | |
| `submission_id` | UUID FK → `verification_submissions(id)` | the approving attempt |
| `full_name` | TEXT | as confirmed by the reviewer |
| `date_of_birth` | DATE | |
| `nationality` | VARCHAR(3) | |
| `document_type` | VARCHAR(30) | |
| `document_number_enc` | TEXT | encrypted |
| `document_expiry` | DATE | used by the re-verification job |
| `document_number_hmac` | CHAR(64) | **UNIQUE**, see section 8.6 |
| `verified_at` | TIMESTAMP | |

**Document number handling:**

- Stored only **encrypted** at application level (AES-256-GCM, key `VERIFICATION_FIELD_ENC_KEY` from Secret Manager), so reviewers can see it on the detail page.
- Duplicate detection uses the separate keyed hash (`document_number_hmac`), never the encrypted value.
- It MUST NOT appear in logs, audit details, push notifications, list responses or error messages.

### 4.5 `admin_accounts` (new): reviewer accounts, separate from app users

| Column | Type | Notes |
|---|---|---|
| `id` | UUID PK | |
| `email` | VARCHAR(255) | not null, unique, stored lowercase |
| `full_name` | VARCHAR(100) | not null, shown in the admin app as "decided by" |
| `password_hash` | VARCHAR(255) | not null, BCrypt (cost ≥ 12) or Argon2id |
| `role` | VARCHAR(40) | not null, `VERIFICATION_REVIEWER`. Stored as an enum so more roles can be added later |
| `is_active` | BOOLEAN | not null, default true |
| `must_change_password` | BOOLEAN | not null, default true |
| `failed_login_count` | INT | not null, default 0 |
| `locked_until` | TIMESTAMP | |
| `token_version` | INT | not null, default 0. Incremented to invalidate all tokens |
| `notify_new_requests` | BOOLEAN | not null, default true |
| `notify_overdue` | BOOLEAN | not null, default true |
| `last_login_at` | TIMESTAMP | |
| `created_at` | TIMESTAMP | not null, default `now()` |

Admin accounts are **not** rows in `users`. An admin account cannot sign in to the user API, and a user account cannot sign in to the review API.

### 4.6 `admin_refresh_tokens` (new)

| Column | Type | Notes |
|---|---|---|
| `id` | UUID PK | |
| `admin_account_id` | UUID FK → `admin_accounts(id)` ON DELETE CASCADE | |
| `token_hash` | CHAR(64) | SHA-256 of the refresh token, unique. The raw token is never stored |
| `device_name` | VARCHAR(100) | |
| `expires_at` | TIMESTAMP | not null |
| `revoked_at` | TIMESTAMP | |
| `replaced_by` | UUID | id of the token that replaced it on rotation |
| `created_at` | TIMESTAMP | not null |

### 4.7 `admin_devices` (new): FCM tokens of the admin app

Same shape as the existing `user_devices`, but linked to admin accounts:

| Column | Type | Notes |
|---|---|---|
| `id` | UUID PK | |
| `admin_account_id` | UUID FK → `admin_accounts(id)` ON DELETE CASCADE | |
| `fcm_token` | VARCHAR(512) | not null, unique |
| `platform` | VARCHAR(10) | `ios` / `android` |
| `device_name` | VARCHAR(100) | |
| `last_active` | TIMESTAMP | not null |
| `created_at` | TIMESTAMP | not null |

### 4.8 `verification_audit_log` (new)

| Column | Type | Notes |
|---|---|---|
| `id` | UUID PK | |
| `submission_id` | UUID FK, nullable | |
| `user_profile_id` | UUID FK, nullable | subject of the action |
| `actor_admin_id` | UUID FK → `admin_accounts(id)`, nullable | set for reviewer actions |
| `actor_user_id` | UUID FK → `users(id)`, nullable | set for app-user actions |
| `action` | VARCHAR(40) | `CREATED`, `FILE_UPLOADED`, `SUBMITTED`, `EXTRACTED`, `EXTRACTION_FAILED`, `OPENED`, `VIEWED_FILE`, `DECIDED`, `DECISION_REJECTED`, `USER_BLOCKED`, `EXPIRED`, `PURGED`, `RESET_DOCUMENT_EXPIRED`, `ADMIN_LOGIN`, `ADMIN_LOGIN_FAILED`, `ADMIN_LOCKED` |
| `detail` | TEXT | short JSON, no personal data or document numbers |
| `created_at` | TIMESTAMP | not null, default `now()` |

Both actor columns null means a system action. The audit log is append-only: no update or delete endpoints.

### 4.9 `user_verifications` (existing): current status per user

Keep this table as the user's **current** verification state (it is what `GET /status` reads). Add:

```sql
ALTER TABLE user_verifications
    ADD COLUMN current_submission_id UUID REFERENCES verification_submissions(id),
    ADD COLUMN reason_code           VARCHAR(50),
    ADD COLUMN decline_count         INT NOT NULL DEFAULT 0,
    ADD COLUMN last_declined_at      TIMESTAMP,
    ADD COLUMN verification_locked   BOOLEAN NOT NULL DEFAULT FALSE,
    ADD COLUMN verified_via          VARCHAR(20);   -- 'VERIFF' or 'MANUAL'
```

### 4.10 Existing Veriff data (part of V21)

Veriff is switched off in the same release (section 15), so the migration must:

1. **Keep Veriff-verified users verified.** Leave `user_profiles.verified = true` untouched and set `user_verifications.verified_via = 'VERIFF'` for them. They have no `verified_identities` row, so the duplicate-document check and the document-expiry job do not cover them. That is accepted.
2. **Reset unfinished Veriff attempts.** For users who are not verified and whose status is anything other than `NOT_STARTED`, `approved`, `declined`: set `status = 'NOT_STARTED'` and clear `verification_message`. These users start again with the new flow.
3. Keep `veriff_session_id` as history. Dropping it later is optional.

---

## 5. User API (GuzoMy user app)

All endpoints use the existing `ApiResponseDto` envelope and user JWT auth. Base path: `/api/v1/users/verification`.

### 5.1 `POST /session`: start or resume an attempt

**Request body** (required):

```json
{ "documentType": "PASSPORT", "issuingCountry": "ETH" }
```

**Rules, in order:**

1. If `documentType` is missing → 400 `APP_UPDATE_REQUIRED` with message **"Please update GuzoMy to the latest version to verify your identity."** The current (Veriff) app sends an empty body and shows the server's message when `success` is false, so users on the old app see this instead of a broken flow.
2. `documentType` must be one of `PASSPORT`, `NATIONAL_ID`, `DRIVER_LICENSE`, `RESIDENCE_PERMIT`.
3. If `user_profiles.verified = true` → 400 `USER_ALREADY_VERIFIED` (`BIZ_008`).
4. If `users.is_blocked = true` or `user_verifications.verification_locked = true` → 403 `VERIFICATION_LOCKED` with message "Please contact support".
5. If an open attempt exists in `created`/`started` and `expires_at > now` → return that attempt (200). The app resumes it. If the user picked a different document type, cancel the old attempt (status `expired`, files deleted) and create a new one.
6. If an open attempt is in `submitted`/`review` → 409 `VERIFICATION_IN_PROGRESS`.
7. If the last decision was a `declined` with a reason code that applies the cooldown (section 9) and `last_declined_at + verification.decline-cooldown > now` → 429 `VERIFICATION_COOLDOWN`, include `canRetryAt` in `errors.details`.
8. Create a `verification_submissions` row:
   - `status = created`, `attempt_no` = number of previous attempts + 1
   - `is_resubmission = true` if the user's previous attempt ended in `resubmission_requested`
   - `expires_at = now + verification.session-ttl`
9. Update `user_verifications`: `current_submission_id`, `status = created`, `verification_requested_at = now`; clear `is_denied`, `verification_message`, `reason_code`, `verified_at`. Create the row if it does not exist.
10. Audit `CREATED`.

**Response** `201` (new) or `200` (resumed):

```json
{
  "sessionId": "uuid",
  "status": "created",
  "expiresAt": "ISO-8601 timestamp",
  "documentType": "PASSPORT",
  "requiredFiles": ["DOC_FRONT", "SELFIE_WITH_DOC"],
  "uploadedFiles": []
}
```

`requiredFiles`:

| Document type | Required files |
|---|---|
| `PASSPORT` | `DOC_FRONT` (photo page), `SELFIE_WITH_DOC` |
| `NATIONAL_ID`, `DRIVER_LICENSE`, `RESIDENCE_PERMIT` | `DOC_FRONT`, `DOC_BACK`, `SELFIE_WITH_DOC` |

`sessionUrl` and `sessionToken` are removed from `VerificationSessionResponseDto`.

### 5.2 `POST /session/{sessionId}/files`: upload one photo

`multipart/form-data` with fields `kind` and `file`. Follow the same pattern as `MatchService.uploadPickupPhoto`.

**Rules:**

1. The attempt must belong to the caller. If not, return 404 `VERIFICATION_NOT_FOUND` (do not reveal that it exists).
2. Status must be `created` or `started` and `expires_at > now`. Otherwise 409 `VERIFICATION_SESSION_EXPIRED` or `INVALID_STATUS_TRANSITION`.
3. `kind` must be in the attempt's `requiredFiles`.
4. Content type `image/jpeg`, `image/png` or `image/webp` (the existing `GcsStorageService` allow-list). Validate by reading the file's magic bytes, not only the declared content type.
5. Size ≤ `verification.max-image-bytes`. Otherwise 400 `INVALID_FILE` (`UPL_001`). The existing 10 MB multipart limit is enough.
6. Stream to the verification bucket through a `DigestInputStream` to compute SHA-256 during upload. Object path:
   `verifications/{userProfileId}/{submissionId}/{kind}.{ext}`
7. If another user's `verification_files` row has the same `sha256`, mark the attempt suspicious with `REUSED_FILE`. Do not tell the user; the upload still succeeds.
8. If a file of the same `kind` already exists for this attempt, delete the old GCS object and replace the row (retakes are allowed).
9. Set status to `started` (if it was `created`) on both the attempt and `user_verifications`.
10. Audit `FILE_UPLOADED` (kind, size; no content).

**Response** `200`:

```json
{ "sessionId": "uuid", "status": "started", "uploadedFiles": ["DOC_FRONT"] }
```

### 5.3 `POST /session/{sessionId}/submit`: send for review

**Request body:**

```json
{ "consentVersion": "v1" }
```

**Rules:**

1. Owned by caller, status `started`, `expires_at > now`.
2. Every file in `requiredFiles` has a row. Otherwise 400 `VERIFICATION_FILES_MISSING` with the missing kinds in `errors.details`.
3. Set `status = submitted`, `submitted_at = now`, `consent_version`, `consent_at = now`.
4. Insert a `verification_extractions` row with `status = PENDING` (section 6).
5. Copy status to `user_verifications`.
6. Audit `SUBMITTED`.
7. **After commit**, notify reviewers (section 10): `VERIFICATION_RESUBMITTED` if `is_resubmission`, otherwise `VERIFICATION_SUBMITTED`. This must be asynchronous; a push failure must never fail the user's submit.

**Response** `200`: same shape as `GET /status`.

### 5.4 `GET /status`: current status (existing, modified)

`VerificationStatusResponseDto` becomes:

```json
{
  "status": "submitted",
  "isVerified": false,
  "isDenied": false,
  "isLocked": false,
  "reasonCode": null,
  "message": null,
  "sessionId": "uuid",
  "verificationRequestedAt": "ISO-8601",
  "verifiedAt": null,
  "canRetryAt": null
}
```

- `veriffSessionId` is removed and replaced by `sessionId`.
- `message` is a user-safe text derived from `reasonCode` (section 9). It is never the reviewer's internal note, and the user never sees the reviewer's name.

---

## 6. Automatic field extraction (Google Cloud Vision)

### 6.1 When it runs

- A `verification_extractions` row is created with `PENDING` when the user submits.
- A worker in the backend processes pending rows in the background. Reviewers are notified on submit and do not wait for extraction; the detail page shows "Reading document…" until it completes (usually seconds).
- Every attempt gets its own extraction, including resubmissions.

### 6.2 Worker

Runs every few seconds on every instance. It is safe to run on many Cloud Run instances at once because it claims rows with `SKIP LOCKED`:

```sql
SELECT submission_id FROM verification_extractions
 WHERE status = 'PENDING' AND next_attempt_at <= now()
 ORDER BY next_attempt_at
 LIMIT 10
 FOR UPDATE SKIP LOCKED;
-- then set status = 'PROCESSING', processing_started_at = now(), attempts = attempts + 1
```

- Rows stuck in `PROCESSING` longer than `verification.extraction-stuck-after` go back to `PENDING`.
- On a Cloud Vision error, set `PENDING` again with exponential backoff (`next_attempt_at`). After `verification.extraction-max-attempts`, set `FAILED`, set `error_code`, audit `EXTRACTION_FAILED`. The reviewer then fills the fields by hand.

### 6.3 Calling Cloud Vision

- Add the `google-cloud-vision` dependency and enable the Vision API in the Google Cloud project. Grant the backend service account access.
- Send the images by their `gs://` URI (no download and re-upload through the backend).
- Feature: `DOCUMENT_TEXT_DETECTION`.
- Language hints: `en` for passports; `en` and `am` (Amharic) for Ethiopian documents.
- Run it on `DOC_FRONT` and, when present, `DOC_BACK`. Never on the selfie.

### 6.4 Parsing

**Passport:**

1. Find the two 44-character MRZ lines (ICAO 9303, TD3 format) at the bottom of the photo page.
2. Parse surname, given names, nationality, date of birth, sex, document number, expiry and issuing country.
3. Validate all check digits (document number, date of birth, expiry, composite). If any fail, set `mrz_valid = false` and mark the attempt suspicious with `MRZ_CHECK_FAILED`.
4. `source = MRZ`.

**Residence permits and other ID cards with an MRZ** (TD1 format, 3 lines of 30 characters): same approach as passports.

**National ID, driver's license, and cards without an MRZ:**

1. Use label-based rules per document layout, in English and Amharic (e.g. "Date of Birth" / "የትውልድ ቀን", "Expiry" / "የሚያበቃበት ቀን").
2. Any field that cannot be read confidently is left null. The reviewer fills it.
3. `source = OCR`.

**Ethiopian calendar:** Ethiopian documents may print dates in the Ethiopian calendar. The parser must detect these and convert them to Gregorian before storing. Set `original_calendar = ETHIOPIAN`, and return both the converted date and the original text to the reviewer.

**Document type check:** if the document looks like a different type from what the user selected, set `detected_document_type` and mark the attempt suspicious with `DOCUMENT_TYPE_MISMATCH`.

**Confidence:** store a confidence per field (from Cloud Vision's word confidences, or 1.0 for MRZ fields with valid check digits). The admin app highlights fields below `verification.extraction-low-confidence`.

On success: `status = COMPLETED`, `completed_at = now`, audit `EXTRACTED` (source and which fields were found; no values).

### 6.5 Building the layout rules

The parsing rules for each non-passport document need real sample images. Collect consented test samples of each accepted document (Ethiopian national ID (Fayda), kebele ID if accepted, Ethiopian driver's license, residence permits) before implementing the rules. Track how often reviewers correct each field (`corrected_fields`) to improve them.

---

## 7. Review API: authentication and accounts

The admin app talks to a separate API under **`/api/v1/review/**`**. It has its own accounts, its own tokens and its own Spring `SecurityFilterChain` (`securityMatcher("/api/v1/review/**")`), separate from the user API.

The existing `SYS_ROLE` admin controllers (`/api/v1/admin/**`) are not affected, except `AdminVerificationController`, which is removed (section 15).

### 7.1 Tokens

- **Access token:** JWT signed with a **different secret** from user tokens (`REVIEW_JWT_SECRET`). Claims: `sub` (admin account id), `typ: "review"`, `role`, `tv` (token version). Lifetime: `review.access-token-ttl` (short).
- **Refresh token:** a random opaque value (≥ 32 bytes), stored only as a SHA-256 hash in `admin_refresh_tokens`. Lifetime: `review.refresh-token-ttl`. **Rotated on every use**: the old token is revoked and a new one issued. If a revoked token is presented again, revoke every refresh token of that account (token theft).
- On every request, the review filter checks the signature, `typ = review`, that the account is active, and that `tv` equals `admin_accounts.token_version`. A user-API token must fail on the review API and a review token must fail on the user API.
- The account lookup on each request may be cached briefly (e.g. 30 seconds).

### 7.2 `POST /api/v1/review/auth/login`

Public endpoint.

```json
{ "email": "reviewer@example.com", "password": "…", "deviceName": "Pixel 8" }
```

**Rules:**

1. Rate limit by IP and by email.
2. Look up by lowercase email. If not found, inactive, or wrong password → generic 401 `ADMIN_INVALID_CREDENTIALS`. A locked account returns 423 `ADMIN_ACCOUNT_LOCKED`. Always run the password hash check, even when the account doesn't exist, so response times don't reveal valid emails.
3. On a wrong password: increment `failed_login_count`. After `review.login-max-failures` failures, set `locked_until = now + review.lockout-duration` and audit `ADMIN_LOCKED`.
4. On success: reset `failed_login_count`, set `last_login_at`, audit `ADMIN_LOGIN`, issue an access and refresh token.

**Response:**

```json
{
  "accessToken": "…",
  "refreshToken": "…",
  "accessTokenExpiresIn": 900,
  "mustChangePassword": true,
  "admin": { "id": "uuid", "email": "…", "fullName": "…", "role": "VERIFICATION_REVIEWER" }
}
```

While `must_change_password = true`, every review endpoint except `change-password`, `logout` and `me` returns 403 `ADMIN_PASSWORD_CHANGE_REQUIRED`.

### 7.3 Other auth endpoints

| Endpoint | Logic |
|---|---|
| `POST /api/v1/review/auth/refresh` | Public. `{refreshToken}` → new access and refresh token (rotation as in 7.1). Invalid or expired → 401 `INVALID_REFRESH_TOKEN`. |
| `POST /api/v1/review/auth/logout` | Revokes the given refresh token and removes the FCM token sent in the body from `admin_devices`. |
| `POST /api/v1/review/auth/change-password` | `{currentPassword, newPassword}`. Minimum 12 characters, must differ from the current one. On success: new hash, `must_change_password = false`, increment `token_version`, revoke all refresh tokens, return a fresh token pair. |
| `GET /api/v1/review/me` | The signed-in admin's profile and notification preferences. |
| `PATCH /api/v1/review/me/preferences` | `{notifyNewRequests, notifyOverdue}`. |

### 7.4 Admin devices (push tokens)

| Endpoint | Logic |
|---|---|
| `POST /api/v1/review/devices` | `{fcmToken, platform, deviceName}`. Upsert by `fcm_token`. If the token belonged to another admin account, move it to the caller. |
| `DELETE /api/v1/review/devices` | `{fcmToken}`. Removes it. |

The admin app is in the **same Firebase project** as the user app, so the backend's existing Firebase credentials are used to send admin pushes.

### 7.5 Account provisioning (developers only)

There are no endpoints to create or manage admin accounts. Provide a small command-line tool inside the backend (e.g. a Spring `ApplicationRunner` that only runs under an `admin-cli` profile), runnable locally against the database or as a one-off Cloud Run job:

| Command | Effect |
|---|---|
| `create --email --name [--role]` | Creates an account with a random temporary password printed once, `must_change_password = true`. |
| `reset-password --email` | New random temporary password printed once, `must_change_password = true`, `token_version + 1`, refresh tokens revoked. |
| `disable --email` / `enable --email` | Sets `is_active`. Disabling also increments `token_version`, revokes refresh tokens and deletes the account's `admin_devices`. |
| `unlock --email` | Clears `locked_until` and `failed_login_count`. |
| `list` | Lists accounts (no hashes). |

Admin accounts are never deleted, only disabled, so past decisions keep a valid "decided by" reference.

---

## 8. Review API: verifications

Base path: `/api/v1/review/verifications`. Requires role `VERIFICATION_REVIEWER`.

### 8.1 `GET /summary`

Small, cheap endpoint for badges and the home screen:

```json
{ "pendingCount": 7, "overdueCount": 2, "oldestPendingSubmittedAt": "ISO-8601" }
```

### 8.2 `GET /`: list (current and past)

**Query parameters:**

| Param | Values | Notes |
|---|---|---|
| `view` | `pending` (default), `past` | `pending` = `submitted` + `review`. `past` = `approved`, `declined`, `resubmission_requested` |
| `status` | optional, one or more statuses | narrows the view |
| `q` | optional text | search by the requester's name or email (case-insensitive, partial) |
| `decidedBy` | optional admin account id | past view only |
| `documentType` | optional | |
| `suspiciousOnly` | optional boolean | |
| `cursor` | optional | opaque cursor from the previous page |
| `limit` | default 20, max 50 | |

**Sorting:**

- `pending`: `submitted_at` ascending (oldest first).
- `past`: `decided_at` descending (most recent first).

**Pagination:** use **cursor (keyset) pagination** on `(sort column, id)`, not page numbers, so lists stay fast as history grows and don't skip or repeat rows when new requests arrive. Return `nextCursor` (null on the last page).

**Search at scale:** enable the `pg_trgm` extension and add trigram indexes on the profile's first name, last name and the user's email.

**Each item:**

```json
{
  "submissionId": "uuid",
  "status": "submitted",
  "attemptNo": 2,
  "isResubmission": true,
  "documentType": "PASSPORT",
  "issuingCountry": "ETH",
  "submittedAt": "ISO-8601",
  "waitingMinutes": 42,
  "isOverdue": false,
  "suspicious": false,
  "extractionStatus": "COMPLETED",
  "requestedBy": {
    "userId": "uuid",
    "fullName": "…",
    "email": "…",
    "profilePhotoUrl": "short-lived signed URL or null"
  },
  "decision": {
    "decision": "APPROVE",
    "decidedAt": "ISO-8601",
    "decidedBy": { "adminId": "uuid", "fullName": "…" },
    "reviewedByName": "…",
    "reasonCode": null
  }
}
```

`decision` is null in the pending view. No document photo URLs or document numbers in the list.

### 8.3 `GET /{submissionId}`: detail page

**Response includes:**

- **Requester** (who asked for verification): user id, full name, email, phone, date of birth on profile, profile photo, rating, account creation time, and whether the account is blocked.
- **Submission:** status, attempt number, `isResubmission`, document type, issuing country, suspicious flag and reasons, submitted time, first opened by/at.
- **Photos:** for each kind, a signed read URL valid for `verification.reviewer-file-url-ttl` (add a `generateSignedReadUrl(objectPath, minutes)` overload in `GcsStorageService`; the existing one uses the general 15-minute setting). Photos with `purged_at` set are returned as `null` with `purged: true`.
- **Extracted fields** (section 6): status, source (`MRZ`/`OCR`), `mrzValid`, each field with its value and confidence, the decrypted document number, and for Ethiopian-calendar dates both the converted date and the original text. These pre-fill the decision form.
- **Profile comparison:** for name and date of birth, whether the extracted value matches the profile (so the app can highlight differences).
- **Decision** (if decided): decision, reason code, internal note, decided by (account), reviewed by (typed name), decided at, corrected fields.
- **Confirmed identity** (if approved): from `verified_identities`, including the decrypted document number.
- **History:** the user's previous attempts (status, reason code, decided by, reviewed by name, decided at), most recent first, each with its own `submissionId` so the app can open it.

**Side effects:**

- If status is `submitted`: set `status = review`, `first_opened_by`, `first_opened_at`, copy `review` to `user_verifications`, audit `OPENED`. Use a conditional update (`WHERE status = 'submitted'`) so concurrent opens are harmless.
- Audit `VIEWED_FILE` for each photo URL issued.

### 8.4 `GET /{submissionId}/files/{kind}/url`

Returns a fresh signed URL for one photo (used when the URL from the detail response has expired while the reviewer is still on the page). Audit `VIEWED_FILE`.

### 8.5 `POST /{submissionId}/decision`

Replaces the old `PATCH /api/v1/admin/verifications/{sessionId}` (`overrideStatus`).

**Request:**

```json
{
  "decision": "APPROVE",
  "reviewedByName": "Name typed by the reviewer",
  "reasonCode": null,
  "note": "internal note",
  "nameMismatchAcknowledged": false,
  "dobMismatchAcknowledged": false,
  "identity": {
    "fullName": "ABEBE KEBEDE",
    "dateOfBirth": "YYYY-MM-DD",
    "nationality": "ETH",
    "documentType": "PASSPORT",
    "documentNumber": "EP1234567",
    "documentExpiry": "YYYY-MM-DD"
  }
}
```

- `decision`: enum `APPROVE`, `DECLINE`, `RESUBMIT`.
- `reviewedByName`: **required for every decision**, 2–100 characters, trimmed. Stored as typed. The signed-in account is recorded separately and automatically in `decided_by`; the client cannot set it.
- `reasonCode`: required for `DECLINE`/`RESUBMIT`, must match the allowed decision in section 9. Must be null for `APPROVE`.
- `identity`: required for `APPROVE`, ignored otherwise. The admin app pre-fills it from the extracted fields; the reviewer confirms or corrects every field. All fields are required, all dates in Gregorian.

**Rules (single `@Transactional` method):**

1. Status must be `submitted` or `review`. If the attempt has already been decided → 409 `VERIFICATION_ALREADY_DECIDED`, with `errors.details` containing the existing decision, `decidedBy.fullName`, `reviewedByName` and `decidedAt`, so the app can tell the reviewer someone else got there first. Audit `DECISION_REJECTED`.
2. For `APPROVE`, validate the confirmed values on the server:
   - `documentExpiry` is at least `verification.min-document-validity-days` (3 months) after the current date. Fail → 422 `VERIFICATION_RULE_FAILED` with `details.rule = DOCUMENT_EXPIRING_SOON` (or `DOCUMENT_EXPIRED` if already expired).
   - Age from `dateOfBirth` ≥ `verification.min-age` (18). Fail → `details.rule = UNDERAGE`.
   - Name check: normalize both names (uppercase, strip accents and punctuation, split into words, sort words) and compare against the profile's first and last name. If they don't match and `nameMismatchAcknowledged` is not true → `details.rule = NAME_MISMATCH`. When acknowledged, `note` is required.
   - If `user_profiles.dob` is set and differs from `dateOfBirth` and `dobMismatchAcknowledged` is not true → `details.rule = DOB_MISMATCH`. When acknowledged, `note` is required.
   - Compute `document_number_hmac` (section 8.6). If it exists in `verified_identities` for a different profile → 409 `DUPLICATE_IDENTITY_DOCUMENT`. Approval is blocked; the reviewer should decline with `DUPLICATE_ACCOUNT`.
   - Compare the confirmed values with the extraction and record the names of changed fields in `corrected_fields`.
3. Write the decision with a **conditional update** so only the first decision can succeed, even when two reviewers submit at the same moment:

   ```sql
   UPDATE verification_submissions
      SET status = :newStatus, decided_by = :adminId, reviewed_by_name = :name,
          decided_at = now(), reason_code = :reason, reviewer_note = :note,
          corrected_fields = :corrected, version = version + 1
    WHERE id = :id AND status IN ('submitted', 'review');
   ```

   0 rows updated → step 1's 409 response.
4. Apply the rest of the decision in the same transaction:

   | Decision | Submission status | `user_verifications` | `user_profiles.verified` | Other |
   |---|---|---|---|---|
   | APPROVE | `approved` | status `approved`, `is_denied=false`, `verified_at=now`, `reason_code=null`, `verified_via='MANUAL'` | `true` | upsert `verified_identities` (number encrypted + HMAC) |
   | DECLINE | `declined` | status `declined`, `is_denied=true`, `verified_at=null`, `decline_count + 1`, `last_declined_at=now` | `false` | if `decline_count` reaches `verification.max-declines` → `verification_locked = true`; for `SUSPECTED_FRAUD` see below |
   | RESUBMIT | `resubmission_requested` | status `resubmission_requested`, `is_denied=false` | `false` | does not count toward the decline limit |

   In all cases, copy `verification_message` (user-facing text from section 9) and `reason_code` to `user_verifications`.

   **`SUSPECTED_FRAUD`:** also set `verification_locked = true` and **block the user account** (`users.is_blocked = true`, the existing block, so the user gets `USER_BLOCKED` / `AUTH_003` on their next request). Audit `USER_BLOCKED`. Unblocking is done by support through the existing admin tools.
5. Audit `DECIDED` (decision, reason code, reviewed by name; no identity data).
6. **After commit**, send the user push with the existing `NotificationService` methods (`notifyVerificationApproved`, `notifyVerificationDeclined`, `notifyVerificationResubmission`), passing the user-facing message, never the internal note or the reviewer's name. Use `@TransactionalEventListener(phase = AFTER_COMMIT)`.

**Response** `200`: the updated detail (same shape as 8.3).

### 8.6 Document number hash

```
normalized = uppercase(documentNumber) with spaces and dashes removed
input      = documentType + "|" + issuingCountry + "|" + normalized
hmac       = hex(HMAC-SHA256(VERIFICATION_DOC_HMAC_KEY, input))
```

- `VERIFICATION_DOC_HMAC_KEY` comes from Secret Manager, minimum 32 random bytes, and is different from `VERIFICATION_FIELD_ENC_KEY`.
- The key must never change once in use (changing it breaks duplicate detection). Document this in the deployment notes.

---

## 9. Reason codes

Store as a Java enum. The decision endpoint accepts only these values; there is no free-text reason shown to users. Expose the list through `GET /api/v1/review/verifications/reason-codes` so the admin app does not hard-code it.

| Code | Decision | 24h cooldown | User-facing message (EN) |
|---|---|---|---|
| `BLURRY` | RESUBMIT | no | Your photos were not clear enough. Please retake them in good light. |
| `GLARE` | RESUBMIT | no | There was glare on your document. Please avoid direct light and retake. |
| `DOCUMENT_CUT_OFF` | RESUBMIT | no | All four corners of your document must be visible. |
| `FACE_NOT_VISIBLE` | RESUBMIT | no | Your face was not clearly visible in the selfie. |
| `DOCUMENT_NOT_IN_SELFIE` | RESUBMIT | no | Please hold your document next to your face in the selfie. |
| `UNSUPPORTED_DOCUMENT` | DECLINE | no | This document type is not accepted. Please use a passport, national ID, driver's license or residence permit. |
| `DOCUMENT_EXPIRED` | DECLINE | no | Your document has expired. Please use a valid document. |
| `DOCUMENT_EXPIRING_SOON` | DECLINE | no | Your document must be valid for at least 3 more months. Please use another document. |
| `UNDERAGE` | DECLINE | yes | You must be 18 or older to use GuzoMy. |
| `NAME_MISMATCH` | DECLINE | yes | The name on your document does not match your profile. |
| `FACE_MISMATCH` | DECLINE | yes | We could not confirm that the document belongs to you. |
| `DUPLICATE_ACCOUNT` | DECLINE | yes | This document is already linked to another account. |
| `SUSPECTED_FRAUD` | DECLINE | n/a (account blocked) | We could not verify your identity. Please contact support. |

**Limits:**

- `verification.max-declines` = **3**. After the third decline the user cannot start another attempt (`verification_locked = true`) and must contact support.
- Resubmission requests and expired attempts do **not** count toward the limit.
- The cooldown (`verification.decline-cooldown` = **24 hours**) applies only to codes marked "yes". Document problems (expired, expiring, unsupported) can be fixed immediately with another document.

The user app shows localized text based on `reasonCode`; the English `message` is a fallback and is also used in the user push notification.

---

## 10. Reviewer push notifications

Create an `AdminNotificationService`, separate from the user `NotificationService`.

### 10.1 Notification types

| Type | When | Sent to | Title / body |
|---|---|---|---|
| `VERIFICATION_SUBMITTED` | Every user submit where `is_resubmission = false` | all active reviewers with `notify_new_requests = true` | "New verification request" / "A user is waiting for identity review." |
| `VERIFICATION_RESUBMITTED` | Every user submit where `is_resubmission = true` | same as above | "Verification resubmitted" / "A user sent new photos after a resubmission request." |
| `VERIFICATION_OVERDUE` | Scheduled job (section 11) | all active reviewers with `notify_overdue = true` | "Requests waiting too long" / "{n} verification requests have been waiting more than 24 hours." |

Data payload for every type: `{ "type": "...", "submissionId": "uuid" }` (no `submissionId` for `VERIFICATION_OVERDUE`). Tapping a submitted or resubmitted notification opens the detail page; tapping an overdue notification opens the pending list.

**Notification text MUST NOT contain the user's name, email or any document data**, because it can appear on a locked phone screen.

### 10.2 Delivery rules

- Send **after commit** and **asynchronously** (`@Async` or a queue), never inside the user's request.
- Collect the tokens from `admin_devices` joined to active accounts with the matching preference.
- Send with FCM `sendEachForMulticast` in batches of up to 500 tokens.
- Remove tokens that FCM reports as `UNREGISTERED` or `INVALID_ARGUMENT`.
- Retry transient FCM errors with backoff; give up after a few attempts and log the failure (without personal data).
- Android: use a dedicated notification channel id (e.g. `verification_requests`) with high priority. iOS: set `apns-priority: 10`.

---

## 11. Scheduled jobs

The service runs on Cloud Run and may have several instances. Each `@Scheduled` method would run on every instance. Use **ShedLock** (Postgres lock provider) or trigger the jobs from Cloud Scheduler through an internal, authenticated endpoint. The same concern applies to the existing `@Scheduled` job in `MatchService`. The extraction worker (section 6.2) is the exception: it is designed to run on every instance.

| Job | Frequency | Logic |
|---|---|---|
| Extraction worker | every few seconds | Section 6.2. |
| Expire abandoned attempts | every 5 min | `created`/`started` with `expires_at < now` → `expired`. Delete their GCS files, set `purged_at`. Update `user_verifications`. Audit `EXPIRED`. No push. |
| Overdue alert | hourly | Find `submitted`/`review` attempts where `submitted_at < now - verification.overdue-after` (24 hours) and `overdue_alert_sent_at IS NULL`. If any, send **one** `VERIFICATION_OVERDUE` push with the count, then set `overdue_alert_sent_at` on those attempts so each attempt triggers at most one alert. |
| Document expiry | daily | `verified_identities.document_expiry` before the current date → `user_profiles.verified=false`, `user_verifications.status=NOT_STARTED`, `reason_code=DOCUMENT_EXPIRED`. Push the user asking them to verify again. Audit `RESET_DOCUMENT_EXPIRED`. |
| Clean refresh tokens | daily | Delete expired or revoked rows in `admin_refresh_tokens`. |

---

## 12. Retention, security and privacy

### 12.1 Retention

- Photos of **submitted** attempts (decided or not) are kept **for as long as the user's account exists**, so reviewers can browse past verifications with their photos.
- Photos of attempts that **expired before submission** are deleted by the expiry job.
- When a user account is closed or deleted, delete all of the user's GCS verification objects, `verification_files`, `verification_extractions` and the `verified_identities` row. Keep audit rows and decision metadata, but remove personal data from them.
- The user app calls `POST /api/v1/users/{userId}/close`, which does not currently exist in the backend. This cleanup must be part of whatever account-closure flow is implemented.

### 12.2 Storage

- Use a **dedicated private bucket** for verification files (`VERIFICATION_STORAGE_BUCKET`), with uniform bucket-level access, no public access, and encryption at rest (customer-managed key preferred).
- Only the backend service account (and the Cloud Vision call made on its behalf) can read the bucket. No human IAM access to the bucket in production.
- Files are reachable only through short-lived signed URLs issued by the review API, and each issued URL is audited.
- Enable Cloud Audit Logs (data access) on the bucket.

### 12.3 Review API

- Separate accounts, separate tokens, separate filter chain (section 7).
- Login lockout, rate limiting, generic error messages, password minimum length 12, forced password change on first login.
- Disabling an admin account takes effect immediately (`token_version` check).
- Every login, open, photo view and decision is audited.

### 12.4 Logging

- `RequestLoggingFilter` must not log request or response bodies for `/api/v1/users/verification/**` and `/api/v1/review/**`.
- Never log passwords, tokens, document numbers, dates of birth, OCR text, file contents or signed URLs.

### 12.5 Consent

- Store `consent_version` and `consent_at` on submit. Keep a record of each consent text version.
- The consent text must say that ID photos are kept while the account exists and that they are processed by Google Cloud Vision to read the document details.

---

## 13. Configuration

Add to `application-*.properties` (all must be configurable):

| Property | Value |
|---|---|
| `verification.session-ttl` | `30m` |
| `verification.max-declines` | `3` |
| `verification.decline-cooldown` | `24h` |
| `verification.max-image-bytes` | `10MB` |
| `verification.min-age` | `18` |
| `verification.min-document-validity-days` | `90` |
| `verification.reviewer-file-url-ttl` | `5m` |
| `verification.overdue-after` | `24h` |
| `verification.extraction-max-attempts` | `3` |
| `verification.extraction-stuck-after` | `5m` |
| `verification.extraction-low-confidence` | `0.8` |
| `verification.storage-bucket` | env `VERIFICATION_STORAGE_BUCKET` |
| `verification.doc-hmac-key` | env `VERIFICATION_DOC_HMAC_KEY` |
| `verification.field-enc-key` | env `VERIFICATION_FIELD_ENC_KEY` |
| `review.jwt-secret` | env `REVIEW_JWT_SECRET` (different from the user JWT secret) |
| `review.access-token-ttl` | `15m` |
| `review.refresh-token-ttl` | `30d` |
| `review.login-max-failures` | `5` |
| `review.lockout-duration` | `15m` |

---

## 14. Error codes

Add to `ErrorCode` and map in `GlobalExceptionHandler` (use typed exceptions, not message string matching):

| Enum | Code | HTTP |
|---|---|---|
| `ADMIN_INVALID_CREDENTIALS` | `AUTH_005` | 401 |
| `ADMIN_ACCOUNT_LOCKED` | `AUTH_006` | 423 |
| `ADMIN_PASSWORD_CHANGE_REQUIRED` | `AUTH_007` | 403 |
| `INVALID_REFRESH_TOKEN` | `AUTH_008` | 401 |
| `VERIFICATION_NOT_FOUND` | `DATA_013` | 404 |
| `VERIFICATION_IN_PROGRESS` | `BIZ_010` | 409 |
| `VERIFICATION_LOCKED` | `BIZ_011` | 403 |
| `VERIFICATION_COOLDOWN` | `BIZ_012` | 429 |
| `VERIFICATION_SESSION_EXPIRED` | `BIZ_013` | 409 |
| `VERIFICATION_FILES_MISSING` | `BIZ_014` | 400 |
| `VERIFICATION_ALREADY_DECIDED` | `BIZ_015` | 409 |
| `DUPLICATE_IDENTITY_DOCUMENT` | `BIZ_016` | 409 |
| `VERIFICATION_RULE_FAILED` | `BIZ_017` | 422 |
| `APP_UPDATE_REQUIRED` | `BIZ_018` | 400 |

Existing codes reused: `USER_ALREADY_VERIFIED` (`BIZ_008`), `USER_BLOCKED` (`AUTH_003`), `INVALID_STATUS_TRANSITION` (`BIZ_001`), `INVALID_FILE` (`UPL_001`), `STORAGE_NOT_CONFIGURED` (`UPL_002`), `ACCESS_DENIED` (`ACL_001`).

---

## 15. Veriff removal (same release)

Veriff is switched off in the same release that adds the new flow. Remove:

- `integrations/veriff/` (`VeriffClient`, `VeriffSessionRequest`, `VeriffSessionResult`)
- `commons/security/VeriffHmacService.java`
- `commons/configs/VeriffProperties.java`
- `controllers/VeriffWebhookController.java`
- `controllers/admin/AdminVerificationController.java` (replaced by the review API)
- `SecurityConfig`: the `permitAll` for `/api/v1/webhooks/veriff/**`
- `RequestLoggingFilter`: the `/api/v1/webhooks/veriff` exclusion
- `GlobalExceptionHandler`: the two Veriff message mappings; `INVALID_WEBHOOK_SIGNATURE` if unused elsewhere
- `IdentityVerificationService`: `handleDecisionWebhook`, `handleEventWebhook`, `resolveVerification`, `validateWebhookSignature`, `listVerifications`, `overrideVerification`
- `UserVerificationRepository.findByVeriffSessionIdWithProfile`
- `veriff.*` properties in both profiles, and the `VERIFF_*` secrets in Cloud Run
- Swagger text in `VerificationController` that mentions Veriff
- The webhook URL in the Veriff dashboard, and the Veriff subscription once confirmed unused

Data handling for existing Veriff users and unfinished Veriff attempts is in section 4.10. Users on the old app version get `APP_UPDATE_REQUIRED` (section 5.1).

Related cleanup: `NotificationService` verification messages still say "Airpick"; the product name is now GuzoMy.

---

## 16. Rollout order

Because Veriff is switched off at once, the new user app must be ready the moment the backend changes:

1. Get the new user app and the admin app approved in the App Store and Play Store, but **hold the release** (manual release on iOS, unpublished or halted rollout on Android).
2. Create the reviewer accounts with the CLI (section 7.5).
3. Deploy the backend (migration V21, new endpoints, Veriff removed).
4. Immediately release both apps.
5. Reviewers sign in, change their password and register their devices.

Between steps 3 and 4, users on the old app see "Please update GuzoMy…" if they try to verify.

---

## 17. Scaling notes

The design is meant to work the same with 5 or many reviewers:

- **Stateless auth:** JWT access tokens, no server sessions; any Cloud Run instance can serve any request.
- **Keyset pagination and partial indexes** keep list queries fast as history grows.
- **Trigram indexes** keep name and email search fast.
- **Extraction queue with `SKIP LOCKED`** spreads document reading across all instances without double-processing.
- **FCM multicast in batches of 500** and automatic removal of dead tokens.
- **Asynchronous push sending** so notifications never slow down user requests.
- **Per-reviewer notification preferences** so large teams can limit who is alerted.
- **Role stored as an enum** on admin accounts, so roles such as a read-only auditor or a senior reviewer can be added later without schema changes.
- **First-decision-wins conditional update** keeps decisions correct without locking, regardless of how many reviewers are working at once.
- **ShedLock** for the other scheduled jobs across multiple instances.

---

## 18. Acceptance criteria

**User flow**

- [ ] A user can create an attempt, upload all required photos, submit, and see `submitted` from `GET /status`.
- [ ] A passport needs front + selfie; the other document types need front + back + selfie.
- [ ] Calling `POST /session` without `documentType` returns `APP_UPDATE_REQUIRED` with the update message.
- [ ] Calling `POST /session` while an unexpired `created`/`started` attempt exists returns the same attempt.
- [ ] A second open attempt for the same user is impossible, even under concurrent requests.
- [ ] Uploads with a wrong type, wrong magic bytes or over the size limit are rejected with `UPL_001`.
- [ ] A photo whose SHA-256 matches another user's photo marks the attempt suspicious.
- [ ] Submit fails with `BIZ_014` when a required photo is missing.
- [ ] Attempts not submitted within the session TTL become `expired` and their photos are deleted.
- [ ] After 3 declines the user cannot start a new attempt; resubmission requests don't count.
- [ ] After a decline with a cooldown code, a new attempt is refused for 24 hours; after `DOCUMENT_EXPIRED`, `DOCUMENT_EXPIRING_SOON` or `UNSUPPORTED_DOCUMENT` it is allowed immediately.

**Field extraction**

- [ ] Every submitted attempt gets an extraction row that reaches `COMPLETED` or `FAILED`.
- [ ] Passport MRZ fields are parsed and check digits validated; a failed check marks the attempt suspicious.
- [ ] Ethiopian-calendar dates are converted to Gregorian and the original text is shown to the reviewer.
- [ ] A Cloud Vision outage does not block reviewers: after retries the extraction is `FAILED` and the reviewer fills the fields by hand.
- [ ] Running several backend instances never processes the same extraction twice.
- [ ] Raw OCR text is never stored or logged.

**Admin accounts**

- [ ] Accounts can only be created, reset, disabled and unlocked through the CLI.
- [ ] A user-API token is rejected by the review API, and a review token is rejected by the user API.
- [ ] A new account must change its password before using any verification endpoint.
- [ ] Repeated wrong passwords lock the account; login errors do not reveal whether an email exists.
- [ ] Refresh tokens rotate on every use; reusing an old refresh token revokes all of that account's refresh tokens.
- [ ] Disabling an account blocks its existing tokens immediately and removes its devices.

**Review flow**

- [ ] Every active reviewer with notifications enabled receives a push for each new submission, with a different message for resubmissions.
- [ ] Push text contains no user name, email or document data.
- [ ] A failed push never fails the user's submit.
- [ ] Dead FCM tokens are removed automatically.
- [ ] The pending list shows `submitted` and `review` attempts oldest first; the past list shows decided attempts most recent first; both use cursor pagination.
- [ ] Search by name or email works on both lists.
- [ ] Opening a `submitted` attempt sets it to `review` and records the first reviewer who opened it.
- [ ] The detail page shows the requester's full profile, photos (signed URLs), extracted fields with confidence, decision, and previous attempts.
- [ ] Every decision requires a typed "reviewed by" name, and also records the signed-in account automatically.
- [ ] When two reviewers decide on the same attempt at the same time, exactly one succeeds; the other gets `BIZ_015` with who decided first.
- [ ] Approve fails when the document expires within 3 months, the user is under 18, or the document number is already verified on another account.
- [ ] Approve with a name or date-of-birth mismatch fails unless acknowledged with a note.
- [ ] Fields the reviewer changed from the extraction are recorded in `corrected_fields`.
- [ ] Approve sets `isVerified = true` in `GET /status` and sends the user push only after commit.
- [ ] `SUSPECTED_FRAUD` locks verification and blocks the user account.
- [ ] `reviewer_note` and the reviewer's name never appear in any user-facing response or push.
- [ ] Requests waiting more than 24 hours trigger one overdue alert per attempt.

**Data and security**

- [ ] Photos of submitted attempts remain viewable for past verifications while the user's account exists.
- [ ] Closing a user account deletes all of that user's verification photos, extractions and identity data.
- [ ] Document numbers are stored only encrypted and as an HMAC.
- [ ] Every login, open, photo view and decision has an audit row.
- [ ] No password, token, document number, date of birth, OCR text or signed URL appears in application logs.
- [ ] Scheduled jobs run once per interval across multiple Cloud Run instances.
- [ ] Users verified through Veriff remain verified after the migration, and unfinished Veriff attempts are reset to `NOT_STARTED`.

---

## 19. Open questions

1. Is the kebele ID accepted as a "national ID", or only the Fayda card?
2. Sample images (with consent) of each accepted document type are needed to build the field-reading rules. Who provides them?
3. Confirm that Google Cloud Vision's data-processing terms are acceptable for identity documents under the applicable data-protection law.
4. Should reviewers be able to revoke an existing approval from the admin app? (Not in the current feature list.)
5. Should approvals with an acknowledged name or date-of-birth mismatch require a second reviewer?
6. Who unblocks a user blocked for `SUSPECTED_FRAUD`, and with which tool?
7. Account closure endpoint (`POST /users/{userId}/close`) does not exist yet; who owns it?
