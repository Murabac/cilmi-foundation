# CILMI Foundation — redesign spec

Mockups: `png/` (screenshots, 390×844 phone) and `html/` (open in a browser; exact sizes, colours, text). Logo files: `assets/brand/`.
Look: Somali-first, calm, modern, trustworthy. Solid deep-teal headers, warm linen background, white cards, gold for the one main action. No patterns, no gradients.

## Colour tokens

| Token | Hex | Use |
|---|---|---|
| teal (primary) | `#0F3D3E` | headers, primary buttons, bottom bar, selected states |
| tealMid | `#1F6F6B` | links, secondary icons, progress |
| mint | `#DCEBE7` | icon tiles, soft buttons, selected chip background |
| gold (accent) | `#C9A227` | ONE main action per screen ("Hadda bixi"), active bottom-bar tile, "you" highlight |
| onGold | `#1E1A0B` | text/icons on gold |
| linen (background) | `#F4F1EA` | page background, stat tiles |
| surface | `#FFFFFF` | cards |
| border | `#E3DDD0` | card borders, dividers |
| ink (text) | `#16302F` | main text |
| muted | `#56625F` | secondary text (passes 4.5:1 on white) |
| onTealMuted | `#C9DAD6` | secondary text on teal |
| paid / calm | `#1E7A4C` | paid, "Deggan" |
| pending / stress | `#B26A00` (text `#9A5B00`, bg `#FBEFD9`) | pending, "Cadaadis" |
| urgent / unpaid | `#B42318` (bg `#FBE4E1`) | unpaid, "U baahan gargaar", reject |

## Typography

Font: **Manrope** (`google_fonts`). Weights 500 / 600 / 700 / 800.

| Style | Size / weight |
|---|---|
| Screen title (in header) | 24 / 800 |
| Big name (home greeting) | 28 / 800 |
| Money hero | 40–44 / 800, teal |
| Card title | 17 / 800 |
| Body | 15–16 / 600 |
| Secondary | 13.5–14.5 / 500–600, muted |
| Section label | 13 / 800, letter-spacing 0.06em, UPPERCASE, muted |
| Chip / pill | 13 / 700 |

## Shape and spacing

- Card: white, 1 px border `#E3DDD0`, radius 20, padding 18. Hero card may add shadow `0 8 24 rgba(15,61,62,.08)`.
- Buttons: height 54, radius 14, 17/700. Primary = teal; main action = gold with onGold text; secondary = white with 1.5 px teal border; soft = mint with teal text.
- Inputs: height 54, radius 14, white, 1 px border.
- Pills: height 26, radius 13 (paid green / pending amber / unpaid red, tinted backgrounds as above).
- Page padding 16; gap between cards 14.
- Avatars: circle with initials on mint; "you" = teal fill + white text + gold ring.

## Header (all main screens)

Solid teal block at the top (no AppBar shadow), 20 px padding, title 24/800 linen-white, subtitle 14.5 `#C9DAD6`, round 48 px outline icon button on the right (search / bell). On Home the header is taller and the first card overlaps it by ~50 px.

## Bottom bar

Floating, inset 14 px left/right and 16 px from bottom. Height 72, radius 26, background teal, shadow `0 16 36 rgba(15,61,62,.38)`. Four items: **Hoyga** (home) · **Qoyska** (tree) · **Bixi** (wallet) · **Aniga** (person). Labels always visible, 13 px. Active item = gold tile (radius 20, height 60, slightly wider) with dark icon + label; inactive = `#BFD9D4` icon + label. Admin areas are NOT tabs: they open from the Home "Maamulka" card and staff shortcuts. Bixi tab only for members on the payers list (exempt members see the exempt view or no tab — keep current logic).

## Screens

1. **Login** (`01-login`): full teal background; centred stacked logo (reversed) + tagline "Taageero · Isku-duubni · Daryeel"; linen card at the bottom with title "Soo dhawoow", phone + password fields, teal "Gal" button, "Samee Akoon" link; language switch under the card.
2. **Home** (`02-home`): teal header with small logo, bell, "Subax wanaagsan," + member name. Overlapping white card: this month's contribution, status pill, amount 40/800, gold "Hadda bixi" button (payers only). 2-column quick links (Geedka qoyska, Taariikhda lacag bixinta). Monthly status card (from `MonthlyStatusCard`). "Xaaladda Qoyska" stat tiles. Staff only: "Maamulka" card with rows (Qaybta Xaqiijinta, Sanduuqa, Liiska Daryeelka) + shortcuts (Maaree Xubnaha, Warbixinta xaaladda, WhatsApp).
3. **Family tree — Geed** (`03-family-tree`): header "Geedka Qoyska" + "Reer Sheekh Yoonis · N xubnood" + search. Segmented control Geed | Abtirsiin | Liis. Lineage breadcrumb chips (older ancestors scroll off left, current person gold). White card "Reerka {father}" with "Jiil kor" button and a diagram in 3 generation rows, each labelled on the left (J5 Aabbe / J6 Adiga / J7 Carruur): father on top; you + siblings in the middle (you larger, teal, gold ring; "+N" dashed circle for more siblings); children at the bottom; grey connector lines (vertical stem + horizontal bar + drops). Each node: initials avatar with care-status dot, name, relation. Legend under the card. Tap node → member card.
4. **Family tree — Abtirsiin** (`04-lineage`): card "ABTIRSIINTAADA" with the full nasab as one big line ("Axmed bin Cabdi bin … bin Cilmi"), buttons "La wadaag" (WhatsApp share) and "Ka eeg geedka". Below, numbered vertical timeline from the founder (1) down to you (gold), each row a white card with name, "Ina {father}", descendant count, chevron.
5. **Member card** (`05-member-card`): bottom sheet over dimmed tree. Avatar + name + relation pill (gold tint, e.g. "Walaalkaa · ka weyn"), close button. Dashed box "ABTIRSIIN" with lineage. Chips (marital, city, job). Stat tiles (carruur, farac, jiilka). Wac + WhatsApp soft buttons, teal "Eeg laantiisa geedka".
6. **Bixi / Give** (`06-give`): header "Qaadhaanka Billaha" + month. Card: amount (member's own `monthly_amount`), status pill, ZAAD / e-Dahab radio cards, 2 numbered steps, gold "Hadda bixi" (USSD dial), outline "Waan bixiyay — ogeysii maamulka". History card with paid / pending pills.
7. **Admin & treasury** (`07-admin-treasury`): teal header with balance hero, inflow/outflow tiles; soft action buttons (Ku dar Sanduuqa, Diiwaangeli Gargaar); verification card with Ansixi (teal) / Diid (outline, red text); payment report progress bar + counts.

Sample names and `[#]` values in the mockups are placeholders — always show real data.
