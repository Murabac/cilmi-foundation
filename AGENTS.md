# CILMI Foundation app — agent context

Read this file fully before any change. Then read `design/DESIGN.md` before any UI work.

## What the app is

Private family app for **CILMI Foundation** (Reer Sheekh Yoonis, Hargeisa, Somaliland): family tree / lineage (abtirsiin), monthly contributions (qaadhaan) paid by ZAAD or e-Dahab, a family treasury (sanduuq), member welfare (care rating) and monthly member status reports. About 261 members. Users include elders and less technical people, the diaspora, young members, and managers/admins.

- Package: `com.cilmifoundation.mobile` · Flutter app name in pubspec: `reer_sh_yoonis`
- Languages: Somali (main) and English. Every UI string comes from `assets/l10n/so.json` + `assets/l10n/en.json` via `l10n.t('key')`.

## Stack and layout

- Flutter (SDK ^3.11, currently 3.47+), Riverpod 2 (`flutter_riverpod`), `supabase_flutter`, `google_fonts`, `url_launcher`, `intl`.
- Backend: Supabase only (no own server). Schema `reer_sh_yoonis` in a shared Supabase project. Security lives in RLS policies + `SECURITY DEFINER` RPCs.
- Android build: Gradle 9.3.1, AGP 9.1.0, KGP 2.4.0, `android.newDsl=false` (must stay false).

```
lib/
  app.dart                 auth gate + login screen
  main.dart
  screens/
    home_shell.dart        bottom navigation + app bar
    dashboard/             Home
    tree/                  Family tree tab
    contributions/         Give / pay (member)
    profile/               my profile, lineage setup, claim pending
    admin/                 payment report, verification queue, treasury,
                           members_manager_screen, whatsapp_message_screen
    reports/               status_report_screen
    settings/              admin settings (super admin)
    auth/                  register
  widgets/                 shared widgets (member_business_card, pedigree_tree_chart,
                           family_tree_list_view, member_edit_sheet, status_update_sheet,
                           member_status_fields, dashboard_actions, app_logo, widgets.dart)
  services/services.dart   ALL Supabase calls (ProfileService, ContributionService,
                           TreasuryService, SettingsService, AuthService, AdminService)
  providers/providers.dart Riverpod providers
  models/                  models.dart, payment_report.dart, lineage_tree.dart
  theme/app_theme.dart     theme + brand colours
  utils/                   lineage_name, branch_filter, payment_exempt, somali_search,
                           whatsapp_contributions_message, phone_utils, patriarch_resolver
assets/brand/              final logo files (Family Crown, teal & gold) — PNG + SVG
assets/l10n/               so.json, en.json
supabase/migrations/       001–038 (all applied to production)
design/                    redesign mockups (PNG + HTML) and DESIGN.md
```

Run: `flutter run --dart-define-from-file=env.json` (or `scripts/run.ps1`). `env.json` is gitignored.

## Rules (always)

1. **One step at a time.** Do only the step you were asked for. When done: run `flutter analyze` (0 errors required), list the files you changed, tell the user what to test, then stop.
2. **Do not change behaviour while restyling.** Redesign steps change layout and styling only. Keep every existing feature, provider, service call, permission check and role rule working.
3. **Strings:** never hard-code user-facing text. Add new keys to BOTH `so.json` and `en.json`. Somali is the main language; write natural Somali.
4. **Colours/typography:** use the theme and the tokens in `design/DESIGN.md` (`BrandColors` in `app_theme.dart`). No random hex values in screens.
5. **Database:** never edit migrations 001–038 (they are live). Any schema/RLS change = a new file `supabase/migrations/039_….sql` and tell the user to run it in the Supabase SQL Editor. All data access stays in `services/services.dart`.
6. **Accessibility for elders:** touch targets ≥ 48 px, body text ≥ 15 sp, labels always visible on the bottom bar, contrast ≥ 4.5:1.
7. Never use the name "H24" anywhere.

## Do-not-break list

These were built and tested recently. Restyle around them; do not change their logic:

- Payers list: only members with `monthly_amount > 0` pay; everyone else is exempt (`utils/payment_exempt.dart`, DB function `is_profile_payment_exempt`). Per-member amounts, "mark paid" with a custom amount.
- WhatsApp contributions message format (`utils/whatsapp_contributions_message.dart`) — must stay exactly: bold header `Qaadhaanka Bisha {N}aad`, `ZAAD = … – EDAHAB = …`, bold group title, numbered lines `N. Name Father = $ X ✅` (paid) or `⏳` (not yet), blank line, bold `TOTAL PAID = $ X`.
- Monthly member status (`update_member_status` RPC, `member_status_history`), status report screen, members manager (spelling-tolerant search in `utils/somali_search.dart`).
- Claim / lineage-setup flow for new sign-ups (`lineage_directory` RPC, masked data for unapproved users).
- Roles: super_admin > treasury > manager > family_member (`UserRoleX` in models.dart).

## Current status

- Done: security migration 037, payers + status migration 038 + payer seed, new features above, Step 5 (new logo, launcher icons, splash), Gradle 9 upgrade.
- Next: Step 6 onward (below).

## Redesign plan (steps)

Design source: `design/png/*.png` (what it should look like) and `design/html/*.html` (exact sizes/colours/text). Spec: `design/DESIGN.md`.

| Step | What | Main files | Test |
|---|---|---|---|
| 5 | Logo, app icon, splash — **done, verify only** | `widgets/app_logo.dart`, pubspec `flutter_launcher_icons` | icon, splash, login logo |
| 6 | Theme: teal & gold, Manrope font, card/button/input/chip styles, solid teal headers | `theme/app_theme.dart`, `theme/member_status_theme.dart` | every screen readable, no navy/cream left |
| 7 | Bottom bar: floating teal bar, 4 tabs Hoyga · Qoyska · Bixi · Aniga, gold active tile. Admin screens reached from Home shortcuts, not tabs | `screens/home_shell.dart`, `widgets/dashboard_actions.dart` | member / manager / treasury / super admin each see the right things |
| 8 | Login + register screens (`design/png/01-login.png`) | `app.dart`, `screens/auth/register_screen.dart` | sign in, sign up, language switch |
| 9 | Home (`02-home.png`): greeting header, contribution card with gold "Hadda bixi", quick links, Xaaladda Qoyska stats, Maamulka card for staff, monthly status card | `screens/dashboard/dashboard_screen.dart` | numbers match real data |
| 10 | Family tree — Geed view (`03-family-tree.png`): lineage breadcrumb, generation rows J5/J6/J7 with connector lines, "Jiil kor", care dots + legend | `screens/tree/family_tree_screen.dart`, `widgets/pedigree_tree_chart.dart`, `widgets/family_tree_list_view.dart` | move up/down several branches; parents/children correct |
| 11 | Family tree — Abtirsiin view (`04-lineage.png`): full nasab line + numbered timeline + share | same + new widget | lineage correct for several members |
| 12 | Member card bottom sheet (`05-member-card.png`) | `widgets/member_business_card.dart` | open from tree and from search |
| 13 | Bixi / Give (`06-give.png`) | `screens/contributions/contribution_screen.dart` | pay → "Waan bixiyay" → admin approves |
| 14 | Admin & treasury restyle (`07-admin-treasury.png`) | `screens/admin/*` | approve/reject, inflow/outflow, report filters |
| 15 | Polish + release: Somali default language, copy review, version 1.1.0+, release build | `pubspec.yaml`, settings | install release build on a phone |
