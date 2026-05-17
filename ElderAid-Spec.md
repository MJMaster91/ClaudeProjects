# ElderAid — Product Spec Document
> Version 1.0 | Last updated: 2026-05-14
> Working title: ElderAid (rename before market launch)

---

## 1. Product Vision

ElderAid is a mobile app for elderly people who are comfortable with smartphones but experiencing memory loss. It replaces the normal phone home screen with a calm, distraction-free interface that surfaces only what matters: calling loved ones, sending simple messages, and getting help when confused.

**Primary user:** Elderly person with mild-to-moderate memory loss. Comfortable with phones but overwhelmed by complex UIs.
**Secondary user:** Relative or caregiver who sets up and manages the app on behalf of the elderly person.
**Phase 2 user:** Retirement home staff managing multiple residents from a central dashboard.

---

## 2. Platform & Tech Stack

### Mobile App (Frontend)
| Decision | Choice | Reason |
|---|---|---|
| Framework | **Flutter** | Single codebase for Android + iOS, excellent accessibility widget library, strong Play Store + App Store deployment story |
| Language | **Dart** | Flutter's native language |
| Min OS | Android 8.0+ / iOS 14+ | Covers >95% of active devices |
| Orientation | Portrait only | Reduces cognitive complexity |
| State management | **Riverpod** | Simple, testable, well-documented for Flutter |
| Local database | **sqflite** | SQLite wrapper for Flutter — stores contacts, settings, app state locally |
| Localization | **flutter_localizations + intl** | Scaffolded from day one. All strings in ARB files. MVP ships English; German added in Phase 2 without code refactor. |

### Backend
- **MVP:** None. All data stored locally on-device. No user accounts, no cloud sync, no API calls except the AI helper.
- **Phase 2:** Cloud backend for retirement home multi-tenancy. Recommended stack: **Supabase** (PostgreSQL, Auth, Storage, REST API) hosted on **Google Cloud europe-west3 (Frankfurt)** for GDPR compliance. Alternatively Firebase (EU region).

### AI Helper
| Component | Technology |
|---|---|
| Speech-to-text | `speech_to_text` Flutter package (on-device, free, no API cost) |
| Intent & response | **OpenAI GPT-4o mini** API (cheap, fast, sufficient for simple commands) |
| Text-to-speech | `flutter_tts` Flutter package (on-device, free) |

### Payments (Phase 2 only)
- **RevenueCat** — manages in-app subscriptions for both iOS and Android via a single Flutter SDK
- **Stripe** — handles facility/B2B invoicing and web-based subscription management for retirement homes

---

## 3. User Roles

| Role | Description | How they interact |
|---|---|---|
| **End user** | Elderly person | Uses the locked-down app daily. Cannot access settings. |
| **Setup admin** (MVP) | Relative or caregiver | Unlocks setup mode via PIN on the physical device. Manages contacts, settings, font size. |
| **Facility admin** (Phase 2) | Retirement home staff | Web dashboard. Manages multiple residents, pushes events/menus, controls nurse-call routing. |

---

## 4. Kiosk / Launcher Mode

The app fully replaces the normal phone home screen. No access to other apps during normal use.

**Android:**
- App registers as default launcher via `android.intent.category.HOME` + `android.intent.category.DEFAULT` intent filters in `AndroidManifest.xml`
- Home button press returns to ElderAid, not the Android launcher
- Setup mode (PIN-authenticated) temporarily surfaces a "Exit to normal phone" option for the relative

**iOS:**
- Apple does not permit third-party launcher replacement
- Relative enables **Guided Access** (Settings → Accessibility → Guided Access) during setup, which locks the device to ElderAid
- App is full-screen; home swipe gesture is disabled while Guided Access is active
- Setup instructions for enabling Guided Access included in the app's setup flow

---

## 5. Feature List

### Feature 1 — Home Screen (Contact Grid)
**Description:** The main screen the elderly user sees at all times. Displays a grid of large contact tiles — each tile shows a full-face photo, large name text, and a call button. Maximum 8 contacts visible without scrolling (recommended: 4–6 for clearest layout).

**Behaviour:**
- Each contact tile is a full-bleed photo card — the photo fills the entire tile, with the contact name as bold white text on a dark gradient overlay at the bottom
- Tapping anywhere on a contact tile immediately initiates a phone call (uses device native dialer)
- No confirmation dialog — one tap = call (speed over safety; relatives set up only trusted numbers)
- Missed calls shown as a badge on the contact tile
- Large clock and date displayed at the top, with a teal icon badge identifying the current screen
- **Help tile:** An amber card in the contact grid (same size as contact tiles) showing a large `?` icon and "Help" label — tapping opens a help dialog. Not a floating button.

**Tech:** Flutter GridView, `url_launcher` package for `tel:` links, `sqflite` for contact storage

---

### Feature 2 — Messages Screen (WhatsApp)
**Description:** A dedicated Messages screen that mirrors the home screen's large-tile grid, but tapping a contact opens their WhatsApp conversation directly. Unread WhatsApp messages are shown as a badge on the contact tile.

**Behaviour:**
- Bottom navigation switches between Phone (home) and Messages
- Messages screen shows a 2-column grid of large contact tiles — same visual style as the home screen
- Only contacts marked "Uses WhatsApp" in Setup appear on this screen
- Tapping a tile opens WhatsApp directly at that contact's conversation (deep link: `whatsapp://send?phone=…`)
- If WhatsApp is not installed, a friendly SnackBar explains this
- **Unread badge:** Android's Notification Listener Service detects incoming WhatsApp notifications and shows a green badge (unread count) on the relevant contact tile. Badge clears when the user taps the tile.
- Notification access must be granted once by the relative in Setup. A guided prompt is shown if access is not yet granted.

**Tech:** `url_launcher` (already included) for WhatsApp deep links; `notification_listener_service` Flutter package for notification badge detection; no API keys or accounts required

> **SMS (Wave 2):** Full native SMS inbox — read/send threads, quick-reply chips — is planned for Wave 2. See Wave 2 roadmap section.

---

### Feature 3 — AI Helper
**Description:** A persistent large "Help" button always visible on screen. Activates a voice-driven assistant that guides the user.

**Interaction flow:**
1. User taps the **"? Help"** button (bottom-right, always visible, large)
2. Screen dims slightly; a large pulsing microphone indicator appears with text: *"I'm listening — say a name or ask for help"*
3. User speaks — examples: *"Call Maria"*, *"Send a message to Thomas"*, *"What does this button do?"*, *"Go back to the start"*
4. `speech_to_text` converts audio to text
5. Text + current screen context sent to GPT-4o mini API with a system prompt that includes: list of contact names, current screen name, available actions
6. GPT-4o mini returns a short, simple response (max 2 sentences) + an optional action (e.g. `{ "action": "call", "contact": "Maria" }`)
7. `flutter_tts` speaks the response aloud while the text is displayed in a large overlay
8. If an action is returned, it is executed automatically (e.g. initiates call to Maria)

**System prompt guidelines for LLM:**
- Always respond in simple language (max Grade 5 reading level)
- Always be calm and reassuring
- Never say "I don't know" — always suggest a next step
- Address the user by first name if known

**MVP scope:** Navigation help, contact lookup by name, sending messages, returning to home screen. Not a general-purpose chatbot.

**Tech:** `speech_to_text`, `flutter_tts`, `http` package for OpenAI API calls, environment variable for API key (never hardcoded)

---

### Feature 4 — Setup Mode
**Description:** PIN-protected admin interface the relative uses to configure the app. Hidden from the end user during normal operation.

**Access:** For MVP evaluation, Setup is accessible via the bottom navigation bar. Before store release this should be replaced with a hidden entry point (e.g. tap the clock 5 times) so it is invisible to the elderly user during normal operation.

**PIN storage:** MVP stores the 4-digit PIN as a plain string in `shared_preferences`. Upgrade to bcrypt hash before public release.

**Setup mode screens:**
- **Contacts manager** — add/edit/delete contacts (name, phone number, photo from gallery or camera)
  - *Post-MVP:* Import contact directly from device phone book (contacts_service package)
  - *Post-MVP:* Drag-and-drop reordering of contacts in the grid (sort_order field already in DB)
- **Quick replies** — edit the pre-written SMS quick-reply options
- **Display settings** — font size slider (Large / Extra Large / Maximum), theme (MVP: Warm & Friendly only)
- **AI helper settings** — enter/update OpenAI API key, test the helper
- **App settings** — change setup PIN, set user's first name (used by AI helper), language (MVP: English only)
- **Kiosk settings** — enable/disable launcher mode on Android, show Guided Access instructions for iOS

**Tech:** PIN stored as bcrypt hash in `shared_preferences`. Setup screens are separate Flutter routes only reachable via PIN flow.

---

### Feature 5 — Configurable Feature Tiles *(Family Pro)*
**Description:** The home screen grid supports optional app tiles beyond contacts. The relative enables or disables tiles from the remote web dashboard or local setup mode. Only enabled tiles are visible to the end user.

**Available optional tiles:**
| Tile | Action | Notes |
|---|---|---|
| **Mail** | Deep link — opens user's default email app (Gmail, etc.) to inbox | Not a built-in mail client. Relative sets which app is the default during device setup. |
| **Calendar** | Opens built-in ElderAid calendar screen | Relative adds/edits events via web dashboard; user sees read-only list of upcoming events in large text |
| **Banking** | Deep link — opens user's installed banking app | Not built-in. Avoids all financial data regulatory complexity. Relative configures which banking app to open during setup. |

**Tile design:** Same large-tile format as contacts — icon, label, subtle colour coding per tile type. Tap = single action, no sub-menus.

**Architecture:** Each tile is a `FeatureTile` model stored in the user's config (local `sqflite` for MVP, synced via Supabase in Phase 2). Adding a new tile type in future = adding one entry to the tile registry, no structural changes.

**Tech:** `url_launcher` for deep links (e.g. `googlegmail://`, bank app URI schemes). Tile configuration stored as JSON in user profile. Android app URI schemes vary by banking app — relative enters the correct package name during setup if needed.

---

### Feature 6 — Mental Fitness Profiles *(Family Pro)*
**Description:** The relative defines 2–3 named profiles that control which tiles and features are visible. Switching profiles instantly adapts the UI to the user's current cognitive state without manual tile-by-tile toggling.

**Example profiles:**
| Profile | Tiles shown | Use case |
|---|---|---|
| **Full** | Contacts, Messages, Mail, Calendar, Banking | User is having a good day, fully oriented |
| **Standard** | Contacts, Messages, Calendar | Average day — familiar tasks only |
| **Simple** | Contacts only | Difficult day — maximum reduction, no distractions |

**Behaviour:**
- Relative switches the active profile from the remote dashboard (or local setup mode)
- App applies the new profile within seconds (synced via Supabase in Phase 2; immediate in local setup mode)
- Profile switch is invisible to the end user — tiles simply appear/disappear on next home screen load
- Profile names are defined by the relative (they may rename "Full" to "Good day" etc.)
- AI helper is aware of the active profile and only references available features in its responses

**Tech:** Profile config stored as JSON in Supabase user record (Phase 2). App polls for config changes on foreground resume. Local cache ensures app works offline with last-known profile.

---

### Feature 7 — Remote Settings Management *(Family Pro)*
**Description:** The relative manages the elderly user's app configuration remotely via a web dashboard, without needing physical access to the device.

**Remotely manageable settings:**
- Add / edit / remove contacts (name, photo, phone number)
- Enable / disable feature tiles
- Switch active mental fitness profile
- Update quick-reply SMS options
- Change font size
- Change theme
- Restore to last saved configuration (rollback if user accidentally changes something)

**Restore / rollback:**
- Every settings change (local or remote) is versioned in Supabase with a timestamp
- Relative can view change history and restore any previous config with one click
- "Restore to factory setup" resets to the initial configuration the relative first created

**Sync behaviour:**
- App syncs settings on launch and every time it returns to the foreground
- Changes pushed from the dashboard are applied within ~30 seconds (Supabase Realtime subscription)
- If offline, app uses the last synced config. Changes queue and apply on next connection.
- Local setup mode (PIN on device) remains available as fallback at all times

**Web dashboard tech:** Next.js + Supabase JS client, deployed to Vercel (EU region). Relative logs in via email + password (Supabase Auth). Each elderly user account is linked to one or more relative accounts.

**Tech:** Supabase Realtime for push sync. `connectivity_plus` Flutter package to detect online/offline state. Settings versioned in a `config_history` table (user_id, config_json, created_at).

---

### Feature 8 — Helpline Alerts + Daily Welfare Check *(Family Pro)*
**Description:** The app silently monitors usage patterns for signs of confusion or distress. When a threshold is crossed, it sends a push notification to the relative's phone with context about what happened, allowing them to check in or call immediately.

**Trigger events monitored:**
| Trigger | Default threshold | Meaning |
|---|---|---|
| Repeated Help button taps | 3+ times within 10 minutes | User is repeatedly confused |
| Circular navigation | Same screen visited 4+ times in 5 minutes without completing an action | User is lost and looping |
| Long idle on action screen | Stuck on compose message / dial screen for 3+ minutes without completing | User started a task but cannot finish |
| Unanswered incoming call | Incoming call from an approved contact not answered 2+ times in a row | User may be unable to respond |
| **Daily welfare check** ⭐ | App not interacted with for a configurable period (default: 24 hours) | Passive safety net — no action needed from user. Especially valuable for elderly people living alone. |

**Notification to relative:**
- Push notification to relative's phone with plain-language context, e.g.:
  - *"Oma has pressed Help 4 times in the last 8 minutes on the Messages screen."*
  - *"Oma appears to be stuck — she has been on the same screen for 5 minutes."*
  - *"Oma hasn't opened ElderAid today."*
- Notification includes a **"Call now"** shortcut button that dials the elderly user directly
- Relative can view a simple activity log in the web dashboard: last 7 days of sessions, screens visited, Help button usage

**Configuration (relative controls via web dashboard):**
- Enable / disable each trigger type individually
- Adjust thresholds (e.g. change Help button alert from 3 to 5 taps)
- Set quiet hours (no notifications between 22:00–08:00 unless welfare check)
- Add multiple relatives / caregivers to receive alerts (e.g. both daughter and son)

**GDPR / Privacy:**
- Monitoring must be disclosed to the end user during setup — consent screen in setup mode (plain language, large text: *"Your family can see if you need help using this app"*)
- Consent logged with timestamp in Supabase
- Activity data retained for 30 days by default, configurable, deletable on request
- Data never sold or shared with third parties

**Tech:**
- `user_events` table in Supabase: `(user_id, event_type, screen, timestamp)`
- App writes events locally and syncs to Supabase in background
- Supabase Edge Function runs on a schedule (every 5 minutes) to evaluate thresholds and fire alerts
- **Firebase Cloud Messaging (FCM)** delivers push notifications to relative's Android/iOS device
- `firebase_messaging` Flutter package on the relative's app (or web push via FCM for dashboard)
- Relative's web dashboard shows activity timeline with events visualised per day

---

## 6. Visual Design Spec

### MVP Theme — Warm & Friendly
| Element | Spec |
|---|---|
| Background | Warm off-white `#FDF6EC` |
| Primary colour | Soft teal `#4A9B8E` (buttons, active states) |
| Accent colour | Warm amber `#E8A838` (help button, badges) |
| Text primary | Dark charcoal `#2C2C2C` |
| Text secondary | Medium grey `#6B6B6B` |
| Font | **Nunito** (Google Font) — rounded, friendly, highly legible |
| Default font size | 20sp body, 28sp contact names, 16sp labels |
| Tap target minimum | 64×64dp (exceeds WCAG 2.1 AA 44px minimum) |
| Corner radius | 16dp (rounded, approachable) |
| Iconography | Filled, large, simple — no thin-line icons |
| Contact photo | Full-bleed tile photo (fills entire card); name as bold white text on dark gradient overlay |

### Navigation
- Maximum 2 taps to reach any action
- Bottom navigation bar (teal, full-width): **Messages** | **Setup** (Setup hidden pre-launch; replaced with hidden entry point)
- Help accessible via amber tile in the contact grid
- Every screen shows a home icon in the AppBar for 1-tap return to Home
- No hamburger menus, no nested settings visible to end user
- Back button always returns to Home screen (never exits app)

### Phase 2 — Theme Switching *(behind Family Pro paywall)*
- **Calm & Minimal** — white, clean sans-serif, clinical
- **High Contrast** — dark background, bright text, accessibility-optimised
- Themes are Flutter `ThemeData` objects; switching is a single config change. Architecture supports this from day one.

---

## 7. Screen Map

### MVP
```
[Home / Contact Grid]  ←→  [Messages / WhatsApp Grid]
        |                         |
   [Active Call]           Opens WhatsApp app at contact's conversation
   (native dialer)         (deep link — leaves app briefly)

[Help Dialog] — triggered by Help tile in the contact grid (not a separate route)

[Setup Mode] — PIN-gated, accessible via bottom nav (hidden entry point pre-launch)
  ├── Contacts Manager  (add/edit/delete; WhatsApp toggle per contact)
  ├── Notification Access  (grant once for WhatsApp badge detection)
  ├── Quick Replies  (Wave 2 — for SMS)
  ├── Display Settings
  ├── AI Helper Settings
  └── App Settings
```

### Phase 2 (Family Pro additions)
```
[Home / Tile Grid] — now shows optional tiles alongside contacts
        ├── [Contact tiles] → native dialer
        ├── [Mail tile] → deep link to email app
        ├── [Calendar tile] → built-in Calendar Screen
        └── [Banking tile] → deep link to banking app

[Calendar Screen] — read-only, events pushed by relative
[Help Overlay] — AI aware of active profile and visible tiles

[Family Web Dashboard] — relative's browser interface
  ├── User Profile & Contacts
  ├── Feature Tiles (enable/disable)
  ├── Mental Fitness Profiles (define + switch active)
  ├── Remote Settings & Config History
  ├── Restore / Rollback
  ├── Helpline Alert Settings (thresholds, quiet hours, recipients)
  └── Activity Log (7-day session history, Help button usage)
```

---

## 8. Monetization

| Tier | Target | Price | Features |
|---|---|---|---|
| **Free** | Individual users / trial | $0 | Contacts (max 5), 1-tap calling, SMS, setup mode, Warm & Friendly theme |
| **Family Pro** | Families / caregivers | ~$3–5/month per account | Unlimited contacts, AI helper, theme switching, configurable feature tiles (Mail, Calendar, Banking), mental fitness profiles, remote settings management, helpline alerts with push notifications, daily welfare check (alert if app unopened for 24h), activity log, priority support |
| **Facility License** | Retirement homes | ~$2–4/user/month | Everything in Pro + centralized admin dashboard, events, menus, nurse-call, usage analytics, health data features (GDPR Article 9 compliant) |

**MVP:** No payment infrastructure. Free app, no paywalls.
**Phase 2:** RevenueCat SDK added to Flutter app. Stripe for B2B facility billing. Paywall gate added to AI Helper and theme switching features.

---

## 9. Deployment

### MVP Deployment

**Android (Google Play Store):**
1. Create Google Play Console account (~$25 one-time fee)
2. Build release APK/AAB: `flutter build appbundle --release`
3. Sign with keystore (generate once, store securely — losing it = cannot update the app)
4. Upload to Play Console → Internal Testing → Closed Testing → Production
5. Complete Play Store listing: description, screenshots, privacy policy URL (required)
6. Privacy policy must be hosted at a public URL (simple static page is fine)

**iOS (Apple App Store):**
1. Apple Developer Program ($99/year)
2. Build via Xcode: `flutter build ios --release`
3. Upload via Xcode or Transporter to App Store Connect
4. Configure Guided Access instructions in App Store description
5. App Review typically 1–3 days

**Infrastructure (MVP):** None — fully local app. No servers to provision.

### Phase 2 Deployment (Cloud Backend)

**Recommended: Supabase on Google Cloud europe-west3 (Frankfurt)**
- Supabase provides PostgreSQL database, Auth, Storage, and auto-generated REST API
- Hosted in EU for GDPR compliance
- Free tier sufficient for early Phase 2; scales via paid plans
- Admin web dashboard: Next.js + Supabase JS client deployed to **Vercel** (EU region)

**CI/CD:**
- GitHub Actions for automated build + test on every PR
- Fastlane for automated Play Store + App Store deployments
- Environment secrets (API keys) stored in GitHub Secrets, never in code

---

## 10. Phase 2 & 3 Roadmap

### Phase 2 — Family Pro + German Localisation
- **Native SMS inbox** — read + send SMS threads natively, quick-reply chips, `telephony` package, Android-primary
- German localisation (ARB translation files, owner verifies as native speaker)
- Cloud backend (Supabase, EU-hosted) — required for all remote management features
- Remote contact management via family web dashboard
- RevenueCat + Stripe payment integration
- Theme switching (Calm & Minimal, High Contrast) behind paywall
- AI helper behind paywall
- Configurable feature tiles (Feature 5)
- Mental fitness profiles (Feature 6)
- Remote settings management + rollback (Feature 7)
- Helpline alerts + daily welfare check (Feature 8)

### Phase 3 — Facility Tier (Retirement Home)
- Multi-tenant backend (one account per facility, multiple residents)
- Facility admin web dashboard
- Events calendar (facility pushes events; residents see read-only calendar screen)
- Daily menu display (facility uploads; full-screen menu card in app)
- Direct nurse/staff call button (routes to facility's internal number)
- Facility-wide announcements / notifications
- Health data features (GDPR Article 9 compliant — explicit consent, audit logs, data processing agreements)
- Usage analytics per resident (for staff oversight)

---

## 11. Compliance & Legal

### GDPR (Germany / EU — applies from day one)
- **MVP:** Fully local. No personal data (names, photos, phone numbers) leaves the device. GDPR risk is minimal.
- Privacy policy required for store submission. Must cover: what data is stored locally, how to delete it (uninstall), contact details for data requests.
- **Phase 2:** EU-hosted backend only. Implement right-to-deletion (account + all data). Cookie/tracking consent if web dashboard uses analytics.
- **Phase 3:** Health-adjacent data triggers GDPR Article 9 (special category). Requires: explicit opt-in consent per data type, documented Data Processing Agreements (DPAs) with each retirement home operator, stricter access controls.
- **No health/medical data in MVP or Tier 2.** Tier 3 only.

### App Store Policies
- Apple and Google both require a privacy policy for apps that request microphone permission (AI helper uses microphone)
- Microphone permission must be justified in the app's permission rationale string
- Launcher/kiosk apps may receive additional review scrutiny on iOS — setup instructions must be clear

---

## 12. Non-Functional Requirements

- All tap targets minimum 64×64dp
- Default font size 20sp, configurable to 28sp max via setup mode
- Maximum 2 taps to reach any core action from Home screen
- App launches in under 2 seconds on mid-range hardware
- No ads, no unsolicited notifications, no dark patterns
- Back button never exits the app (returns to Home)
- App functions fully offline (MVP is 100% local; AI helper gracefully degrades with "No internet connection" message)
- No analytics or crash reporting tools that transmit PII in MVP

---

## 13. Implementation Status
> Last updated: 2026-05-17

| Feature | Status | Notes |
|---|---|---|
| Home Screen (Feature 1) | ✅ Built | Full-bleed tiles, teal header, amber Help tile, teal bottom nav |
| Messages Screen (Feature 2) | 🔨 In progress | WhatsApp deep link + notification badge |
| AI Helper (Feature 3) | 📋 Phase 2 | Deferred — needs OpenAI key + microphone permission |
| Setup — Contacts Manager | ✅ Built | PIN gate (4-digit numpad), add/edit/delete, image picker |
| Setup — App Settings | ⬜ Not started | Change PIN, set user's first name |
| Setup — Quick Replies | ⬜ Not started | Required for Messages screen |
| Kiosk / Launcher Mode | ⬜ Pre-launch | AndroidManifest HOME intent filter not yet added |

### Pre-launch hardening checklist
- [ ] Hide Setup entry point (remove from bottom nav; add clock-tap secret gesture)
- [ ] Upgrade PIN storage from plain string to bcrypt hash
- [ ] Remove demo seed contacts (`seedDemoContactsIfEmpty` in `database_helper.dart`)
- [ ] Add CATEGORY_HOME intent filter to AndroidManifest for kiosk mode
- [ ] Add privacy policy URL (required for store submission)
- [ ] Generate and securely store release keystore

---

## 14. Open Items for Future Decisions
- Final app name (ElderAid is placeholder)
- OpenAI API key management model for Phase 2 (per-user key vs. proxied through backend)
- Exact Quick Reply defaults (to be defined during UX design)
- Nurse-call routing mechanism for Phase 3 (SIP/VoIP vs. standard call)
- Whether to support Android tablets / iPads (larger screen layout)
