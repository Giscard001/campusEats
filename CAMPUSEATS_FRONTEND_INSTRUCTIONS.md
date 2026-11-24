# CampusEats : Flutter frontend instructions for Antigravity

> Written in English because it is meant to be read by the AI agent. All user-facing texts in the app are in **French**.
> Put this file at the root of the repo (or in `docs/`) and also copy section 2 ("Non-negotiable rules") into the workspace rules file used by Antigravity (e.g. `AGENTS.md` or the `.agent/rules` folder), so every agent session follows it.

---

## 0. How the team uses this file

1. Create the repo with the structure of section 4 (`app/` for Flutter, `api/` for the backend, `docs/`).
2. Export the Stitch designs and save them in `docs/designs/` named `S01-splash-login.png`, `S02-register.png`, etc. (the IDs `S01` to `S19` are listed in section 9 and match the Stitch prompts 1 to 19). If Stitch gives HTML/CSS exports, put them in `docs/designs/html/`.
3. In Antigravity, open the repo and send **the master prompt (section 12.0)**, then **one phase prompt at a time** (12.1 to 12.6). Do not send everything at once.
4. After each phase: run the checks of section 13, review the code as a team, open a small pull request. **Every member must be able to explain the code that was generated** (project rule: code you cannot explain is forbidden and graded individually).

---

## 1. Product context (what we are building)

CampusEats is a mobile app (Android, portrait) for a school canteen in Burkina Faso. Today students queue at lunch, canteen staff serve plates and students sign on paper. The app removes the queue:

- The student sees the menu of the day, orders a meal and picks a pickup slot. The server generates a **daily meal QR code**.
- At lunch (13:00 to 14:00) the student shows the QR code. Canteen staff scan it. The scan marks the meal as collected (one use only).
- **No payment in the app.** Some students are *boursiers* (scholarship, free canteen, verified against an official list kept by the server). Others pay a monthly subscription **physically**; the admin or canteen staff then record the number of months in the app by scanning the student's **permanent identity QR code**.
- A student can order only if they are a verified boursier or have an active subscription on the meal date.

Three roles in **one single app**: `student`, `staff` (canteen staff), `admin`. The UI adapts to the role after login.

Business rules the UI must reflect (the server enforces them, the UI only displays them and handles the errors):

- Slots: 13:00-13:15, 13:15-13:30, 13:30-13:45, 13:45-14:00, each with a capacity.
- Orders and cancellations close at **10:00** on the meal day. Orders for future days are allowed.
- One meal per student per day.
- Order status: `received` -> `preparing` -> `ready` -> `collected`, or `cancelled`.
- Meal QR scan results: valid, already used, expired, no order today, subscription expired.

---

## 2. Non-negotiable rules (copy this section into the agent rules)

1. **Stack**: Flutter (current stable), Dart null-safe, `flutter_bloc` for ALL application state (Bloc or Cubit). No Provider, Riverpod, GetX, MobX, setState for business state. `setState` only for purely visual local state (e.g. a text field obscure toggle).
2. **Clean Architecture, feature-first.** Each feature has `domain/`, `data/`, `presentation/`. The **domain layer is pure Dart**: it imports neither Flutter nor Dio nor any storage package.
3. **No business logic in widgets.** Widgets only dispatch events and render states.
4. **Repository contracts** (abstract classes) live in `domain/`. Implementations live in `data/`. Exceptions are caught **once, at the data border** and mapped to `Failure` objects, returned as `Result<T>` (own sealed class, see 8.1). Blocs never see `DioException`.
5. **Dependency injection** with `get_it`, in a **single composition root** (`lib/core/di/injection.dart`). No `GetIt.I` calls scattered in widgets except in the route builders that provide blocs.
6. **Navigation** with `go_router`, declarative, with a **redirect guard** driven by the `AuthBloc` state and the user's role/status (section 6).
7. **Tokens** (access + refresh) in `flutter_secure_storage`. **Automatic and concurrency-safe refresh**: if 3 requests fail with 401 at the same time, only ONE refresh call is made, the others wait for it, then retry (section 8.3).
8. **Every screen that loads data** has four distinct states: **loading** (skeleton), **empty**, **error with a "Réessayer" button**, **content**. Model them in the bloc state (sealed classes or a status enum), not with booleans scattered around.
9. **At least one optimistic update with rollback** and **at least one deliberate event transformer** (debounce, droppable, restartable, sequential), documented in a comment above the handler (section 9 lists where).
10. **Cache then network** for the main lists: the last known data is visible when the app starts **offline** (section 8.4).
11. **Forms** are validated on the client AND server validation errors (HTTP 422) are displayed **next to the right field**.
12. **API URL from configuration**: `--dart-define=API_BASE_URL=...`. Never hard-coded.
13. `flutter analyze` must be clean (`flutter_lints` or stricter), code formatted (`dart format`). No `print`, use a logger.
14. **Tests**: a `bloc_test` for every bloc/cubit that contains logic, covering the **success and the failure path**. Use `mocktail` for mocks.
15. All UI strings in **French**. Dates and numbers localised with `intl` (`fr_FR`). Timezone is UTC+0 (Burkina Faso), but always compute the "cutoff" from **server time** (section 8.5).
16. **No secrets in the repository.** No API keys in source. `google-services.json` is added by the team following the instructions in phase 5.
17. Keep pull requests small: one phase = several small commits/PRs, one feature per PR. Add a short comment on non-obvious code (the team must be able to explain everything).
18. Do not invent endpoints or fields: use the API contract of section 7. If something is missing, **add it to a "Questions for the API team" list in `docs/frontend-questions.md`** and continue with a mock.

---

## 3. Packages

```yaml
dependencies:
  flutter_bloc: ^latest
  bloc_concurrency: ^latest      # droppable(), restartable(), sequential()
  equatable: ^latest
  get_it: ^latest
  go_router: ^latest
  dio: ^latest
  flutter_secure_storage: ^latest
  hive_ce: ^latest               # local cache (+ hive_ce_flutter)
  hive_ce_flutter: ^latest
  connectivity_plus: ^latest
  intl: ^latest
  qr_flutter: ^latest            # display QR codes
  mobile_scanner: ^latest        # scan QR codes
  cached_network_image: ^latest  # dish photos
  fl_chart: ^latest              # admin charts
  file_picker: ^latest           # CSV import (admin)
  image_picker: ^latest          # dish photo (admin)
  firebase_core: ^latest         # phase 5 only
  firebase_messaging: ^latest    # phase 5 only
  flutter_local_notifications: ^latest  # phase 5, foreground display
  logger: ^latest

dev_dependencies:
  flutter_test:
    sdk: flutter
  bloc_test: ^latest
  mocktail: ^latest
  flutter_lints: ^latest
```

Always use the latest compatible versions (`flutter pub add`). Bundle the fonts **Poppins** and **Inter** as assets (do not rely on runtime download: the app must look right offline).

---

## 4. Project structure

```
project-root/
  api/                      # backend (other team members)
  app/
    lib/
      main.dart
      app.dart              # MaterialApp.router, theme, global blocs
      core/
        config/             # AppConfig (dart-define), Env
        di/                 # injection.dart (composition root)
        error/              # Failure, Result
        network/            # dio_client.dart, auth_interceptor.dart, error_mapper.dart
        storage/            # secure_token_storage.dart, cache_store.dart (Hive)
        router/             # app_router.dart, route_names.dart, guards
        theme/              # app_theme.dart, colors.dart, text_styles.dart
        time/               # server_clock.dart
        utils/              # validators.dart, formatters.dart, debounce helpers
        widgets/            # shared UI: AppButton, StatusChip, SkeletonBox, EmptyView, ErrorView, QrCard...
      features/
        auth/               # login, register (3 steps), pending, session
        menu/               # daily menu, eligibility banner
        orders/             # place order, my orders, today's QR
        profile/            # profile, subscription status, identity QR
        notifications/      # list + push handling
        staff_scan/         # scanner + meal scan result
        staff_orders/       # orders by slot, status changes
        subscriptions/      # register subscription flow (staff/admin)
        admin_dashboard/
        admin_dishes_menus/ # dishes CRUD + daily menu planner
        admin_slots/
        admin_scholarships/ # list, CSV import, pending accounts
        admin_users/        # users list, detail, staff accounts
        admin_stats/
    test/                   # mirrors lib/
    pubspec.yaml
  docs/
    designs/                # Stitch exports S01..S19
    frontend-questions.md
```

Each feature folder:

```
feature_x/
  domain/    entities/  repositories/ (abstract)  usecases/ (optional, only if logic is shared)
  data/      models/ (fromJson/toJson, extends or maps to entities)  datasources/ (remote, local)  repositories/ (impl)
  presentation/  bloc/ (or cubit/)  pages/  widgets/
```

Use cases are optional: use them only when a bloc would otherwise contain business logic that belongs in the domain. Do not create empty boilerplate.

---

## 5. Design system (from the Stitch designs)

The **Stitch screenshots in `docs/designs/` are the visual source of truth.** When a detail is not visible, follow these tokens.

| Token | Value |
|---|---|
| Primary | `#1F8A4C` |
| Primary dark | `#14633A` |
| Accent | `#F59E0B` |
| Background | `#F7F8F5` |
| Surface | `#FFFFFF` |
| Text | `#1B1F1D` |
| Text secondary | `#6B726E` |
| Success / Warning / Error / Info | `#22A559` / `#F59E0B` / `#D93636` / `#2F80ED` |
| Radius | cards 16, buttons 12, chips fully rounded |
| Fonts | Poppins (titles, semi-bold), Inter (body) |
| Min tap target | 48 px |

- Material 3 `ThemeData` built from these tokens in `core/theme/`. No colors hard-coded inside widgets: always use the theme or `AppColors`.
- Shared widgets in `core/widgets/`: `StatusChip(status)` (received=info, preparing=warning, ready=success, collected=grey-green, cancelled=error), `SkeletonBox`, `EmptyView(icon,title,message,action)`, `ErrorView(message,onRetry)`, `PrimaryButton` (with loading state), `QrCard`.
- Build the shared widgets **first**, then screens.

---

## 6. Roles, navigation and route guard

Session data returned by `GET /me`:

```json
{
  "id": "…", "role": "student|staff|admin",
  "accountStatus": "active|pending",
  "firstName": "Awa", "lastName": "Ouédraogo", "matricule": "BIT-2024-001", "className": "2nde A",
  "eligibility": { "type": "scholarship|subscription|none", "subscriptionEndsAt": "2027-01-30" }
}
```

Routes (names in `route_names.dart`):

- Public: `/splash`, `/login`, `/register`.
- `/pending` : for `accountStatus == pending` (student waiting for admin validation).
- Student shell (bottom nav, 4 tabs): `/student/home` (Accueil), `/student/orders` (Mes commandes), `/student/qr` (Mon QR), `/student/profile` (Profil). Sub-routes: `/student/order/new` (slot choice), `/student/order/confirmed`, `/student/notifications`, `/student/identity-qr`.
- Staff shell (bottom nav): `/staff/scan`, `/staff/orders`, `/staff/subscriptions`, `/staff/profile`.
- Admin shell (bottom nav): `/admin/dashboard`, `/admin/menus`, `/admin/users`, `/admin/more`. "Plus" opens: scanner, subscriptions, slots, scholarships, pending accounts, staff accounts, statistics.

**Guard (`redirect`)** driven by `AuthBloc`:

1. `AuthUnknown` (app starting, reading tokens) -> `/splash`.
2. `Unauthenticated` -> only `/login` and `/register` allowed, anything else redirects to `/login`.
3. `Authenticated` and `accountStatus == pending` -> `/pending` only.
4. `Authenticated` and active -> redirect to the home of the role (`student` -> `/student/home`, `staff` -> `/staff/scan`, `admin` -> `/admin/dashboard`). A student must never reach `/staff/*` or `/admin/*` (and so on): redirect to own home.
5. Use `refreshListenable` bound to a stream of `AuthBloc` so the router reacts to login/logout/session expiry.

On a failed refresh (refresh token invalid/expired), the interceptor emits `SessionExpired` to `AuthBloc` -> `Unauthenticated` -> redirect to `/login` with a snackbar "Session expirée".

---

## 7. API contract (PROVISIONAL, to align with the API team)

Base URL: `API_BASE_URL` (HTTPS). JSON. Header `Authorization: Bearer <accessToken>`. Dates ISO 8601 UTC. Money is not used (no payment).

**Error format (all errors):**

```json
{ "error": { "code": "SLOT_FULL", "message": "Ce créneau est complet.", "details": [ { "field": "slotId", "message": "…" } ] } }
```

`details` is filled for `422 VALIDATION_ERROR` (one entry per invalid field, `field` = request body field name).

**Pagination** on every list: `?page=1&limit=20` -> `{ "items": [...], "page": 1, "limit": 20, "total": 134 }` (limit max 50).

| Area | Method + path | Role | Notes |
|---|---|---|---|
| Auth | `POST /auth/scholarship-check` `{lastName, firstName, matricule}` | public | -> `{result: "verified"|"not_found"|"ambiguous"}` |
| | `POST /auth/register` `{lastName, firstName, matricule, className, claimsScholarship, password}` | public | -> `{user, accessToken, refreshToken}`; `accountStatus` may be `pending` |
| | `POST /auth/login` `{matricule, password}` | public | -> `{user, accessToken, refreshToken}` |
| | `POST /auth/refresh` `{refreshToken}` | public | -> new pair (refresh token rotates) |
| | `POST /auth/logout` `{refreshToken}` | any | revokes the session |
| | `GET /me` | any | see section 6; includes `serverTime` |
| | `POST /devices` `{fcmToken}` / `DELETE /devices/:token` | any | push registration (phase 5) |
| Menu | `GET /menus?date=YYYY-MM-DD` | any | -> `{date, status:"open|closed|none", cutoffAt, serverTime, dishes:[{id,name,description,photoUrl,portionsLeft}]}` |
| | `GET /menus/week` | any | days that have a published menu |
| Slots | `GET /slots?date=YYYY-MM-DD` | any | -> `[{id,label:"13:00-13:15",startsAt,capacity,placesLeft,active}]` |
| Orders | `POST /orders` `{date, dishId, slotId}` | student | -> order. Errors: `ORDER_CLOSED`, `SLOT_FULL`, `DISH_SOLD_OUT`, `ALREADY_ORDERED`, `NOT_ELIGIBLE` |
| | `GET /orders/mine?scope=upcoming|history&page=` | student | paginated |
| | `GET /orders/today` | student | today's order or 404 `NO_ORDER`; contains `qrPayload` |
| | `DELETE /orders/:id` | student | cancel; error `ORDER_CLOSED` after 10:00 |
| | `GET /orders?date=&slotId=&q=&page=` | staff, admin | orders for a slot; `q` searches name or matricule |
| | `PATCH /orders/:id/status` `{status:"preparing|ready"}` | staff, admin | |
| | `POST /orders/status-bulk` `{slotId, date, status:"ready"}` | staff, admin | |
| | `GET /orders/summary?date=` | staff, admin | portions per dish + counters `{served, total}` |
| Scan | `POST /scan/meal` `{payload}` | staff, admin | -> `{result:"valid", student:{…}, dish, slot}` or error codes `QR_ALREADY_USED` (with `usedAt`), `QR_EXPIRED`, `NO_ORDER`, `NOT_ELIGIBLE` |
| | `POST /scan/identity` `{payload}` | staff, admin | -> `{student:{id,firstName,lastName,className,matricule,eligibility}}` |
| Subscriptions | `GET /students?q=` | staff, admin | search by matricule or name (identity lookup without scan) |
| | `POST /subscriptions` `{studentId, months}` | staff, admin | months 1..10; -> new `subscriptionEndsAt`. Error `NOT_REQUIRED` for boursier |
| | `PATCH /subscriptions/:studentId` `{newEndsAt, reason}` | admin | correction |
| | `GET /subscriptions/:studentId/history` | any staff/admin; student for self | |
| Notifications | `GET /notifications?page=` / `PATCH /notifications/:id/read` | any | |
| Admin: dishes | `GET/POST /dishes`, `PUT/DELETE /dishes/:id`, `POST /dishes/:id/photo` (multipart) | admin | |
| Admin: menus | `PUT /menus/:date` `{dishes:[{dishId,portions}], published}` | admin | |
| Admin: slots | `GET /slots/config`, `PUT /slots/config` `{cutoffTime, slots:[{id,capacity,active}]}` | admin | |
| Admin: scholars | `GET /scholarships?q=&page=`, `POST /scholarships`, `DELETE /scholarships/:id` | admin | |
| | `POST /scholarships/import` (multipart CSV) | admin | -> `{added, duplicates, errors:[{line,message}]}` |
| Admin: pending | `GET /accounts/pending`, `POST /accounts/:id/approve` `{asScholarship: true|false}` | admin | each item has declared identity and `candidate` from the list |
| Admin: users | `GET /users?filter=all|scholarship|subscribed|expired|staff&q=&page=` | admin | |
| | `GET /users/:id`, `POST /users/staff` `{firstName,lastName,matricule,password}` | admin | |
| Admin: stats | `GET /stats?from=&to=` | admin | meals/day, popular dishes, scholarship vs subscribed, slot fill rate, expiring subscriptions |

QR payloads are **opaque signed strings** created by the server. The app never builds or verifies them: it only displays them with `qr_flutter` (student side) or sends the scanned string to the API (staff side). The meal QR is read from `GET /orders/today` (`qrPayload`), the identity QR from `GET /me` (`identityQrPayload`).

---

## 8. Core layer specification

### 8.1 Result and Failure (`core/error/`)

```dart
sealed class Result<T> { const Result(); }
final class Success<T> extends Result<T> { final T data; const Success(this.data); }
final class Err<T> extends Result<T> { final Failure failure; const Err(this.failure); }

sealed class Failure extends Equatable { final String message; ... }
// NetworkFailure (no connection / timeout), UnauthorizedFailure, ForbiddenFailure,
// NotFoundFailure, ValidationFailure(fieldErrors: Map<String,String>), ConflictFailure(code),
// ServerFailure, UnknownFailure
```

`ConflictFailure.code` carries the API error code (`SLOT_FULL`, `ORDER_CLOSED`, `QR_ALREADY_USED`…) so blocs can map them to the right UI variant. Mapping `DioException` -> `Failure` is in ONE place: `core/network/error_mapper.dart`, called by the repository implementations.

### 8.2 Config (`core/config/`)

`AppConfig.apiBaseUrl = String.fromEnvironment('API_BASE_URL')`, plus `bool.fromEnvironment('USE_MOCKS')`. Fail fast at startup with a clear message if `API_BASE_URL` is empty and `USE_MOCKS` is false.

Run commands (put them in the README):

```
flutter run --dart-define=API_BASE_URL=https://<deployed-api>
flutter run --dart-define=USE_MOCKS=true            # UI without backend
flutter build apk --release --dart-define=API_BASE_URL=https://<deployed-api>
```

### 8.3 Dio client and concurrency-safe refresh (`core/network/`)

- One `Dio` instance (base URL, timeouts 15 s, JSON).
- `AuthInterceptor`:
  - `onRequest`: add the access token (skip for `/auth/*`).
  - `onError` for 401: use a single shared `Completer<String?>? _refreshing`. If `_refreshing != null`, `await` it; otherwise create it, call `POST /auth/refresh` with a **separate Dio instance (no interceptor)**, save the new pair in secure storage, complete the completer, set it back to `null`. Then retry the original request with the new token (retry **once**; mark the request with `extra['retried']=true`). If refresh fails, clear tokens, complete with `null`, notify `AuthBloc` (`SessionExpired`).
  - Never try to refresh on `/auth/login`, `/auth/refresh`.
- Add a unit test proving that **3 simultaneous 401 produce exactly 1 refresh call**.

### 8.4 Cache then network (`core/storage/cache_store.dart`)

- Hive box wrapper: `put(key, json, savedAt)`, `get(key)`.
- Repository pattern for cached lists: `Stream<Result<T>> watchXxx()` or a two-step load in the bloc: emit cached content first (`fromCache: true`), then fetch, then emit fresh content; if the network fails and cache exists, keep the cached content and show a small banner "Hors ligne, données du <date>".
- Cache: today's/selected day menu (per date), `my orders` first page, **today's order with its QR payload** (so the QR still shows offline), the `/me` user.
- Clear the cache on logout.
- `connectivity_plus` is used only to show the offline banner, never to decide logic.

### 8.5 Server clock (`core/time/server_clock.dart`)

The cutoff countdown ("Commandes ouvertes jusqu'à 10h00") must not depend on the phone clock. Store `offset = serverTime - DateTime.now()` every time an API response contains `serverTime`. `ServerClock.now()` returns `DateTime.now() + offset`. The countdown widget uses `cutoffAt` and `ServerClock.now()`. When it reaches zero, it triggers a bloc event to refresh the menu (the server decides, the UI is just in sync).

### 8.6 Dependency injection

`injection.dart`: register `AppConfig`, `Dio`, storages, `ServerClock`, data sources, repositories (as their **abstract** type), and blocs (`registerFactory` for page-scoped blocs, `registerLazySingleton` for `AuthBloc`). When `USE_MOCKS` is true, register the `Fake...DataSource` implementations (realistic French sample data, simulated delays and a few simulated errors) instead of the remote ones. This allows the UI team to work before the API is deployed.

---

## 9. Screens, blocs, states

Screen IDs match the Stitch designs in `docs/designs/`.

### Auth

- **S01 Splash + Login** (`/splash`, `/login`). `LoginCubit` (form state: matricule, password, submitting, field errors, global error). Event handling on submit: ignore double taps (use a Bloc with `droppable()`, or guard in the Cubit).
- **S02 Register, 3 steps** (`/register`). `RegisterCubit` holds step 1 identity (nom, prénom, matricule, classe), step 2 status (boursier yes/no), step 3 password. When leaving step 2 with "boursier = oui", call `scholarship-check`: `verified` -> continue; `not_found` -> show the dialog of S03 ("Continuer comme non boursier" sets `claimsScholarship=false`; "Modifier mes informations" goes back to step 1); `ambiguous` -> continue (account will be pending). Show 422 field errors on the right field (e.g. "Ce matricule existe déjà").
- **S03 Pending account** (`/pending`) + the dialog above. "Actualiser" calls `GET /me`; if `accountStatus` becomes `active`, the guard redirects.
- `AuthBloc` (global): events `AppStarted` (read tokens, call `/me`, fall back to cached user if offline), `LoggedIn(user)`, `LogoutRequested` (call `/auth/logout`, always clear local data even if it fails), `SessionExpired`, `UserRefreshed`. States: `AuthUnknown`, `Authenticated(user)`, `Unauthenticated`.

### Student

- **S04 Home / daily menu** (`/student/home`). `MenuBloc`. Events: `MenuStarted`, `DateSelected(date)` (**transformer: `restartable()`**: if the student taps several days quickly, only the last request counts), `MenuRefreshed`, `CutoffReached`. State: `loading | content(menu, eligibility, serverTime, fromCache) | empty | error`. Show the eligibility card ("Boursier" badge or "Abonnement actif jusqu'au …" or red "Abonnement expiré"). Order buttons are disabled when closed, sold out or not eligible (with the reason as text). Day selector: Aujourd'hui, Demain, then weekday names.
- **S05 Order: slot choice + confirmation** (`/student/order/new`, `/student/order/confirmed`). `PlaceOrderBloc` (**transformer: `droppable()`** on `OrderSubmitted` to prevent double orders). Loads `GET /slots?date=`, shows `placesLeft`, "Complet" disabled. Map failures: `SLOT_FULL` -> message + reload slots and keep the dish; `ORDER_CLOSED` -> message "Les commandes sont closes" and go back; `ALREADY_ORDERED`, `NOT_ELIGIBLE`, `DISH_SOLD_OUT` -> clear French messages.
- **S06 My QR of the day** (`/student/qr`). `TodayQrCubit`: states `loading | hasOrder(order, qrPayload) | noOrder | error`. Variants: used (grayed + "Repas déjà récupéré à 13:22"), ready (green banner "Votre repas est prêt !"), no order (button "Commander un repas"). Increase screen brightness while the QR is visible (optional, `screen_brightness` package) and keep it working **offline** from cache. "Annuler ma commande" is visible only before cutoff, with a confirmation dialog.
- **S07 My orders** (`/student/orders`). `MyOrdersBloc`, tabs "À venir" and "Historique", pagination (**`droppable()`** on `LoadMore`), pull to refresh. **Optimistic update with rollback: `OrderCancelRequested`**: the order is immediately shown as `Annulée` (or removed from "À venir"), the API call is made, on failure the previous list is restored and a snackbar explains why (e.g. `ORDER_CLOSED`). Keep the previous state in the bloc to roll back.
- **S08 Profile + subscription** (`/student/profile`, `/student/identity-qr`). `ProfileCubit` (user + subscription history). Subscription progress bar and the "expire dans N jours" warning when <= 7 days. Identity QR full screen (white background, max brightness). Notification toggle, logout.
- **S09 Notifications** (`/student/notifications`). `NotificationsBloc` with pagination and read marking. Reachable from a bell icon in the home app bar (with unread dot).

### Staff

- **S10 Scanner** (`/staff/scan`). `ScannerBloc` using `mobile_scanner`. Event `CodeDetected(raw)` with **`droppable()` transformer plus a ~1.5 s cooldown** after a result (the camera detects the same QR many times per second; we must send exactly one request). States: `idle | processing | result(ScanOutcome)`. Today's counters card ("Servis 124 / 180") from `/orders/summary`. Torch toggle. Camera permission denied state with a button to open settings.
- **S11 Scan result bottom sheets**. `ScanOutcome` = `Valid(student, dish, slot) | AlreadyUsed(usedAt) | Expired | NoOrder | SubscriptionExpired | NetworkError`. Map from `ConflictFailure.code`. Big icon, large title (readable from 1 m), button "Scanner suivant" that resets the scanner. Use haptic feedback (success/error) and optional sound.
- **S12 Orders by slot** (`/staff/orders`). `StaffOrdersBloc`: events `SlotSelected` (restartable), `SearchChanged(q)` (**transformer: debounce 400 ms + `restartable()`**), `StatusChangeRequested(orderId, status)` (**optimistic with rollback**, `sequential()` per bloc), `BulkMarkReady(slot)`, `Refreshed`. Summary header: portions to prepare per dish. Auto-refresh every 30 s while the screen is visible (cancel the timer when the page is disposed).
- **S13 Register a subscription** (`/staff/subscriptions`). `SubscriptionFlowBloc`: step 1 scan identity QR or search by matricule (debounced search), step 2 student card + months stepper (1..10) with a live preview of the new end date (computed in the UI from the response data, display only), step 3 success. Boursier case: show "Étudiant boursier : aucun abonnement nécessaire" and disable validation. `droppable()` on submit.

### Admin (also has scanner and subscriptions through "Plus")

- **S14 Dashboard** (`/admin/dashboard`). `DashboardBloc` -> KPI cards + `fl_chart` bar chart (7 days) and slot fill rate. Shortcuts with counters (pending accounts).
- **S15 Dishes and menus** (`/admin/menus`). `DishesBloc` (list, delete with confirmation, optimistic removal with rollback is a nice second example), `DishFormCubit` (validation + 422 errors + photo pick/upload), `MenuPlannerBloc` (week calendar, dishes and portions per day, "Publier le menu").
- **S16 Slots config**. `SlotsConfigCubit` (capacity steppers, active toggles, cutoff time). Validate: capacity >= 1.
- **S17 Scholarships and pending accounts**. `ScholarshipsBloc` (search debounced, pagination, add, delete, CSV import with a preview and a result summary: added / duplicates / errors per line) and `PendingAccountsBloc` (each card shows declared identity vs list candidate; actions "Valider comme boursier" / "Refuser (non boursier)").
- **S18 Users and subscriptions**. `UsersBloc` (filters + debounced search + pagination), `UserDetailBloc` (history table, "Ajouter des mois", "Corriger l'abonnement" with mandatory reason), `StaffAccountCubit` (create staff account form).
- **S19 Statistics**. `StatsBloc`, date range picker, charts (bar, donut, list), "Exporter en CSV" (generate on the client from the loaded data and share via the system sheet, or call an export endpoint if the API team provides one).

### Cross-cutting UI behaviour

- Pull-to-refresh on every list.
- Snackbars for transient errors, inline `ErrorView` with "Réessayer" for load failures.
- Buttons show a loading indicator and are disabled during submission.
- Confirmation dialogs for destructive actions (cancel order, delete dish, remove boursier, correct subscription).
- Back button on Android must behave logically inside shells (go to the first tab, then exit).
- Text must not overflow with long French names (ellipsis, 2 lines max in cards). Support text scale up to 1.3.

---

## 10. State modelling convention

For loadable data use sealed states, e.g.:

```dart
sealed class MenuState extends Equatable {}
class MenuLoading extends MenuState {}
class MenuLoaded extends MenuState { final DailyMenu menu; final bool fromCache; ... }
class MenuEmpty extends MenuState { final String message; }
class MenuError extends MenuState { final Failure failure; }
```

For lists with pagination and optimistic updates, keep a single state class with `status`, `items`, `hasMore`, `isLoadingMore`, `previousItems` (for rollback), `failure`. Name events in the past tense (`OrderCancelRequested`, `MenuRefreshed`). Document every `transformer:` choice in one comment line explaining **why**.

---

## 11. Tests

- `test/` mirrors `lib/`.
- `bloc_test` for **every** bloc/cubit with logic: success path AND failure path (and the rollback for optimistic ones, the debounce for search blocs with `wait:`).
- Mocks with `mocktail` on the **repository contracts** (domain), not on Dio.
- Mandatory dedicated tests: (1) the auth interceptor does 1 refresh for 3 concurrent 401, (2) `ScannerBloc` sends only one request for repeated detections, (3) `MyOrdersBloc` rolls back a failed cancel, (4) error mapper: 422 -> `ValidationFailure` with fields, 409 -> `ConflictFailure(code)`.
- Bonus if time allows: widget tests for login and scan result sheets.
- A test must be able to **fail**: when writing a test, check it turns red if the tested code is broken.

---

## 12. Prompts to send to Antigravity

### 12.0 Master prompt (send first, once per workspace)

```
You are building the Flutter mobile app "CampusEats" for a school canteen. Read these files completely before doing anything: CAMPUSEATS_FRONTEND_INSTRUCTIONS.md (the full spec, you must follow section 2 strictly) and all images in docs/designs/ (Stitch designs S01 to S19, the visual source of truth).
Work in the folder app/. Do not touch api/.
Rules: Clean Architecture feature-first, flutter_bloc only, get_it, go_router, Dio, Result/Failure mapped at the data border, secure token storage, French UI.
Work ONLY on the phase I give you, nothing more. At the end of each phase: run flutter analyze, dart format, flutter test and report what passes. Then list what you did, what is missing, and any question for the API team (also append it to docs/frontend-questions.md).
Explain non-obvious design choices in short code comments, because every team member must be able to defend the code orally.
Confirm you understood, then wait for the phase prompt.
```

### 12.1 Phase 1: scaffold, core, theme, shared widgets

```
PHASE 1. In app/, create the Flutter project (Android) and implement: the folder structure of section 4, pubspec with the packages of section 3 (latest versions), AppConfig with --dart-define (API_BASE_URL, USE_MOCKS), core/error (Result, Failure), core/network (Dio client, error_mapper, AuthInterceptor with the concurrency-safe refresh of section 8.3), core/storage (secure token storage + Hive cache store), core/time/server_clock, core/theme (Material 3 theme from the tokens of section 5, fonts Poppins and Inter bundled as assets), core/widgets (StatusChip, SkeletonBox, EmptyView, ErrorView, PrimaryButton with loading, QrCard), core/di/injection.dart with the mock switch, and the go_router skeleton with route names of section 6 (pages can be placeholders). Add the tests for the error mapper and the interceptor (3 simultaneous 401 -> 1 refresh). Add a README section with the run commands. Stop after this phase.
```

### 12.2 Phase 2: authentication (walking skeleton, milestone M2)

```
PHASE 2. Implement the auth feature end to end following sections 6, 7 and 9: screens S01, S02, S03 matching docs/designs, LoginCubit, RegisterCubit (3 steps with scholarship-check and the "Boursier non reconnu" dialog), AuthBloc, the router redirect guard with role and pending-status rules, logout with token revocation, session expiry handling, 422 field errors displayed under the fields. Include the Fake data sources for USE_MOCKS=true (accounts: one student, one pending student, one staff, one admin, with a mocked scholarship list). Add bloc_tests (success + failure) for AuthBloc, LoginCubit and RegisterCubit. Also build the three empty shells (student, staff, admin bottom navigation) with placeholder tabs so the role redirect can be demonstrated. Stop after this phase.
```

### 12.3 Phase 3: student features

```
PHASE 3. Implement the student features S04 to S09 matching docs/designs: MenuBloc (restartable date selection, cutoff countdown using ServerClock, eligibility card, cache then network), PlaceOrderBloc (droppable submit, all error codes mapped to French messages), TodayQrCubit (QR with qr_flutter, offline from cache, all variants), MyOrdersBloc (pagination, tabs, OPTIMISTIC cancel with rollback), ProfileCubit (subscription status, identity QR full screen), NotificationsBloc (list only, no push yet). Every data screen needs loading, empty, error-with-retry and content states. Provide Fake data sources with realistic French data. Write bloc_tests (success, failure, rollback). Stop after this phase.
```

### 12.4 Phase 4: staff features

```
PHASE 4. Implement the staff features S10 to S13 matching docs/designs: ScannerBloc with mobile_scanner (droppable + cooldown so one QR triggers exactly one request), scan result sheets for all 5 outcomes + network error with haptic feedback, StaffOrdersBloc (slot tabs, debounced search, optimistic status change with rollback, bulk mark ready, 30 s auto refresh), SubscriptionFlowBloc (identity scan or matricule search, months stepper, success screen, boursier case). Handle camera permission denied. Add bloc_tests (including the scanner single-request test). Stop after this phase.
```

### 12.5 Phase 5: admin features

```
PHASE 5. Implement the admin features S14 to S19 matching docs/designs: DashboardBloc with fl_chart, DishesBloc + DishFormCubit (photo pick and upload), MenuPlannerBloc, SlotsConfigCubit, ScholarshipsBloc (search, pagination, CSV import with preview and result summary), PendingAccountsBloc, UsersBloc + UserDetailBloc + StaffAccountCubit, StatsBloc with date range and CSV export. The admin "Plus" tab also gives access to the scanner and subscription flow already built for staff (reuse, do not duplicate). Fake data sources, loading/empty/error states everywhere, bloc_tests for every bloc with logic. Stop after this phase.
```

### 12.6 Phase 6: push notifications, polish, release

```
PHASE 6. (a) Push notifications with firebase_messaging: register the FCM token with POST /devices after login and remove it on logout, handle foreground (flutter_local_notifications), background and terminated states; tapping a notification of type order_ready opens /student/qr, type subscription_expiring opens /student/profile; refresh the relevant bloc when the app comes to the foreground. The Firebase project and google-services.json are added by the team: write the exact manual steps in docs/firebase-setup.md and make the code compile and run even if Firebase is not configured yet (guard the initialisation). (b) Polish: accessibility pass (semantics labels on QR and buttons, contrast, tap targets, text scale 1.3), offline banners everywhere cache is used, consistent empty states, app icon and splash. (c) Release: configure the Android release build (signing config read from key.properties NOT committed, add it to .gitignore), build the release APK with --dart-define, and update the README (run in under ten minutes, test accounts per role, known limitations). Run flutter analyze, dart format, and the whole test suite. Stop after this phase.
```

---

## 13. Definition of done (check after every phase)

- [ ] `flutter analyze` reports no issue; `dart format --set-exit-if-changed .` passes.
- [ ] `flutter test` is green, with success and failure tests for each bloc added in the phase.
- [ ] The app runs with `USE_MOCKS=true` and with the real API URL.
- [ ] Each new screen matches its Stitch design and has loading / empty / error (retry) / content states.
- [ ] The domain layer imports no Flutter or Dio.
- [ ] No hard-coded URL, no secret, no color literal outside the theme.
- [ ] The role guard works: a student cannot open a staff or admin route.
- [ ] Offline start: the cached menu and the QR of today still appear.
- [ ] The team has read the code and can answer: "what happens when 3 requests fail with 401 at the same time?", "why Bloc and not Cubit here?", "which transformer did you choose and why?", "what happens if the network drops when I tap this button?" (these are real defence questions).

---

## 14. Rules for the humans

- One member = one feature per branch, small pull requests reviewed by **another** member the same day. No direct push to `main` after Milestone 1. The commit history must show every member's work over the whole period.
- Do not paste a full AI-generated project in one commit. Commit phase by phase, in readable steps.
- Each member must write and understand code in both the app and the API (even if roles are split). Mention in the final report what the AI assistant was used for.
- If the API changes, update section 7 of this file and `docs/frontend-questions.md` first, then ask Antigravity to adapt the data layer only.
