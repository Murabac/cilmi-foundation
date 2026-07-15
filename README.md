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

**Option A — Run all migrations once (recommended for new projects)**

1. Open Supabase **SQL Editor**
2. Paste and run the entire file: **`supabase/all_migrations.sql`**
   - Or regenerate it: `powershell -File scripts/combine_migrations.ps1`
3. Then run **`supabase/seed_family.sql`**

**Option B — Run migrations one by one**

Run each file in `supabase/migrations/` in order (`001` … `018`).

**If you already ran older migrations**, do **not** run `all_migrations.sql` again (error: `type "user_role" already exists`).

1. Run **`supabase/check_migration_status.sql`** to see what is missing  
2. Run only what you need, e.g. **`supabase/migrations_017_018.sql`** (claim approval + security)

**Nuclear reset (empty schema, then run everything once):**

```sql
DROP SCHEMA IF EXISTS reer_sh_yoonis CASCADE;
-- then run all_migrations.sql, then seed_family.sql
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

The sample lineage from your CSV is at `data/family_tree.csv` (**261 members** from the final SHEEK YOONIS CSV).

Load it into Supabase:

```sql
-- Run in SQL Editor (after 001_initial_schema.sql)
-- Paste contents of supabase/seed_family.sql
```

**Full reset (corrupted tree, wrong member count, start over):**

1. Run `supabase/reset_fresh_start.sql` — deletes all profiles, payments, treasury rows, and app auth users
2. Run `supabase/seed_family.sql` — loads exactly **261** members from the final CSV
3. Run `supabase/migrations/017_security_and_claim_requests.sql` if not applied yet
4. Sign up, submit your profile link request, then bootstrap super admin:

```sql
-- Paste supabase/bootstrap_super_admin.sql (approves your claim + sets super_admin)
```

Or promote the **login profile** (not the tree row — phone may be empty until approved):

```sql
UPDATE reer_sh_yoonis.profiles
SET role = 'super_admin'
WHERE auth_user_id = (
  SELECT id FROM auth.users WHERE email LIKE 'rsy.252634749276@%'
);
```

Then in the app: **Approve my profile link** on the waiting screen.

Or sync from the latest download and regenerate:

```powershell
powershell -File scripts/sync_csv_from_download.ps1
powershell -File scripts/generate_seed.ps1
```

Tree structure from the spreadsheet:

| Column | Meaning |
|--------|---------|
| GRANDPARENT | Patriarch (Sheekh Yonis) |
| UNCLE | His sons |
| CHILD | Grandchildren |
| GRANDCHILD+ | Deeper generations (columns E–N) |

**Re-seeding only** (keep auth accounts, replace tree data):

```sql
DELETE FROM reer_sh_yoonis.profiles WHERE auth_user_id IS NULL;
-- then paste supabase/seed_family.sql
```

All members are inserted as `family_member` / `adult` with `father_id` links. Update roles, demographics, phones, and care ratings in the app or via SQL after seeding.

### Profile linking (admin approval required)

After migration `017_security_and_claim_requests.sql`:

1. Member signs up and selects their name from the tree
2. Request goes to **Verification Queue → Profile links** (super admin only) for approval
3. Only after approval is `auth_user_id` linked to the tree profile

Direct self-claim is disabled. New tree members are added by admins via **Add family member**.

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
