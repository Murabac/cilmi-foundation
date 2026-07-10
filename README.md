# Reer Sh Yoonis

Family lineage & mutual-aid mobile app built with **Flutter** and **Supabase**.

## Features

- **RBAC** — Super Admin, Manager (×3), and Family Member roles with strict privacy boundaries
- **Family Tree** — Focused multi-generational lineage view (parents, center node, spouse/siblings, children)
- **Care Rating (1–5)** — Color-coded well-being tracking with manager administration
- **Treasury** — Monthly adult contributions ($50 default), payment logging, manager verification, audit ledger
- **i18n** — English and Af-Somali with Super Admin global language control

## Prerequisites

- [Flutter SDK](https://flutter.dev/docs/get-started/install) 3.11+
- A [Supabase](https://supabase.com) project

## Setup

### 1. Supabase database (multi-schema)

This app uses its own Postgres schema (`reer_sh_yoonis`) inside a shared Supabase project.

Open the Supabase SQL Editor and run:

```
supabase/migrations/001_initial_schema.sql
```

Then expose the schema to the API:

**Dashboard → Project Settings → API → Exposed schemas** → add `reer_sh_yoonis`

(The migration also attempts `ALTER ROLE authenticator SET pgrst.db_schemas` — if that fails, use the dashboard step above.)

This creates the `reer_sh_yoonis` schema with tables, RLS, auth trigger, storage bucket, and helper functions.

### 2. Configure credentials

Copy the example env file and add your Supabase values:

```bash
cp env.json.example env.json
# Edit env.json with your URL, anon key, and schema
```

Then run without passing flags each time:

```bash
flutter pub get
flutter run --dart-define-from-file=env.json
```

**Cursor / VS Code:** use the **Reer Sh Yoonis** launch configuration (loads `env.json` automatically).

**Windows shortcut:**

```powershell
.\scripts\run.ps1
```

`env.json` is gitignored — never commit real keys.

<details>
<summary>Manual flags (optional)</summary>

```bash
flutter run \
  --dart-define=SUPABASE_URL=https://YOUR_PROJECT.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=YOUR_ANON_KEY \
  --dart-define=SUPABASE_SCHEMA=reer_sh_yoonis
```

</details>

### 3. Bootstrap Super Admin

1. Sign up through the app (profile is created only when `app: reer_sh_yoonis` metadata is sent — handled automatically)
2. In SQL Editor, promote your account:

```sql
UPDATE reer_sh_yoonis.profiles
SET role = 'super_admin'
WHERE email = 'your-email@example.com';
```

3. Optionally promote up to 3 managers:

```sql
UPDATE reer_sh_yoonis.profiles SET role = 'manager' WHERE email IN ('manager1@...', 'manager2@...');
```

### 4. Seed family tree

The sample lineage from your CSV is at `data/family_tree.csv` (**103 members**).

Load it into Supabase:

```sql
-- Run in SQL Editor (after 001_initial_schema.sql)
-- Paste contents of supabase/seed_family.sql
```

Or regenerate after editing the CSV:

```powershell
powershell -File scripts/generate_seed.ps1
```

Tree structure from the spreadsheet:

| Column | Meaning |
|--------|---------|
| GRANDPARENT | Patriarch (Sheekh Yonis) |
| UNCLE | His sons |
| CHILD | Grandchildren |
| GRANDCHILD | Great-grandchildren |

All members are inserted as `family_member` / `adult` with `father_id` links. Update roles, demographics, phones, and care ratings in the app or via SQL after seeding.

### 5. Generate monthly billing

Super Admin → **Settings** → **Generate Monthly Billing**, or call:

```sql
SELECT reer_sh_yoonis.generate_monthly_billing();
```

## Project structure

```
lib/
├── app.dart                 # App shell, auth gate, login
├── main.dart
├── config/                  # Supabase credentials
├── l10n/                    # en.json / so.json loaders
├── models/                  # Profile, Contribution, etc.
├── providers/               # Riverpod state
├── services/                # Supabase API layer
├── screens/
│   ├── dashboard/           # Care priority feed + admin metrics
│   ├── tree/                # Focused family tree
│   ├── contributions/       # Adult payment portal
│   ├── settings/            # Super Admin panel
│   └── admin/               # Treasury & verification queue
├── theme/
└── widgets/
```

## Role permissions

| Capability | Super Admin | Manager | Family Member |
|---|:---:|:---:|:---:|
| Global pool balance | ✅ | ✅ | ❌ |
| Audit ledger | ✅ | ✅ | ❌ |
| Verify payments | ✅ | ✅ | ❌ |
| Update care ratings | ✅ | ✅ | ❌ |
| Change adult rate / language | ✅ | ❌ | ❌ |
| Promote managers / demographics | ✅ | ❌ | ❌ |
| Family tree | ✅ | ✅ | ✅ |
| Own contributions (adults) | ✅ | ✅ | ✅ |
| Payment UI (students/children) | Exempt | Exempt | Exempt |

## Care rating scale

| Level | Label | Color |
|:---:|:---|:---|
| 1 | Stable & Flourishing | Emerald |
| 2 | Stable | Light green |
| 3 | Under Pressure | Amber |
| 4 | Urgent Need | Orange |
| 5 | Critical Crisis | Red |

## License

Private family project.
