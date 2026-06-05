# Airpick Flutter App — Session Context

## What this app is
Peer-to-peer luggage/package delivery marketplace. Travelers (carriers) carry items for senders between airports. Think "human courier network". Old reference project lives at `/Users/nate/Documents/airdash`.

Working directory: `/Users/nate/Documents/airpick_mobile/airpick`

---

## Tech stack
- Flutter (SDK ^3.11.5), Dart
- **State management**: `flutter_bloc` — BLoC for auth/app/onboarding, Cubit for simpler features (nav, settings, create-offer flow)
- Firebase Auth + Google/Apple sign-in
- Dio HTTP client (single `ApiClient` instance, singleton via `RepositoryProvider`)
- SharedPreferences + FlutterSecureStorage
- Manrope font family throughout
- Full dark/light mode support (`AppColors` has both sets)
- Localization: ARB-based (`lib/l10n/app_en.arb`, `lib/l10n/app_am.arb`), code-generated via `flutter gen-l10n`. English values filled, Amharic keys present (empty values = future work). Always use `AppLocalizations.of(context)!.keyName` — never hardcode strings.

---

## API
- Base URL defined once: `AppConfig.apiBaseUrl = '$baseUrl/api/v1'`  
- Dev: `https://48aa-209-127-211-232.ngrok-free.app/api/v1` (ngrok, changes periodically)
- Prod: `https://api.airpick.app/api/v1`
- All repository paths are relative to base, e.g. `/airports`, `/flights`, `/offers`
- Single `ApiClient` (Dio) instance, auth token injected via `AuthInterceptor`
- Response shape: ALL endpoints use `content` as the response key — airports `content: [...]`, flights `content: {...}`, items `content: [...]`. The `data` key does NOT exist on this backend. Always read from `content`.
- Exception: `POST /items` (create item) returns `data: {...}` — confirmed by API spec.

---

## Project structure
```
lib/
├── main.dart                          # App entry, MultiRepositoryProvider, MultiBlocProvider
├── l10n/
│   ├── app_en.arb                     # English strings (source of truth)
│   ├── app_am.arb                     # Amharic (keys only, empty values)
│   └── app_localizations*.dart        # Generated — do not hand-edit
└── src/
    ├── app/
    │   ├── bloc/app_bloc.dart         # AppStarted → routes to onboarding/auth/home
    │   └── view/app_router.dart       # Routing logic
    ├── core/
    │   ├── config/app_config.dart     # API base URL, environment enum
    │   ├── network/api_client.dart    # Single Dio instance, get/post helpers
    │   ├── network/auth_interceptor.dart
    │   ├── storage/token_storage.dart # JWT via FlutterSecureStorage
    │   ├── theme/app_colors.dart      # All colors incl. dark mode variants
    │   ├── theme/app_theme.dart
    │   └── theme/app_typography.dart
    └── features/
        ├── airports/
        │   ├── models/airport.dart    # id, name, iataCode (maps from API field "code"), city, country, active
        │   └── repository/airport_repository.dart  # GET /airports, in-memory cache (_cache field), singleton in main.dart
        ├── auth/                      # Firebase auth, Google/Apple sign-in, BLoC pattern
        ├── flights/
        │   ├── models/flight_models.dart   # FlightType (oneWay/roundTrip), FlightLegRequest/Response, CreateFlightRequest, FlightResponse
        │   ├── repository/flight_repository.dart  # POST /flights — singleton registered in main.dart
        │   └── cubit/
        │       ├── create_flight_cubit.dart   # Standalone Cubit — setters for all form fields + submit() → POST /flights
        │       └── create_flight_state.dart   # CreateFlightStatus (initial/loading/success/failure), all form fields, isValid getter
        ├── home/
        │   ├── cubit/nav_cubit.dart        # Bottom nav tab index
        │   ├── screens/home_screen.dart    # Main home with carrier cards, engagements, in-delivery sections
        │   ├── screens/carrier_offer_detail_screen.dart  # Detail view for a carrier offer
        │   └── widgets/
        │       ├── app_nav_bar.dart        # 5-tab nav (Home, Chat, +, Alerts, Profile). Plus button has GlobalKey (plusKey) for bubble positioning
        │       └── home_app_bar.dart
        ├── offers/
        │   ├── models/offer_models.dart    # UrgencyLevel, PaymentMethod, OfferItemRequest, CreateOfferRequest
        │   ├── repository/offer_repository.dart   # POST /offers — singleton in main.dart DI
        │   ├── cubit/create_offer_cubit.dart      # Cubit managing full create-offer flow
        │   ├── cubit/create_offer_state.dart      # State with all form fields
        │   └── widgets/
        │       ├── create_offer_bubble.dart    # Bottle-shaped popup shown via showGeneralDialog
        │       ├── flight_form_step.dart       # Step 1: flight creation form
        │       ├── offer_form_step.dart        # Step 2: offer details form
        │       └── form_widgets.dart           # FormLabel, FormTextField, AirportPicker, DateTimeTile
        ├── onboarding/                # 3-page onboarding, BLoC, SharedPreferences flag
        └── settings/                  # ThemeCubit, LocaleCubit
```

---

## Home screen (`home_screen.dart`) — key design decisions
- **Dual mode**: Sender / Carrier (currently hardcoded to Sender; `_UserMode` enum with TODO to wire to profile)
- **Sections** (top to bottom):
  1. Greeting + mode pill
  2. In delivery — horizontal scrollable cards (status, progress bar, route)
  3. Engagements — **fixed height 88px, vertically scrollable** (shows ~1.5 cards as hint)
  4. Available carriers — vertical list of `_CarrierOfferCard`
- **Carrier card layout** (top to bottom):
  - Header: avatar column (gradient initial + "Verified" chip below avatar) | name + "View details →" (blue, `AppColors.info`) on same row | rating row below
  - Route strip: white background, compact (13px IATA codes, 9px city names)
  - Price row: "Starting from" label | `$X.XX / unit · up to N capacity · N slots` all inline | Match button (primary gradient, wider) right-aligned
- **Match button**: no shadow (intentional — felt detached with shadow)
- **View details** opens `CarrierOfferDetailScreen` pushed via `Navigator.push`
- **Price unit is dynamic** — `_CarrierOffer` has `priceUnit` and `capacityUnit` strings (not always "kg")

---

## Create Offer bubble — key design decisions
- Triggered by `+` button in `AppNavBar`
- `AppNavBar` exposes `GlobalKey? plusKey` — wrapped around the + Container for position lookup
- `showCreateOfferBubble()` uses `RenderBox.localToGlobal` to get button position, then `showGeneralDialog` (NOT OverlayEntry — OverlayEntry caused date pickers to render behind bubble)
- Bubble shape: **bottle shape** drawn with `CustomPainter` — rounded rect body + shoulder cubic beziers + straight neck (52px wide = button diameter) + semicircle cap
- Position: `top = buttonTopY - _totalH + 52` so the close button centre aligns exactly with the + button centre (creates illusion they're one button)
- Close button: 44px circle, `AppColors.primary` background, white × icon, centred in bottle cap
- `barrierDismissible: false` — only the close button dismisses
- Animation: `ScaleTransition` from `Alignment.bottomCenter` + `FadeTransition`
- Localizations: use `Localizations(locale: locale, delegates: AppLocalizations.localizationsDelegates, ...)` wrapper (NOT `Localizations.override`) — avoids async reload null window

---

## Create Offer flow (Cubit-based, NOT full BLoC with events)
**`CreateOfferCubit`** manages a two-step flow in one state object:

### Step 1 — Flight
- `flightType`: ONE_WAY or ROUND_TRIP
- `fromAirport` / `toAirport`: selected from live-filtered airport list
- Departure + arrival date/time
- **Round trip Option B**: `returnFromAirport` auto-fills = `toAirport` when user sets `toAirport`; `returnToAirport` auto-fills = `fromAirport` when user sets `fromAirport`. Both are independently editable via `setReturnFromAirport` / `setReturnToAirport`
- On "Continue": prints payload to console (`[CreateOfferCubit] flight payload: ...`), calls `POST /flights`, on success stores `flightId` and advances to step 2

### Step 2 — Offer
- pickupArea, deliveryArea, urgencyLevel (NORMAL/EXPRESS), discount, specialNote
- meetupPlaces (add/remove list)
- paymentMethods multi-select (CASH, ZELLE)
- items list (itemId, quantity, pricePerItem)
- On submit: calls `POST /offers` with stored `flightId`

---

## Airports loading
- `AirportRepository` is a **singleton** registered in `main.dart`'s `MultiRepositoryProvider`
- Has in-memory `_cache` — first load fetches from API, subsequent calls return instantly
- API field is `code` not `iataCode` — `Airport.fromJson` handles both: `json['iataCode'] ?? json['code']`
- API response uses `content` array (not `data`): `response['content'] as List<dynamic>`
- **Planned (approved, not yet implemented)**: persist to `SharedPreferences` on first load, prefetch during onboarding so bubble opens instantly even after app restart

---

## Localization workflow
1. Add keys + English values to `lib/l10n/app_en.arb`
2. Add same keys with empty values to `lib/l10n/app_am.arb`  
3. Run `flutter gen-l10n` — regenerates `app_localizations*.dart`
4. Use `AppLocalizations.of(context)!.keyName` in widgets

---

## Design rules (established in this session)
- Font: **Manrope** everywhere, no exceptions
- Primary color: `AppColors.primary` = `#E35335` (red-orange)
- Info/link color: `AppColors.info` = `#4299E1` (blue) — used for "View details" links to distinguish from primary CTAs
- No shadows on buttons that are part of a card (Match button has no shadow)
- All l10n strings through ARB — never hardcode UI text
- Comments: only when WHY is non-obvious; no docstrings

---

## Pending / next steps
1. **Airport local cache (SharedPreferences)** — approved plan:
   - Create `AirportLocalStorage` wrapping SharedPreferences
   - Update `AirportRepository` to check disk cache before API
   - Prefetch in `OnboardingScreen.initState()`
2. **Sender mode** for create offer bubble (currently carrier only)
3. **Real data** for home screen (currently all mock data)
4. Other tabs: Chat, Alerts, Profile (currently placeholder screens)
5. Search screen (`search_screen.dart`) exists but is empty

---

## Flight creation integration (active path: offer bubble)

**How the Continue button fires POST /flights:**
1. User taps `+` → `_HomeViewState._openCreateOffer()` calls `showCreateOfferBubble()`
2. `showCreateOfferBubble` reads `FlightRepository` and `OfferRepository` from DI via `context.read<>()`
3. `CreateOfferCubit` is scoped locally to the bubble via `BlocProvider`
4. User fills flight form → Continue button (`flight_form_step.dart:279`) calls `cubit.createFlight()`
5. `CreateOfferCubit.createFlight()` builds `CreateFlightRequest` → `FlightRepository.createFlight()` → `POST /api/v1/flights`
6. On success: `flightId` stored in state, bubble advances to Step 2 (offer form)

**DI registrations in `main.dart`** (`MultiRepositoryProvider`):
- `AirportRepository` — singleton, in-memory cache
- `FlightRepository` — singleton
- `OfferRepository` — singleton
- All three are read via `context.read<T>()` in `home_screen.dart`

**Standalone `CreateFlightCubit`** (`flights/cubit/`) — NOT used by the offer bubble.
Reserved for future screens where a user creates a flight independently (no offer attached).
Provide it locally: `BlocProvider(create: (ctx) => CreateFlightCubit(ctx.read<FlightRepository>()))`.

---

## Items feature (`features/items/`)

**Models** (`items/models/item_models.dart`):
- `ItemCategory` enum: `beauty, clothing, documents, electronics, food` → `BEAUTY, CLOTHING, ...`
- `MeasurementType` enum: `liquid, solidPiece, solidWeight` → `LIQUID, SOLID_PIECE, SOLID_WEIGHT`
- `MeasurementUnit` enum: `milliliter, piece, kilogram` → `MILLILITER, PIECE, KILOGRAM`
- Each `ItemCategory` has a `.defaultMeasurement` → `(MeasurementType, MeasurementUnit)` pair (auto-fills on custom item creation)
- `ItemModel`: id, name, category, measurementType, measurementUnit, isApproved

**Repository** (`items/repository/item_repository.dart`):
- `fetchItems()` → `GET /api/v1/items` — response uses `data` array (not `content`)
- `createItem(name, category, measurementType, measurementUnit)` → `POST /api/v1/items` — response uses `data` object
- In-memory `_cache` — same pattern as AirportRepository
- Registered as singleton in `main.dart`

---

## Offer form (Step 2) — updated UI

**Pickup / Delivery area**: Free text, hint format: `"e.g. New York, NY"` (City, State or Country)

**Urgency level**: Dropdown (`_FormDropdown<UrgencyLevel>`) — NORMAL or EXPRESS

**Payment methods**: Multi-select toggle chips — CASH and ZELLE (tap to toggle, multiple allowed)

**Meetup places**: Predefined dropdown with options: Cafe, Airport, Public Park, Hotel, Gas Station, Other.
- Tapping "Add meetup place" shows `_MeetupPickerDialog`
- "Other" triggers `_CustomMeetupDialog` for free text entry
- Selected places shown as dismissible chips above the add button
- Stored as `List<String>` in state (meetupPlaces)

**Items**: 
- `CreateOfferCubit.loadItems()` fetches available items on bubble open
- "Add Item" button opens `showItemPickerDialog` (full Dialog, 75% screen height)
- Picker shows items grouped by category with search; tap any item to select it
- "Can't find it? Add custom" → in-dialog create form (name + category dropdown; measurement auto-filled)
- Custom item creation calls `cubit.createAndSelectItem(name, category)` → `POST /api/v1/items`
- Selected items shown as expandable rows with item name, unit, qty input, price input, remove button
- `OfferItemDraft` now holds `item: ItemModel` (not a raw itemId string)
- `offerFormValid` now requires `items.isNotEmpty` in addition to pickupArea, deliveryArea, paymentMethods

**`CreateOfferCubit` constructor now requires `ItemRepository items`**

---

## Offer form — UI updates (post-items pass)

**Urgency dropdown**: Uses `DropdownButtonFormField` with the same `InputDecoration` as `FormTextField` (identical border, fill, padding, font size — pixel-perfect match).

**Payment methods**: Horizontally scrollable `SingleChildScrollView` + `Row` of toggle chips. Full list (from airdash reference):
Cash · CashApp · Zelle · Venmo · PayPal · Apple Pay · Google Pay · Wise · Revolut · Western Union · MoneyGram.
API values: CASH, CASHAPP, ZELLE, VENMO, PAYPAL, APPLE_PAY, GOOGLE_PAY, WISE, REVOLUT, WESTERN_UNION, MONEYGRAM.

**Item picker**: Items are visible by default grouped by category — no search required. Search field filters the visible list when typed into (empty query = show all).

---

## Offer form — final pass

**Currency** (`Currency` enum in `offer_models.dart`): 13 currencies covering North America (USD, CAD), EU/UK (EUR, GBP), Middle East (AED, SAR, KWD, QAR, BHD, OMR, JOD), Asia (CNY), Africa (ETB). Dropdown after meetup places. Included in `CreateOfferRequest.toJson()` as `currency: currency.apiValue`.

**Items — multi-select picker**: `showItemPickerDialog` now returns `Future<List<ItemModel>>`. Items show checkboxes; tapping toggles. Done button (with count) is disabled until ≥1 selected. `cubit.addItems(List<ItemModel>)` deduplicates by item ID.

**Items list**: Fixed height `SizedBox(height: 192)` — shows 2 cards, rest scrollable. Each card shows red border when price or quantity is 0 (validation hint).

**Total price bar**: Appears above items list when items exist. Shows `Total  $X.XX USD` when all items have price+qty, else shows a warning. Uses `state.totalPrice` (fold over `pricePerItem × quantity`) and `state.currency.symbol/apiValue`.

**`offerFormValid`**: Now also requires `items.every((d) => d.quantity > 0 && d.pricePerItem > 0)`.

**Success screen**: `_BubbleContent` uses `AnimatedSwitcher` (fade + slide) to transition from form to `_SuccessScreen` when `state.offerCreated == true`. `_SuccessScreen` is a StatefulWidget with:
- Elastic checkmark scale-in (`TweenAnimationBuilder`, `Curves.elasticOut`)
- 3-second countdown ring (`_CountdownRing` resets per tick via `ValueKey(countdown)`)
- Auto-dismisses bubble after 3 seconds via recursive `_tick()`
- User can dismiss early by tapping the close button

---

## Offer form — corrections pass

**UrgencyLevel** updated: `urgent | flexible | normal` → API values `URGENT`, `FLEXIBLE`, `NORMAL`. Old `express` removed.

**`isManuallyCreated`** added to `ItemModel` (optional, `false` by default). Parsed from `json['isManuallyCreated'] as bool? ?? false`. Present on custom-created items returned by `POST /api/v1/items`.

**Custom item creation flow** (item picker):
- After successful create: item is prepended to `availableItems` (appears at top of list), auto-selected (`_selectedIds.add(item.id)`), dialog returns to list view (not closed)
- User sees the newly created item at the top, already checked, then taps Done

**`hasManualItem`** in `CreateOfferRequest`:
- Computed in cubit: `state.items.any((d) => d.item.isManuallyCreated)`
- Included in `toJson()` only when `true`: `if (hasManualItem) 'hasManualItem': true`
- `POST /api/v1/items` response uses `data` key (not `content`) — confirmed by API spec

---

## User mode (Sender / Carrier)

**`UserModeCubit`** (`features/home/cubit/user_mode_cubit.dart`):
- `UserMode` enum: `sender | carrier`
- Extensions: `.label` (Sender/Carrier), `.pillLabel` (Sender mode/Carrier mode), `.description`
- Default: `UserMode.sender`
- Provided by `HomeScreen` via `MultiBlocProvider` alongside `NavCubit`

**Mode pill** (`_ModePill` in `home_screen.dart`):
- Tappable — shows `_ModePickerDialog` via `showDialog`
- Has a small chevron-down icon to indicate interactivity
- Rebuilds via `BlocBuilder<UserModeCubit, UserMode>` inside `_HomeTabState`

**Mode picker dialog** (`_ModePickerDialog`):
- Scale-in entrance via `TweenAnimationBuilder` (`Curves.easeOutBack`, 320ms)
- Two side-by-side cards (`_ModeCard`): Sender (inventory icon) and Carrier (flight icon)
- Active card: primary border + tinted bg + animated "Active" checkmark label
- Tapping a card calls `UserModeCubit.setMode()` and pops the dialog

**+ button behavior**:
- Carrier mode → `showCreateOfferBubble()` (existing offer creation flow)
- Sender mode → SnackBar "coming soon" (offer request flow not yet implemented)

**`_HomeTab` content** changes based on mode:
- Sender: section title "Available carriers", shows `_CarrierOfferList`
- Carrier: section title "Offer requests", shows `_OfferRequestList`

---

## Offer Requests feature (`features/offer_requests/`) — Sender flow

Mirror of the offer (carrier) flow, but for senders. Same bottle bubble, same item picker.

**Endpoint**: `POST /api/v1/offer-requests` — response under `data` key (NOT `content`, unlike items/flights GET).

**Shared bubble shell** (`offers/widgets/airpick_bubble_shell.dart`):
- Extracted the bottle-shaped bubble (layout, painter, close button) into reusable `showAirpickBubble(context, plusKey, contentBuilder)`.
- Also holds shared `BubbleSuccessScreen` (elastic check + 3s countdown ring auto-dismiss) used by BOTH offer and offer-request bubbles.
- `create_offer_bubble.dart` was refactored to use this shared shell (dropped its private `_BubbleLayout/_BubbleShell/_BubblePainter/_SuccessScreen`).

**Models** (`offer_requests/models/offer_request_models.dart`):
- `CreateOfferRequestRequest`: sourceCountry, sourceCity, destinationCountry, preferredDate (yyyy-MM-dd), urgencyLevel, specialNote?, partialProposalAccepted, items [{itemId, quantity}], hasManualItem (only emitted when true)
- `OfferRequestResponse`: id, shipperId, status (OPEN | PENDING_ITEM_APPROVAL | CLOSED), proposalCount, hasManualItem, items, etc. Has `urgencyLabel`/`statusLabel` display helpers.

**Cubits**:
- `CreateOfferRequestCubit` (`cubit/create_offer_request_cubit.dart`): manages the form. Loads items, createAndSelectItem (prepends new manual item to top), addItems (dedup by id), updateQuantity, submit. Computes `hasManualItem` from `items.any((d) => d.item.isManuallyCreated)`. Offer-request items have quantity ONLY (no price).
- `OfferRequestsCubit` (`cubit/offer_requests_cubit.dart`): holds the list shown on tab 2. `prepend(response)` adds optimistically to the TOP and sets `latestId` for entrance animation, clearing it after 1.8s. Provided at `HomeScreen` level.

**Bubble** (`offer_requests/widgets/create_offer_request_bubble.dart`): `showCreateOfferRequestBubble(context, plusKey, items, offerRequests, onCreated)`. Form fields: From (city+country), To (country), preferred date, urgency dropdown, partial-proposal toggle switch, multi-select items with +/- quantity steppers, special note. On success → `onCreated(response)` then shared success screen.

**Tab 2 screen** (`offer_requests/screens/offer_requests_screen.dart`): `OfferRequestsScreen` reads `OfferRequestsCubit`. Empty state with icon when no requests; otherwise a list of `_OfferRequestCard`s. Newly prepended card (matching `latestId`) animates in with slide-down + fade (`_AnimatedCard`). Card shows route, date, urgency badge, status chip, item count, partial badge, proposal count.

**Item picker refactor** (`offers/widgets/item_picker_dialog.dart`): now CUBIT-AGNOSTIC. `showItemPickerDialog` takes plain params (`availableItems`, `isLoading`, `itemsError`, `onRetry`, `onCreate`) instead of a specific cubit, so both `CreateOfferCubit` and `CreateOfferRequestCubit` reuse it. Callers must have items already loaded (both cubits call `loadItems()` on bubble open).

**Home wiring** (`home_screen.dart`):
- `OfferRequestsCubit` added to HomeScreen MultiBlocProvider.
- Tab index 2 now renders `OfferRequestsScreen` (was placeholder).
- `_onPlusTap`: switches to tab 2 first, then — carrier mode → offer bubble; sender mode → offer-request bubble with `onCreated: (r) => context.read<OfferRequestsCubit>().prepend(r)`.

**DI** (`main.dart`): `OfferRequestRepository` registered as singleton.

---

## Countries feature (`features/countries/`) — searchable country dropdown

Senders must pick a country from the supported list (no free text) on the offer-request form.

**Endpoint**: `GET /api/v1/countries` (JWT). Spec documents `data`, but backend may wrap under `content` (like items GET) — `CountryRepository.fetchCountries()` reads `response['content'] ?? response['data']` defensively, caches in-memory, sorts alphabetically.

**Model** (`countries/models/country.dart`): `Country { id, name, countryCode }`. `.flag` getter derives the flag emoji from the 2-letter ISO `countryCode` (regional-indicator code points).

**Widget** (`countries/widgets/country_picker_field.dart`): `CountryPickerField` — same inline-dropdown pattern as `AirportPicker`. Type to filter by name or code; focus with empty text shows first 8 as a dropdown. Shows flag + name + code rows, checkmark on selected, loading spinner while fetching. Constrains to supported list (free text not accepted — selection only). Sits inside the form's SingleChildScrollView so the suggestion list pushes content like AirportPicker.

**DI** (`main.dart`): `CountryRepository` registered as singleton.

**Offer-request integration**:
- State: `availableCountries`, `countriesLoading`, `countriesError`. `sourceCountry`/`destinationCountry` changed from `String` to `Country?`.
- Cubit: `loadCountries()` called on bubble open (`..loadItems()..loadCountries()`). Setters take `Country`. `submit()` sends `country.name` in the payload (`sourceCountry`/`destinationCountry` strings).
- Form: From = country picker + city field (stacked, full-width for dropdown room); To = destination country picker.
- `isValid` now checks `sourceCountry != null && destinationCountry != null`.

---

## Offer Requests — view / edit / delete

**Card tap → detail screen** (`offer_requests/screens/offer_request_detail_screen.dart`):
- `OfferRequestDetailScreen` shows route header (city, country → destination), status chip, **relative created time** ("2 days ago" via `OfferRequestResponse.createdAgo`), preferred date, urgency, partial-proposal flag, special note, and the full **items list** (name × quantity + unit).
- App-bar actions appear only when `request.canDelete` (`proposalCount == 0 && status not ACCEPTED/CANCELLED`): an **edit** icon and a **delete** icon. When not editable, a warning banner explains why.
- Pushed via `openOfferRequestDetail()` which wraps the route in `BlocProvider.value(OfferRequestsCubit)` so delete can update the list.

**Edit flow**:
- Edit icon pops the detail returning an `OfferRequestEditIntent(request)`. Home catches it (via `OfferRequestsScreen.onEdit`) and opens the **same bubble** anchored to the + button with `existing: request`.
- `CreateOfferRequestCubit.init({existing})` loads countries+items then `_seed()`s the form: matches countries by name, parses date/urgency, rebuilds item drafts (resolving each `OfferRequestItem` back to an `ItemModel` from the loaded list, or a minimal fallback).
- In edit mode: source/destination **country pickers are locked** (`CountryPickerField.locked` → disabled + lock icon) since the backend forbids changing them. City/date/urgency/partial/items/note remain editable. `_Field` is now stateful with a controller that syncs the async-seeded `initialValue` without clobbering typing.
- Submit branches: editing → `PATCH /offer-requests/:id` with `UpdateOfferRequestRequest` (omits source/dest country); creating → `POST`. Header reads "Edit Request", button "Save Changes", success "Request Updated!". `onSaved` → `OfferRequestsCubit.update()` (replace in place) vs `prepend()`.

**Delete flow**:
- Delete icon → `_DeleteConfirmDialog` → `OfferRequestRepository.deleteOfferRequest(id)` → `DELETE /offer-requests/:id` (204). On success: `OfferRequestsCubit.remove(id)` + pop + success snackbar. Errors (403/404/400 already-accepted) surface via snackbar.

**Model additions** (`offer_request_models.dart`):
- `OfferRequestItem` — parses response items defensively (nested `item{}` or flattened): itemId, name, quantity, measurementUnit. `OfferRequestResponse.items` is now `List<OfferRequestItem>` (+ `updatedAt`, `totalQuantity`, `canDelete`, `createdAgo`).
- `UpdateOfferRequestRequest` — all-optional PATCH body; emits only non-null keys; excludes source/dest country.

**ApiClient**: added `patch()` and `delete()` (204-safe); error map now includes 400.

**OfferRequestRepository**: `updateOfferRequest(id, req)` (PATCH), `deleteOfferRequest(id)`. Both create/update read `content ?? data`.

**Assumption**: update uses **PATCH** (partial, non-null-only semantics). If backend wants PUT, change the one call in `offer_request_repository.dart`.

---

## Mode framework + third-tab data fetch (app-wide)

**`UserModeCubit` is now APP-LEVEL** (main.dart MultiBlocProvider), so sender/carrier mode is consistent across the whole app. `OfferRequestsCubit` is also app-level now (takes `OfferRequestRepository`). HomeScreen only provides `NavCubit` locally.

**Third nav tab (index 2) is mode-aware** (home_screen IndexedStack): `BlocBuilder<UserModeCubit>` → sender shows `OfferRequestsScreen`, carrier shows `OffersScreen` (offers/screens/offers_screen.dart — empty-state placeholder until an offers/me endpoint exists).

**Offer requests fetched on init**: `GET /api/v1/offer-requests/me` via `OfferRequestRepository.fetchMyOfferRequests()` (reads `content ?? data`). `OfferRequestsScreen` is now stateful, calls `cubit.load()` in initState (idempotent via `_loadedOnce`; pull-to-refresh forces reload). States: loading spinner / error+retry / empty / list.

**Status filter** (`_StatusFilterBar`): horizontal gradient pill chips — All + OPEN/PENDING_ITEM_APPROVAL/PROPOSAL_RECEIVED/ACCEPTED/EXPIRED (labels via `offerRequestStatusLabel`). `OfferRequestsCubit.statusFilter` + `state.visible` getter filters client-side. Active chip = primary gradient + glow.

**`OfferRequestItem.fromJson`** now also reads `itemName` (the /me shape: id, itemId, itemName, category, measurementType, measurementUnit, quantity).

**Edit** stays the maintainable single-path: detail → `OfferRequestEditIntent` → home `_openRequestBubble(existing:)` → bubble `init(existing:)` seeds form (countries locked). Create vs edit branch only at submit + `onSaved` (prepend vs update).

---

## Offer request card actions (edit on card + swipe to delete)

- **Edit** moved from the detail screen to the **card itself**: a small edit icon sits under the status chip in the card header, shown only when `request.canDelete`. Tapping it → `onEdit(req)` → home `_openRequestBubble(existing:)` → bubble anchored to the + button (always the same spot).
- **Delete** is now **swipe-left** (`Dismissible`, endToStart) on the card, gated to `canDelete` items. Red "Delete" background; `confirmDismiss` shows `_DeleteConfirmDialog`, then calls `OfferRequestRepository.deleteOfferRequest`; on success `onDismissed` → `OfferRequestsCubit.remove` + snackbar; on API error the swipe snaps back with an error snackbar.
- **Detail screen is now view-only** (`OfferRequestDetailScreen` is Stateless): no edit/delete actions, no `OfferRequestEditIntent`. `openOfferRequestDetail(context, request)` just pushes it. Delete confirm dialog + repository import now live in `offer_requests_screen.dart`.

---

## Reference-data prefetch (items + countries)

`ItemRepository` and `CountryRepository` are app-level singletons that cache their lists in-memory (`_cache`). To avoid the create bubbles waiting on the network, both caches are **warmed once at startup** in `_HomeViewState.initState` (after auth, so the JWT exists): `context.read<ItemRepository>().fetchItems().ignore()` + same for countries. The cubits' `loadItems()/loadCountries()` then read straight from cache (no extra network call) as long as the cache is populated. Cache lives for the app session; restart re-fetches.
