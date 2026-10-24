# CILMI FOUNDATION — Google AI Studio redesign prompt

Paste everything under **Prompt** into [Google AI Studio](https://aistudio.google.com). It asks for a visual system and phone mockups only. Features, roles, and the navy / gold / tree brand stay the same.

---

## Prompt

You are a senior product designer. Redesign the mobile app **CILMI FOUNDATION** so it looks like a modern, trusted nonprofit product (2026), not a dated Material template. Do not invent new features. Do not remove features. Output a design system plus high-fidelity phone screens (390×844) as HTML/CSS mockups I can screenshot. English UI first; note Somali label alternatives where space is tight.

### What the app is

Private family community app for the Cilmi Foundation (Somali family lineage and mutual aid). Members see their place in the family, pay a monthly contribution, and keep a profile. Admins verify payments, manage a treasury, and maintain the tree.

Roles:

- Family member (adults pay; children do not)
- Manager (care + payment verification)
- Treasury
- Super admin (settings, add members, language)

Languages: English and Somali. Same screens; only copy changes.

Logo: open book with a green tree growing from it, navy and gold arcs. Keep this mark. Do not replace it with a generic icon.

### Brand (keep, use with restraint)

- Navy `#102850` — text, primary buttons, key headers
- Gold `#B89020` — small accents only (one highlight, not large fills)
- Leaf green `#2F7D32` — growth, paid, healthy
- Warm off-white `#F6F4EF` — page background (not yellow cream)
- White cards, hairline border `#E6E1D6`, soft shadow
- Amber `#F59E0B` — needs attention
- Red `#DC2626` — urgent care / rejected
- Type: a clean humanist sans (Plus Jakarta Sans or similar). Large names, quiet labels. No all-caps walls of text.
- Radius 16–20 on cards, 12 on buttons. Plenty of space. One idea per card.

Avoid: beige paper look, thick navy bars on every screen, gold everywhere, crowded icon-only tabs, default Material list tiles, stock “dashboard widgets” that look like an admin template.

### Navigation

Bottom bar, max 4 items, labels always visible:

1. Home
2. Family
3. Give (adults only; hide for children)
4. Profile

Managers and admins reach Payments, Treasury, Verification, and Settings from Home action cards and Profile — not extra bottom tabs.

Top of main screens: no heavy navy bar. Small logo + screen title on the warm background. Sign out lives in Profile.

### Screens to design

1. **Sign in / register** — phone + password. Calm, logo centered, one primary button. Short line: family lineage and mutual aid.
2. **Claim profile / pending approval** — member finds their name in the tree and waits for admin approval. Clear status, not a form dump.
3. **Home (member)** — greeting with first name; this month’s contribution status (paid / due / waiting); shortcut to Give; “Your place in the family” card; care status if relevant.
4. **Home (admin)** — same member header, plus compact stats (members, collected this month, pending verification, treasury balance) and action rows: Verify payments, Treasury, Payment report, Add member, Settings.
5. **Family tree** — the signature screen. Focused lineage: parents above, selected person in the center, spouse/siblings beside, children below. Person cards with photo or initial, name, and a small care dot (green ok, amber watch, red urgent). Branch and father filters as chips, not a dense form. Chart and list modes.
6. **Give / contributions** — amount due, month, two clear pay choices side by side: ZAAD `484594` and e-Dahab `764043`, each with a Pay button that dials USSD. Then “I’ve paid — notify admins.” History as a simple timeline.
7. **Payment report (admin)** — month summary, filters, list of who paid / pending / rejected. Easy to scan on a phone.
8. **Verification queue** — pending claims and payment proofs. Approve / reject with a short reason. Empty state that feels finished.
9. **Treasury** — balance, inflows, outflows, add outflow. Audit feel: calm numbers, not a spreadsheet.
10. **Profile** — photo, name, family links, city, occupation, marital status, care rating (members see own; managers can set). Link “View in family.”
11. **Admin settings** — adult monthly rate, ZAAD and e-Dahab numbers and USSD codes, app language (EN/SO), family tree default view. Grouped sections, not one long form.
12. **States** — loading, empty, error, and rejected payment. Short Somali-friendly copy, no raw error codes.

### Quality bar

Each screen should look publishable on the Play Store: generous margins (20px), readable at arm’s length, obvious primary action, status color used once per card. Show member Home, admin Home, Family tree, and Give as the hero set. Then the remaining screens in the same system.

At the end, list the design tokens (colors, type sizes, spacing, components) so a Flutter developer can implement them in `lib/theme/app_theme.dart`.
