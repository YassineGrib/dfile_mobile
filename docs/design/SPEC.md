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

## Expense management (files `EX1`..`EX13` in `docs/design/screens/`)

Source file: `docs/design/dfile-mobile-v7-expenses.figcraft` (do not edit). Expenses live under the "More" tab
(More active on all expense screens). Amounts are shown negative in red: "-4,500 DZ".

- Model: Expense = id, description, category (Software/Tools, Hosting/Services, Marketing, Equipment, Others),
  amount, projectId (nullable = general business cost), method (reuse PaymentMethod: baridimob / ccp / bank / cash),
  reference (optional), notes (optional), date, createdAt. Category chips: Software purple on `#EFEBFF`, Hosting
  orange on `#FFF0E4`, Marketing coral on `#FFE9E6`, Equipment green on greenBg, Others grey (seg + mute); the round
  category icon shows the category initial in the same colours. Method badges as in payments.
- Stats (ExpensesRepository): total = sum; projectLinked = sum and count of expenses with a project; thisMonth = sum of
  the current calendar month; average = round(total / count), 0 when empty. Filters: category (All + 5), project link
  (All / Project linked / General costs), search over description, category label, project name, reference, notes.
  Sorts: Newest first, Oldest first, Highest amount, Lowest amount.
- EX1 list: back, "Expenses", "N expenses logged", "+" -> record form, 4 KPI tiles (Total outlays red, Project-linked
  orange, This month purple, Average outlay), search, category pills (All, Software, Hosting, Marketing, Equipment,
  Others; row scrolls), "N expenses" + "Filter" + "Sort: <label>", expense cards (category icon, description, project
  name or "General cost", -amount red, category chip, method badge, date, reference or dash). EX2 empty ("No expenses
  logged yet", [+ Record first expense]); filters with no match -> "No expenses match your filters" + [Clear filters].
  EX3 sort sheet; EX4 filter sheet (Category chips, Project link chips, [Apply filters], [Cancel], Reset).
- EX5 detail: category icon, description, category label, big red amount, rows Category (chip), Project (or General
  cost), Method (badge), Date, Reference, Notes (only when set), bottom [Edit expense]. EX6 actions sheet: Edit expense,
  Copy reference (toast "Copied reference!", "No reference to copy" when empty), Go to project (only for linked
  expenses, else hide the row), Delete expense (red). EX7 delete confirm; EX8 list after delete, toast "Expense deleted
  successfully".
- EX9 record form (/expenses/new, optional query `projectId` preselects the project), EX12 edit form (/expenses/:id/edit,
  prefilled, [Save changes]): amount with DZD chip (required, > 0, error "Please enter a valid amount greater than zero"),
  5 category tiles (required), description (required, error "Please describe the expense"), linked project select
  (optional; EX11 sheet lists "General business cost" + every project, radio, [Confirm]), 4 method tiles (default
  BaridiMob), date (default today) and reference halves, notes. EX10 shows the error state. Save -> list with toast
  "Expense recorded" / edit -> detail with toast "Changes saved".
- Mock data (7): Figma Pro plan, Software/Tools, general, 4,500, CCP, 2026-10-15, INV-802; Domain renewal,
  Hosting/Services, general, 3,200, BaridiMob, 2026-10-03, RCPT-441; Instagram ads, Marketing, Brand Identity, 12,000,
  BaridiMob, 2026-09-20, AD-2291 (notes "Campaign for the brand launch week."); Stock photos pack, Marketing, Fintask
  Landing Page, 6,500, Cash, 2026-08-11, no ref; Monitor 27 inch, Equipment, general, 38,000, Bank wire, 2026-07-02,
  INV-611; VPS hosting (yearly), Hosting/Services, Fintask Landing Page, 18,000, CCP, 2026-06-14, VPS-330; Coworking
  pass, Others, general, 9,000, Cash, 2026-05-05, no ref. Totals: 91,200 / project-linked 36,500 (3) / this month
  (Oct 2026) 7,700 / average 13,029.

## Friends' debts (files `FD1`..`FD16` in `docs/design/screens/`)

Source file: `docs/design/dfile-mobile-v8-friends.figcraft` (do not edit). Lives under More (More tab active everywhere).

- Model: Friend = id, name, phone, notes, createdAt, avatar colour index. FriendTransaction = id, friendId, type
  (money = "Money loan", service = "Service", expense = "Shared cost"), direction (lent = "Owed to me", borrowed = "I owe"),
  amount, paidAmount, description, dueDate (nullable), date, createdAt; status DERIVED: settled when paid >= amount,
  partial when 0 < paid < amount, pending when paid == 0. FriendSettlement = id, transactionId, friendId, amount,
  method (cash, baridimob, bank, serviceOffset), notes, date, createdAt. Remaining = amount - paid.
- Derived: friend net = sum(lent remaining) - sum(borrowed remaining) (positive = owed to you, green; negative = you owe,
  red; zero = Settled grey); overall net, owedToYou (sum of lent remaining), youOwe; per friend active count (non-settled
  transactions) and settled count; last activity date. Settling adds a FriendSettlement and increases paidAmount (cannot exceed
  remaining). Deleting a friend deletes their transactions and settlements; deleting a transaction deletes its settlements.
- Chips: Lent green on greenBg, Borrowed red on redBg; status Pending orange on `#FFF0E4`, Partial purple on `#EFEBFF`, Settled
  green on greenBg; method badges BaridiMob purple, Cash green, Offset orange, Bank grey. Net chip "Owed 45,000 DZ" / "You owe
  12,000 DZ" / "Settled".
- FD1 Friends / FD8 Transactions: ONE screen with back, "Friends' debts", "N friends" or "N transactions", "+" (add friend), overall
  net card (net big, "Owed to you x", "You owe y"), two-way toggle Friends / Transactions, search, pills (friends: All, Owe me, I owe,
  Settled; transactions: All, Owed to me, I owe, Settled) + for transactions the "N transactions" count and "Filter" (FD9: Direction,
  Status, Nature chips, [Apply filters] [Cancel] Reset). Friend cards (avatar, name, phone, net chip, "N active - M settled", "Last:
  date"); transaction cards (type icon, description, amount, "friend - type - date", direction + status chips, "Due mm-dd", [Settle]
  button unless settled, paid bar, "Paid x DZ", "Remaining y DZ" or green "Settled"). FD2 empty ("No friends yet", [+ Add friend]); no
  match states with [Clear filters].
- FD3 statement (/friends/:id): back, "Statement", "..." , avatar, name, phone, net card with chip, 4 stat tiles (Owed to you, You
  owe, Active, Settled), "Transaction history" + "+ Add" (record form with the friend preselected), transaction cards. FD4 actions
  sheet: Add transaction, Copy phone number (Clipboard + toast "Copied phone!", "No phone number" when empty), Open transactions
  (Transactions tab of the list, filtered by this friend's name in search), Delete friend (red) -> FD5 confirm -> list + toast "Friend
  deleted successfully".
- FD7 add friend (/friends/new): name (required, error "Please enter the friend name"), phone, notes; [Save friend] -> list + toast
  "Friend added".
- FD10 transaction detail (/friends/transactions/:id): icon, description, "friend - type", big amount, chips, paid bar, rows Paid,
  Remaining, Date, Due date, "Settlements (N)" rows (date, method badge, +amount), bottom [Delete] (red) and [Settle payment]
  (hidden/disabled when settled). FD15 delete confirm -> statement/list + toast "Transaction deleted successfully".
- FD11/FD12 record transaction (/friends/transactions/new, optional query friendId): friend select (sheet; "+ New friend" ->
  add friend), direction tiles (Owed to me / I owe), nature tiles (Money loan / Service / Shared cost), amount (> 0, error "Please
  enter a valid amount greater than 0"), description (required, error "Please enter a description"), date (default today), due date
  (optional). [Save transaction] -> statement of that friend + toast "Transaction recorded".
- FD13 settle sheet (showSettleSheet(context, transactionId), reusable from statement, list and detail): summary (chip, Total / Paid /
  Remaining), amount (> 0 and <= remaining, "100% full" chip), method tiles BaridiMob / Cash / Offset / Bank, notes (required when
  method is Offset: "Offset service details"), date; [Confirm settlement] -> toast "Settlement recorded"; [Cancel].
- Mock data: friends Karim Boualam (+213 550 12 34 56), Yacine Mebarki (+213 661 45 78 90), Amine Saidi (+213 770 33 21 08), Lina
  Cherif (+213 555 98 76 54). Transactions: Karim lent money 50,000 "Cash via BaridiMob" 2026-09-02 due 2026-11-02 paid 20,000
  (settlements 2026-09-20 +12,000 BaridiMob, 2026-10-01 +8,000 Cash); Karim lent service 15,000 "Frontend UI design" 2026-10-05
  pending; Amine borrowed money 12,000 "Hosting bill split" 2026-10-10 due 2026-11-10 pending; Lina lent money 8,000 "Lunch and taxi"
  2026-08-14 fully settled (one settlement 8,000 Cash 2026-08-20); Yacine lent shared cost 25,000 "Server hosting bill" 2026-10-20 due
  2026-11-20 pending. Overall: net +58,000, owed to you 70,000, you owe 12,000; Karim net 45,000.

## Settings (files `ST1`..`ST16` in `docs/design/screens/`)

Source file: `docs/design/dfile-mobile-v9-settings.figcraft` (do not edit). Settings live under More (the More menu "Settings" row ->
/settings). State is IN MEMORY only (SettingsRepository, no new packages, resets on restart). Honest limits: there is no dark theme and no
Arabic UI yet, so choosing Dark / System / Arabic keeps the current selection and shows the toast "Dark theme is coming soon" / "Arabic is
coming soon"; fingerprint unlock is not available (toast "Not available in the demo", switch stays off).

- Model (SettingsRepository, ChangeNotifier + SettingsScope): profile (name "Yassine G.", designation "Independent designer", email
  yassine@decabyte.dz verified, phone "+213 550 12 34 56", address "12 Rue Didouche Mourad, Algiers"), language (en), themeMode (light),
  categories (Development, Design, Branding, Marketing, Consulting), legalClauses (the 3-clause text of ST7), pinEnabled + pin (nullable
  4 digits), biometricsEnabled (false), sessions (This phone "Samsung S24" active now, Office laptop "Chrome, Windows" 2 days ago),
  googleConnected (false), notifications (push true, deadlines true, payments true, tasks false), supportTickets (list), password (mock
  "demo123", used only to validate "current password").
- ST1 hub (/settings): back, "Settings", profile card (avatar initial, name, designation, email) -> profile, grouped rows Account,
  Preferences, Security, Integrations and cloud, Notifications, About and support, footer "Dfile  -  Version 1.0.0". Reads a toast from route
  extra ({'toast': ...}) like the other screens. ST16 = hub with toast "Profile updated successfully".
- ST2 profile (/settings/profile): name and designation required, email read-only with a "Verified" pill, phone, address; [Save details] ->
  go('/settings', extra {'toast': 'Profile updated successfully'}); "Change password" row -> /settings/password. ST3/ST4 password
  (/settings/password): current (non-empty and equal to the mock password, else error "Current password is incorrect"), new (>= 6 chars, error
  "Password must be at least 6 characters"), confirm (error "New passwords do not match"), "Show" toggles; [Update password] -> back with toast
  "Password updated successfully".
- ST5 preferences (/settings/preferences): Language segmented (English / Arabic), Appearance tiles (Light / Dark / System), rows Font style
  (value "Modern Studio Pro", toast "Not available in the demo"), Project categories "N categories" -> /settings/categories, Legal clauses
  template -> /settings/legal. ST6 categories: chips with remove, bottom field + "+" (duplicate error toast "Category already exists!", added toast
  "Category added", removed toast "Category removed."). The project add/edit forms must use this list as their category choices. ST7 legal
  (/settings/legal): multiline editor with character count, [Save clauses template] -> toast "Legal clauses updated".
- ST8 security (/settings/security): PIN switch (turning on opens the ST9 sheet, off clears the PIN with toast "PIN lock disabled"), "Change PIN"
  row (visible when on) -> ST9 sheet (4 dots + keypad 0-9 and backspace; [Save PIN] enabled at 4 digits; toast "PIN saved"), fingerprint switch,
  sessions card with [Terminate other sessions] (removes non-current sessions, toast "Logged out other sessions."). ST11 notifications
  (/settings/notifications): push master switch (off disables and dims the three below) and deadlines / payments / tasks switches; saved instantly,
  toast "Notification preferences saved".
- ST10 integrations (/settings/integrations): Cloud sync card (static "Connected", "Last synced 2 minutes ago"), Google Calendar [Connect account]
  / [Disconnect] (toggles googleConnected, toasts "Google account linked" / "Google Account unlinked."), Export and backup [Download workspace
  backup (JSON)] -> builds a JSON of clients, projects, payments, expenses, friends and settings categories, copies it to the clipboard, toast "Backup
  copied to clipboard".
- ST12 about (/settings/about): app card (version 1.0.0, build 42), rows Submit support ticket -> /settings/support, Privacy policy -> /settings/privacy,
  Terms and conditions -> /settings/terms, red "Sign out" -> ST14 confirm sheet ([Sign out] -> context.go('/welcome'), [Cancel]). ST13 support
  (/settings/support): subject and message required (errors "Please enter a subject" / "Please enter a message"), [Submit ticket] -> back with toast
  "Support ticket sent". ST15 policy page for privacy and terms (static text sections).

## Play Store compliance (files `PS1`..`PS10` in `docs/design/screens/`)

Source file: `docs/design/dfile-mobile-v10-compliance.figcraft` (do not edit). Google Play requires: an in-app way to delete the account and its data
(plus a web URL for deletion), a privacy policy link, consent to the terms at sign-up, and a clear data-use explanation.

- Settings hub gets a new row "Privacy and data" (subtitle "Export or delete your data") between Notifications and About and support -> /settings/privacy-data (PS1, PS2).
- PS2 Privacy and data (/settings/privacy-data): intro card "Your data belongs to you", rows Privacy policy -> /settings/privacy, Terms and conditions -> /settings/terms, How we use
  your data -> /settings/data-usage, Export my data (same JSON backup copied to the clipboard as Integrations, toast "Backup copied to clipboard"), then a red DANGER ZONE card "Delete account" ->
  /settings/delete-account. PS10 data usage page (/settings/data-usage): static cards (Profile, Clients and projects, Payments and expenses, App settings: what and "Used for: ..."), chips Never sold / No ads /
  Encrypted / Deletable, a card "Delete your data any time" with the in-app path and the web URL text "decabyte.dz/delete-account".
- Delete account flow (re-authenticated, two steps, no dark patterns):
  PS3 (/settings/delete-account): red warning card "This is permanent", list "What will be deleted" (profile and sign-in, clients and their contact details, projects tasks and payments, expenses,
  friends and their debts, app settings), "We keep no copy of your data after deletion."; bottom bar [Export first] (copies the JSON backup, toast "Backup copied to clipboard", stays) and [Continue]
  (red) -> /settings/delete-account/confirm.
  PS4/PS5 (/settings/delete-account/confirm): optional Reason select (bottom sheet: Not using the app, Privacy concerns, Found an alternative, Too complicated, Other), field "Type DELETE to confirm"
  (exact, case-sensitive; error "Type DELETE exactly to confirm"), "Your password" with Show toggle (must satisfy SettingsRepository.checkPassword; error "Password is incorrect"), checkbox "I understand my
  account and data will be permanently deleted." (button dimmed and ignored until ticked), [Cancel] pops, [Delete my account] (red). On valid submit -> /settings/delete-account/progress.
  PS6 (/settings/delete-account/progress): spinner and five staged rows (Clients removed, Projects and tasks removed, Payments and expenses removed, Friends and debts removed, Profile and sign-in
  removed) that tick one by one over about 2.5 seconds while every repository is cleared (clients, projects with payments, expenses, friends, settings reset to defaults, PIN off, sessions cleared), back
  navigation disabled (PopScope). Then -> /account-deleted. PS7 (/account-deleted): yellow panel with a green check, "Your account was deleted", sentence, [Back to welcome] -> context.go('/welcome').
  After deletion the signed-in state is gone: reopening /clients shows an empty list.
- Sign-up consent (PS8/PS9, lib/features/auth/sign_up_screen.dart): checkbox row "I agree to the Terms and Privacy Policy" between the password field and [Create account]; "Terms" and "Privacy Policy" are
  tappable links (push /settings/terms and /settings/privacy). [Create account] AND [Continue with Google] require it: otherwise the checkbox gets a red border and the red text "Please accept the Terms and
  Privacy Policy to continue" appears and nothing navigates. Existing sign-up tests must be adapted (tick the box), the sign-in screen is unchanged.

## Dashboard / Home (files `HM1`..`HM8` in `docs/design/screens/`)

Source file: `docs/design/dfile-mobile-v11-dashboard.figcraft` (do not edit). The dashboard is the HOME TAB: route /home, tab bar index 0 (Home active), and
after Sign in / Sign up / Google the app goes to /home (not /clients). ICONS: use the Lucide icon library (Flutter package `lucide_icons_flutter`), NEVER emojis or
letter glyphs for the dashboard; the shared AppTabBar must also switch to real icons (Home = house, Projects = folder-kanban, Clients = users, More = ellipsis) with the active
tab drawn as an icon in ink on a 52x32 seg pill. Icon names used in the designs (Lucide): house, folder-kanban, users, ellipsis, bell, plus, banknote, receipt, folder-plus,
user-plus, wallet, clock, hand-coins, trending-up, trending-down, arrow-up-right, arrow-down-right, chevron-right, calendar-clock, circle-check, triangle-alert, arrow-left,
arrow-right-left, sparkles, message-square.

Data comes from the existing repositories (no new mock data except the notification read-state): ClientsRepository, ProjectsRepository (projects, payments, paymentStats),
ExpensesRepository (expenseStats), FriendsRepository (overallBalance), SettingsRepository (profile first name). All calculations are PURE functions taking a `now` DateTime
so tests are deterministic (lib/features/dashboard/data/dashboard_stats.dart).

- Greeting: "Good morning" before 12:00, "Good afternoon" before 18:00, else "Good evening", plus the first word of the profile name. A brand new account (no clients, no
  projects, no payments, no expenses, no friends) shows the empty home HM7: "Welcome", a yellow "Set up your ledger" card with a progress bar "N of 3" (steps: has a
  client / has a project / has a payment; each step row has an icon, title, subtitle and a ring that becomes a green check when done and opens the matching create route:
  /clients/new, /projects/new, /payments/new), and a "Your numbers" strip (Net profit 0 DZ, Pending 0 DZ). Once all 3 steps are done the normal home is shown.
- HM1 top bar: avatar initial (orange), greeting + name, bell button (red dot when there is any unread notification) -> /home/notifications, "+" ink button -> quick-add
  sheet HM6. Hero card (ink, radius 32): wallet icon, "Net profit" + "All time", net = all-time payments collected minus all-time expenses (value like "573,800 DZ", white
  34 bold; negative shows a minus), delta chip "52,300 this month" (this month inflow minus this month outflow; green with trending-up, red with trending-down when
  negative), a 6-bar mini chart (last 6 months net, last bar yellow) and "Last 6 months"; tap -> /home/profit. KPI row (horizontal scroll, cards 150x100): Active projects
  (count), Monthly expenses (this month outflow), Pending invoices (paymentStats outstanding), Friends owe you (overallBalance.net, green or red). Quick actions: 4 tiles
  (Record payment banknote -> /payments/new, Add expense receipt -> /expenses/new, New project folder-plus -> /projects/new, Add client user-plus -> /clients/new).
  Upcoming deadlines: up to 3 projects that are not Completed / Delivered / Cancelled and have an end date, ascending; each card shows triangle-alert on red with the pill
  "Overdue Nd" when past, calendar-clock on orange with "Nd left" when within 7 days, neutral grey "Nd left" otherwise, "Today" when 0; tap -> /projects/:id; "See all" ->
  /projects. Section order on the scrolling home: header, hero, KPI row, Quick actions, Upcoming deadlines, Cashflow card, Projects by status card, Recent activity, Friends
  debts card (HM1, HM2, HM3 are three scroll positions of ONE screen).
- HM2 Cashflow card: "Cashflow", range toggle 6 mo / Year, three legend totals (Inflow green, Outflow coral, Net ink) for the range, grouped bar chart (inflow green, outflow
  coral, one group per month, the best inflow month highlighted with a dark value bubble like "+320,000"), hint "Tap to see every month" -> /home/cashflow. 6 mo = the 6 calendar
  months ending with the current month; Year = January to December of the current year (12 groups, narrower bars). Projects by status card: donut (Delivered green, Completed light
  green, In progress purple, Waiting client orange, Planned grey; Cancelled not shown) with the total in the centre and a legend with counts.
- HM3 Recent activity (card, up to 4 rows, newest first) built from real records: payments ("Payment received", client - project, +amount green, date), expenses ("Expense
  added", description, -amount red), friend settlements ("Settlement received" / "Settlement paid", friend, +/- amount), projects whose status is In Progress ("Project started");
  icons circle-check / receipt / arrow-right-left / folder-kanban in the tinted bubbles of the design; "See all" -> /home/notifications. Friends debts card: net balance on the
  right, chips "Owed 70,000" (green, arrow-down-right) and "You owe 12,000" (red, arrow-up-right), tap -> /friends.
- HM4 Cashflow detail (/home/cashflow): back, "Cashflow", segmented toggle "Last 6 months" / "This year", chart card with legend totals and the chart, "MONTH BY MONTH" card with a
  row per month (newest first): month, +inflow, -outflow, net (green / red / ink), values in thousands like "+320k".
- HM5 Notifications (/home/notifications): back, "Notifications", "Mark all read"; groups TODAY and EARLIER; items derived from data: deadline warnings (project due within 3 days
  or overdue: calendar-clock orange / triangle-alert red), overdue friend debts (a lent transaction with a past due date and remaining > 0: wallet red, "Payment overdue",
  "<friend> owes you N DZ"), recent payments (circle-check green). Each shows a title, subtitle, relative time ("2h ago" / "Oct 12") and a coral dot when unread; tapping
  marks it read and opens its target (project / friend statement / payment receipt). The read state lives in an in-memory NotificationsStore (ChangeNotifier) provided like the
  other scopes. Respect the Settings notification switches: when push is off or a category (deadlines / payments) is off, hide those items.
- HM6 quick add sheet: title "Create new", 4 rows (Record payment, Add expense, New project, Add client) each with a tinted icon bubble, title, subtitle and a chevron-right;
  opened by the "+" button; choosing a row closes the sheet and navigates.
- HM8 Profit (/home/profit): back, "Profit", ink card with the all-time net, a margin bar (net / revenue as a percentage, "Profit margin 86%"), "Revenue" and "Expenses";
  "TOP EARNING PROJECTS" (top 3 projects by amount paid, bar relative to the best) and "WHERE THE MONEY GOES" (top 3 expense categories by amount, bar relative to the largest).
- UX rules: numbers use the money formatter; every card is tappable only where noted; lists handle empty data with a friendly line instead of an empty card; the home must not
  overflow on 360x800; chart bars may animate in once (300 ms) but tests must never hang (no infinite animations).

## Calendar (files `CL1`..`CL15` in `docs/design/screens/`)

Source file: `docs/design/dfile-mobile-v12-calendar.figcraft` (do not edit). The calendar lives under More (More tab active everywhere): a new "Calendar" row (Lucide calendar-days,
subtitle "Deadlines and milestones") in the More menu between Payments and Expenses -> /calendar. Icons: Lucide through lib/core/widgets/app_icons.dart (AppIcons; add the missing names:
chevronLeft, chevronDown, calendarDays, calendarClock, calendarCheck, play, milestone, trash2, refreshCw, gauge, check, x), NEVER emojis or letter glyphs.

Data: a NEW Milestone model (id, projectId, title, date, completed, createdAt) in a CalendarRepository (ChangeNotifier + CalendarScope, in memory, optional injection like the other
scopes) with seeds: Moodboard sign-off (Brand Identity, 2026-10-15, done), Client review (Brand Identity, 2026-10-28, done), Send invoice draft (Fintask Landing Page, 2026-10-30,
pending), Beta handoff (Fintask Landing Page, 2026-11-02, pending), Final delivery review (Dashboard Redesign, 2026-11-12, pending); actions addMilestone, toggleMilestone(id),
deleteMilestone(id), deleting a project removes its milestones (ProjectsRepository delete: handle it in the calendar by filtering milestones whose project no longer exists), plus the
sync prefs (googleConnected is read from SettingsRepository; lastSynced DateTime?, syncDeadlines true, syncMilestones true, syncDebts false). Everything is computed by PURE functions taking
`now` (lib/features/calendar/data/calendar_events.dart): `List<CalendarEvent> eventsFor(...)` where CalendarEvent = kind, title, subtitle, date, route (+ milestone id when relevant):
- deadline: every project that is not Cancelled with an end date; kind `over` (red, triangle-alert, "Nd overdue" pill) when end < today and the project is not Completed / Delivered, `due`
  (orange, calendar-clock, "Today" / "Nd left" pill) otherwise, `done` (grey, circle-check) when Completed / Delivered; title = project name, subtitle "Deadline <date>" or the client name;
- start: project start dates (purple, play) title "<project> starts";
- milestone: pending = green milestone icon with "Due today" / "Nd left" / "Nd overdue" pill, completed = `done` grey with "Done";
- debt: unsettled friend transactions with a due date: lent -> "<friend> owes you", borrowed -> "You owe <friend>" (coral, hand-coins), subtitle "<amount> DZ due".
Dot colours in the grid: over red, due orange, start purple, milestone green, done light grey (#B8B2A5), debt coral; max 3 dots per day.

- CL1-CL3 Calendar (/calendar): back, title "Calendar", [Today] pill (only when the shown month is not the current month), gauge button -> /calendar/capacity, "+" ink button ->
  /calendar/new; segmented Month / Agenda / Timeline (state kept while switching; /calendar?tab=agenda|timeline opens that tab). Month: prev / next month buttons, centred "October 2026" with a
  chevron-down (tap -> jump sheet CL15), weekday row S M T W T F S, 5 or 6 week rows (6 only when needed), today = ink circle, selected day = 2 px ink ring, previous / next month days in
  light grey, legend (Deadline, Start, Milestone, Debt due), then the selected day: "Friday, Oct 30" (+ an ink "Today" pill when today) and an "N events" chip, followed by its event cards;
  empty day -> card "Nothing planned" with [Add milestone] (-> /calendar/new?date=...). Tapping a day selects it; swiping horizontally on the grid changes month (optional).
  Event cards: tap a deadline/start card -> CL6 sheet, a milestone card -> CL7 sheet, a debt card -> /friends/transactions/:id.
- CL6 deadline sheet: red/orange icon bubble, project name, "Project deadline", status pill ("Overdue 5d" / "Nd left" / "Today"), rows Client, Due date, Status, Budget, [Open project]
  (context.push /projects/:id) and [Close]. CL7 milestone sheet: milestone icon, title, "Milestone", pill, rows Project, Date, Status (Pending / Done), [Mark as done] (or [Mark as pending] when
  done) -> toggleMilestone + toast "Milestone marked as done" / "Milestone marked as pending", and red outlined [Delete milestone] -> CL13 confirm sheet ([Confirm delete] -> deleteMilestone + toast
  "Milestone deleted", [Cancel]). CL15 jump sheet: year with prev / next year buttons, 12 month tiles (current shown month in ink, a small dot under months that have events), [Go to today].
- CL4 Agenda: groups OVERDUE - N (red label), TODAY, THIS WEEK (next 7 days after today), LATER (everything after, up to 90 days), each a list of event cards with the date in the subtitle for
  non-today groups; friendly empty line "Nothing coming up" when there are no events. CL5 Timeline (Gantt): pills Ongoing (projects that are not Completed / Delivered / Cancelled) /
  All (N); a card with month header (a window of about 4 months starting 2 months before today's month), one row per project (name 12 bold + client 11) with a rounded bar from start to end
  (orange In progress, purple Waiting client, grey Planned, green Completed / Delivered; clipped to the window with a chevron-left when it starts before the window), green ring dots for its
  milestones, a red vertical "Today" line with a small red "Today" flag; legend; a card "Capacity and availability" (-> /calendar/capacity) with the workload label.
- CL8/CL9 New milestone (/calendar/new, optional query projectId and date yyyy-MM-dd): X, "New milestone", project select (sheet CL10 with every non-cancelled project: name + "client - status",
  radio, [Confirm]), title, due date (showDatePicker, calendar-days icon), errors "Please select a project" / "Please enter a title" / "Please pick a due date" in red with red borders on a Save
  attempt, [Cancel] [Register milestone] -> addMilestone, then go to /calendar showing the month of the new milestone with that day selected and the toast "Milestone registered".
- CL11 Capacity (/calendar/capacity): back, "Capacity"; Workload card: pill (Light green 0-1 active contracts, Moderate orange 2-3, Heavy red 4+), "N active projects" (active = Planned,
  In Progress, Waiting Client), a 3-segment gauge with a knob and the sentence ("Open: ready for new projects." / "Selective: you can take one more project." / "Near full capacity."); Next
  available slot card: the earliest FUTURE end date among active projects ("Nov 12, 2026") or "Available now" when none, and "Earliest contract to free up: <project>" when a date exists;
  "Active projects progress" card with a bar per active project (colour by status) and "Average N%"; a "Calendar sync" row -> /calendar/sync.
- CL12 Calendar sync (/calendar/sync): back, "Calendar sync"; Google Calendar card: when SettingsRepository.googleConnected is true show the profile email, the green "Connected" pill, an ink
  [Sync now] button with a refresh-cw icon (sets lastSynced = now, toast "Calendar synced") and "Last synced today at 14:32" (or "Never synced"); when not connected show a grey "Not connected"
  pill and a [Connect in Settings] button -> /settings/integrations; three switches (Project deadlines, Milestones, Friends' debt due dates) stored in CalendarRepository, and the one-way note.
- Other changes: the More menu row, the Home screen "Upcoming deadlines" section header action "See all" now opens /calendar?tab=agenda; milestones count as upcoming events only inside the
  calendar (the Home keeps using project deadlines).
- UX rules: no overflow on 360x800 (the month grid scales with the width); the calendar never hangs tests (no endless animations, bounded pumps); all dates use the injected clock
  (`DateTime Function()? clock`, default DateTime.now) so tests are deterministic with now = 2026-10-30.
