# Dfile Mobile — design spec

Dfile is a bilingual (EN/AR) freelancer ledger: clients, projects, payments, invoices. This Flutter app is the
mobile version of the existing React web app. Amounts are in DZD ("DZ"). The design was made in FigCraft;
`docs/design/screens/*.png` are the exact renders (390x844 logical px, exported at 2x). **Match them closely.**
`docs/design/dfile-mobile-v4-prototype.figcraft` is the source file (do not edit).

All data is local mock data for now. No Firebase, no network calls. Auth is faked: any input succeeds.

## Tokens

| Token | Value |
| --- | --- |
| bg (cream) | `#FBF7F0` |
| ink | `#1B1B1F` |
| mute | `#6B6B76` |
| placeholder | `#A8A8B3` |
| card (white) | `#FFFFFF` |
| line (borders) | `#E8E1D5` |
| seg (segmented bg, neutral chips) | `#EFE9DD` |
| orange | `#F4955F` |
| purple | `#8F81EE` |
| yellow | `#FFD557` |
| coral | `#F0675A` |
| green / greenBg | `#1E8A4C` / `#E4F6E9` |
| red / redBg | `#D32F2F` / `#FFF0F0` |

- Font: Inter (use the `google_fonts` package). Weights: Regular, Medium (500), Bold (700). Title 32 bold; section
  title 22-28 bold; body 15-17; caption 12-13.
- Page gutter 24. Primary button: height 56, fully rounded (radius 28), ink fill, white 17 bold label.
  Secondary button: white fill, 1.5 `line` border, ink label.
- Cards: white, radius 24 (cards inside lists) or 20, 1.5 `line` border, no shadow.
- Inputs: height 56, radius 16, white fill, 1.5 `line` border, 13 `mute` label above, 16 text.
- Search field: height 52, radius 26. Pills: radius = height/2. Icon buttons: 44 circle, white, 1.5 `line` border.
- Bottom tab bar: white, 1px `line` top border, height 80, 4 tabs (Home, Projects, Clients, More); Clients active.
- Bottom sheets: radius 36 on top corners, `bg` fill, 60x5 grabber, scrim `#1B1B1F` at 50% over the screen below.
- Mascot art: `assets/images/mascots.png` (transparent PNG, aspect 2000:1682). It sits on a coloured rounded panel
  (radius 36): Welcome = yellow, Onboarding = orange / purple / coral, Forgot = orange, OTP = purple.
- Google "G": `assets/images/google_g.svg` (use `flutter_svg`), 22px, left of the label "Continue with Google".

## Screens and flow

Auth flow (files `1`..`8` in `docs/design/screens/`):

1. Welcome: mascot panel, "Dfile", subtitle "Your clients, projects and payments in one pocket-sized ledger.",
   [Get started] -> Onboarding 1, link "I already have an account" -> Sign in.
2. Onboarding x3 (PageView, dots indicator, active dot is a 24px ink pill, others 8px `line`): titles "Know every
   client", "Get paid, on time", "Friends' debts, settled". [Next] / last = [Let's start] -> Sign up. "Skip" -> Sign in.
3. Sign in: email, password, "Forgot password?" -> Forgot, [Sign in] -> Clients list, [Continue with Google] ->
   Clients list, "New here? Create an account" -> Sign up.
4. Sign up: full name, email, password, [Create account], [Continue with Google] -> Clients list, link -> Sign in.
5. Forgot password: back button, orange mascot panel, email, [Send code] -> OTP, "Back to sign in".
6. Verify code (OTP): 6 boxes (48x60, radius 14, first one focused with a purple 2px border), "Resend in 0:30" countdown,
   [Verify] -> Sign in, "Change email" -> Forgot.

Client management (files `C1`..`C12`):

- C1 Clients list: title, "N clients in your workspace", "+" button (ink circle) -> Add client. Search field,
  filter pills All / Active / Inactive, "Sort: Name" control. Client cards: avatar circle with initial, name, "Added:
  date", status pill (Active green / Archived grey), revenue "245,000 DZ", "N active projs", social dots. Tap card ->
  detail. All filtering, search and sorting must really work on the mock data.
- C2 Empty state "No clients found" with [+ Add client].
- C3 Sort sheet: Name (A-Z), Highest revenue, Newest first (radio rows). C4 Actions sheet: View profile, Edit client,
  Copy email, Delete client (red). C5 Delete confirm sheet (red warning box, [Confirm delete], [Cancel]).
  C6 = list after deletion with a dark toast "Client deleted successfully".
- C7 Client detail: back, "⋯" (opens C4), avatar, name, joined, status pill, 3 quick actions (Call, Email, Copy),
  contact card with Copy links, 4 finance tiles (budget -> Projects tab, cleared -> Payments tab), [Edit client].
  C8 Projects tab (status chips, progress bars). C9 Payments tab (green rows, total).
- C10 Add client (Quick: name only), C11 Add client (Advanced: email, phone, address, 4 social links, notes),
  C12 Edit client (advanced, prefilled). Quick/Advanced toggle is a segmented control; ✕ closes.

Sample data to ship in the mock repository (4 clients, matching the screenshots):
Mohamed Bachir (2026-03-14, 245,000 DZ, 2 active, orange avatar), Sarah Benali (2026-05-02, 120,000, 1 active, purple),
Nova Studio (2026-06-20, 0, archived, yellow), Karim Haddad (2026-08-11, 68,500, archived, coral).

## Architecture rules

- Feature-first folders: `lib/core/` (theme, widgets, router), `lib/features/auth/`, `lib/features/clients/`.
- Routing with `go_router`. State with plain `ChangeNotifier` + `ListenableBuilder` (no extra state packages).
- Reusable widgets in `lib/core/widgets/` (primary/secondary button, text field, pill, icon button, avatar, bottom
  sheet scaffold, toast, tab bar).
- No hard-coded colours outside `lib/core/theme/`. Strings live in one place per feature so Arabic can be added later.
- Never commit. The orchestrator reviews and commits.

## Project management (files `P1`..`P18` in `docs/design/screens/`)

Source file: `docs/design/dfile-mobile-v5-projects.figcraft` (do not edit). Statuses: Planned, In Progress,
Waiting Client, Completed, Delivered, Cancelled. "Active" = In Progress or Waiting Client. Status chip colours:
Planned grey (seg/mute), In Progress orange on `#FFF0E4`, Waiting Client purple on `#EFEBFF`, Completed green on
greenBg, Delivered ink fill + white text, Cancelled red on redBg. Progress/paid bars: orange while money is due,
green when cleared.

- P1 Projects list (tab "Projects" active): title, "N projects in your portfolio", "+" button, 3 summary tiles
  (Portfolio value, Avg progress, Active), search (name/client/category), status pills (All, Planned, In Progress,
  Completed, Delivered; In Progress includes Waiting Client; the row scrolls horizontally), count + "Filter" +
  "Sort: <label>" row, project cards (client, name, status chip, category chip, "Due <date>", "Paid: x DZ",
  "Due: y" or green "Cleared", paid bar). P2 no results ("No projects match your filters", [Clear filters]).
- P3 Sort sheet: Newest first, Name (A-Z), Highest budget, Progress, Nearest deadline. P4 Filter sheet: Category,
  Client and Status chips, Reset, [Apply filters], [Cancel].
- P5 Detail Overview, P6 Tasks, P7 Payments (3-way segmented toggle). Overview: progress card, tiles Budget / Paid /
  Remaining / Timeline, description, bottom bar [+ Add payment]. Tasks: checklist (toggle done, status chip),
  bottom bar with "Add a new task..." field and "+". Payments: paid-so-far card with bar, payment rows, [+ Add payment].
- P8 Actions sheet (Edit project, Change status, Add payment, Delete project red). P9 Change status sheet (radio
  rows, Completed/Delivered force progress 100%, [Update status]). P10 Delete confirm (tasks removed, payments kept).
  P11 list after delete with toast "Project deleted successfully".
- P12-P16 Add project wizard: 4 steps (Details, Client & Cost, Tasks, Status) with step indicator, Back/Next,
  last step [Save project]. P14 = "+ Quick add client" variant (name only, creates a client). P17 Edit project
  (single scrolling form, [Save changes]). P18 Record payment sheet (amount, date, reference, remaining preview).
- Money: thousands separators + " DZ". Mock data: Fintask Landing Page (Mohamed Bachir, Development, In Progress 65%,
  450,000, paid 245,000, Jul 01 - Aug 30), Brand Identity (Sarah Benali, Design, Waiting Client 40%, 180,000, paid
  60,000), Mobile App UI (Mohamed Bachir, Design, Completed, 320,000, paid 320,000), Logo Pack (Nova Studio,
  Branding, Delivered, 40,000, paid 40,000), Dashboard Redesign (Sarah Benali, Design, Planned, 95,000, paid 0).

## Payment management (files `PY1`..`PY12` in `docs/design/screens/`)

Source file: `docs/design/dfile-mobile-v6-payments.figcraft` (do not edit). Payments live under the "More" tab
(tab bar index 3, More active on all payment screens).

- Model: Payment = id, projectId, clientId, amount, type (advance / milestone / final / tip), method (baridimob / ccp /
  bank / cash), reference (optional), notes (optional), date, createdAt. Labels: Advance, Milestone, Final, Tip;
  BaridiMob, CCP, Bank wire, Cash. Method badge colours: BaridiMob purple on `#EFEBFF`, CCP ink on `#FFF3CC`, Bank
  wire orange on `#FFF0E4`, Cash green on greenBg. Type pills are neutral (seg + ink).
- Derived (PaymentsRepository): collected = sum of amounts; outstanding = sum over non-Cancelled projects of
  max(0, price - paid); this month = payments dated in the current calendar month; collection rate =
  min(100, round(collected / sum of all project prices * 100)), 100 when there are no projects.
- PY1 More menu: workspace card, rows Payments ("N DZ collected"), Expenses, Invoices, Friends' debts, Settings
  (only Payments is functional, the others show a "Not available in the demo" toast), red "Sign out" -> /sign-in.
- PY2 list: back, "Payments", "N payments recorded", "+" -> record form, 4 KPI tiles, search (client / project /
  reference / notes), method pills (All, BaridiMob, CCP, Bank, Cash; row may scroll), "N payments" + "Sort: <label>",
  payment cards (avatar initial, client, project, +amount green, method badge, type pill, date, reference or dash).
  PY3 empty ("No payments logged yet", [+ Record first payment]); with a search/filter and no match show "No payments
  match your filters" + [Clear filters]. PY4 sort sheet: Newest first, Oldest first, Highest amount, Lowest amount.
- PY5 receipt: amount, type pill, client, project, method badge, reference, date, project budget / paid to date /
  remaining, notes, bottom [Share receipt] (toast "Not available in the demo"). PY6 actions sheet: Copy reference
  (Clipboard + toast "Copied reference!"), Go to project -> /projects/:id, Share receipt, Delete payment (red).
  PY7 delete confirm; PY8 list after delete with toast "Payment deleted successfully".
- PY9 record payment form (route /payments/new, optional query `projectId` to preselect): client select (required),
  project select filtered by client, showing "Due x DZ" (required), amount (required, > 0, shows error "Please enter a
  valid amount greater than zero") with a "100% full" chip filling the remaining balance, method tiles (BaridiMob
  default), type select, date (default today), reference, notes. PY10 error state. PY11 project picker sheet.
  [Record payment] saves, pops to the list and shows toast "Payment recorded".
- Mock data: 6 payments consistent with the project mock data: Sarah Benali / Brand Identity +60,000 BaridiMob Advance
  2026-10-12 TXN-552104; Mohamed Bachir / Fintask Landing Page +60,000 CCP Milestone 2026-07-09 CCP-5521, +85,000
  BaridiMob Milestone 2026-05-18 TXN-441872, +100,000 BaridiMob Advance 2026-04-02 TXN-928471 (notes "Received after the
  first milestone delivery."); Mohamed Bachir / Mobile App UI +320,000 Bank wire Final 2026-06-12 WIRE-7783; Nova Studio /
  Logo Pack +40,000 Cash Final 2026-05-20 (no reference).
