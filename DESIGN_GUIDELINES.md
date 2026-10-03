# Wakaranai — Design Guidelines

Living reference for the app's visual language. Follow this when redesigning or
building new screens so everything reads as one system. This file is intentionally
**untracked** (developer notes, not shipped docs).

Source of truth in code: `lib/utils/app_palette.dart` (the nine themes),
`lib/utils/app_colors.dart` (the access proxy), `lib/utils/text_styles.dart`,
`lib/ui/widgets/shimmer.dart`, `lib/ui/common/service_viewer/service_viewer_message.dart`,
`lib/ui/widgets/confirmation_dialog/confirmation_dialog.dart`.

### Theming
Colors are theme-aware. `AppPalette` (a `ThemeExtension`) defines nine palettes — dark:
**Midnight** (`#303030`), **AMOLED** (`#000000`), **Ocean** (navy+cyan), **Dracula**
(purple), **Ember** (warm+amber); light: **Light** (green), **Sky** (blue), **Sakura**
(rose), **Sepia** (warm paper) — selected by `ThemeCubit`
and persisted via `SettingsService`. `AppColors` is a live proxy over the active palette
(so `AppColors.primary` etc. resolve at build time); never reintroduce `const` on a widget
that reads an `AppColors` value. Rules when building UI:
- **Elevation overlays** use `AppColors.overlay(alpha)` (white on dark themes, dark on
  light) — never a literal `Colors.white.withValues(alpha:)`.
- **Text/icons over cover art or media scrims** use `AppColors.onMedia` (always white),
  not `AppColors.mainWhite` (which flips to near-black in the Light theme).
- **Dialog/sheet surfaces** use `AppColors.dialogSurface`; skeleton fills use
  `AppColors.shimmerBase` / `shimmerHighlight`. Image scrims stay literal `Colors.black`.

## Foundations

### Color (`AppColors`)
- **Background**: `AppColors.backgroundColor` `#303030` — every screen `Scaffold` uses it.
- **Primary accent**: `AppColors.primary` `#00E676` (green). Used for selected states,
  active controls, progress, primary buttons, links.
- **On-primary text**: `AppColors.mainBlack` (black @ ~60%). Text/icons that sit on a
  filled primary surface use this, never pure white.
- **Text**: `AppColors.mainWhite` (primary text), `AppColors.mainGrey` (secondary/muted).
- **Destructive**: `AppColors.red`.
- **Splash accents**: `AppColors.mediumLight` (used at ~0.2 alpha for InkWell splashes).
- **Dialog surface**: `#3A3A3A` (one step lighter than background), for modals/dialogs.

### Elevation via translucency (not shadows)
Surfaces are expressed with **white overlays on the dark background**, not drop shadows:
- **Card / tile fill**: `Colors.white.withValues(alpha: 0.04)`.
- **Selected / interactive fill**: `AppColors.primary.withValues(alpha: 0.14–0.16)`.
- **Subtle control fill** (segmented track, chips, icon buttons): `white @ 0.06–0.08`.
- **Hairline borders / dividers**: `white @ 0.06–0.08`.
- Always use `.withValues(alpha:)` — **never** the deprecated `.withOpacity()`.

### Typography (`text_styles.dart`)
Font is **Ubuntu**. Use the helpers, never raw `TextStyle` for text:
- `semibold(size:)` — titles, section headers, emphasis.
- `medium(size:)` — labels, tile titles, buttons.
- `regular(size:)` — body, secondary text (usually `color: AppColors.mainGrey`).
- Rough scale: page title **22–24**, section header **18**, card title **15–16**,
  body **13–14**, meta/caption **11–12**.

### Shape & spacing
- **Radii**: cards/sheets `14–16`, chips/pills & buttons `12`, small badges `6–10`,
  bottom-sheet top corners `20`, dialogs `20`.
- **Screen padding**: horizontal **16**.
- **Rhythm**: 8-based spacing (8 / 12 / 16 / 20 / 24).
- Icons: rounded variants (`Icons.*_rounded`), typically size 20–24.

## Components & patterns

### App bars / page headers
Two accepted patterns:
- **Sliver app bar** (e.g. Extensions): transparent background & surfaceTint, `elevation: 0`,
  `scrolledUnderElevation: 0`, `pinned/floating/snap`, title `semibold(22)`.
- **Plain header** (e.g. History, Settings): `SafeArea(bottom:false)` + a title
  `semibold(24)` at `fromLTRB(16,12,16,12)`, optionally followed by a control
  (segmented tabs, info button).

Detail screens (concrete viewer) have **no app bar** — a floating circular back
button (`ConcreteBackButton`) sits over the cover, always visible.

### Cards & tiles
`Material(color: white@0.04, borderRadius: 14) > InkWell(splash: mediumLight@0.2)`.
Row layout: leading media/icon → title + subtitle column → trailing chevron/meta.
Tile titles `semibold/medium(15–16)`, subtitles `regular(12–13, mainGrey)`.

### Chips & badges
- **Tag/label chip**: `white@0.06` fill, radius 8, `medium(12)`.
- **Category tint chip**: `tint.withValues(alpha:0.16)` fill, radius 6 (e.g. NSFW = red).
- **Count badge**: `white@0.08` fill, radius 10, `medium(12, mainGrey)`.

### Selectable controls
- **Segmented tabs**: track `white@0.06` radius 14, animated primary thumb
  (`AnimatedAlign` + `FractionallySizedBox(0.5)`), selected label `mainBlack`, others `mainGrey`.
- **Selectable pills** (group/provider selector, reader modes): selected =
  filled `primary` + `mainBlack` text (optional leading check); unselected =
  `white@0.06` + `mainWhite`.
- **Bottom nav**: expanding-pill — unselected shows grey icon only; selected animates to a
  `primary@0.14` pill with icon + label in `primary`.
- **Switches**: `activeThumbColor: mainBlack`, `activeTrackColor: primary`.

### Reachability (one-handed use)
Put **interactive controls within thumb reach at the bottom** of the screen, especially on
immersive/reading screens used one-handed. Reserve the top for read-only info (titles,
status). Example: the chapter reader keeps the chapter title in the top bar but places the
back button, page slider, and settings button together in the bottom bar.

### Primary / secondary buttons
- **Primary**: filled `primary`, foreground `mainBlack`, radius 12–14, height ~48–52,
  `semibold(15–16)`.
- **Secondary / cancel**: `white@0.06` fill, `mainWhite` text.

### Bottom sheets
`showModalBottomSheet(backgroundColor: backgroundColor, shape: top radius 20)`.
Start content with a centered **drag handle** (40×4, `white@0.18`, radius 2), then a
`semibold(18)` title. Options are tap rows; the active one shows `primary` text + a
trailing check. Long-press action menus (e.g. history item) are bottom sheets, not dialogs.

### Dialogs (`ConfirmationDialog` / `InfoDialog`)
Custom themed `Dialog` on `#3A3A3A`, radius 20. Layout: tinted icon chip (52×52,
`accent@0.14`, radius 16) → centered `semibold(18)` title → centered `regular(14, mainGrey)`
message → button row. Confirm = filled accent (`red` for destructive, else `primary`);
cancel = `white@0.06`. **Do not** use `adaptive_dialog` / default `AlertDialog`.

### Empty & error states (`ServiceViewerMessage`)
Centered icon (64, `mainGrey`) → `semibold(18)` title → optional `regular(14, mainGrey)`
message → optional action buttons (primary style). Use for empty lists and load errors,
with a Retry `ElevatedButton.icon` where a reload is possible.

### Loading (skeletons, not spinners)
Prefer shimmer skeletons over `CircularProgressIndicator` for content loads. Use
`Shimmer` + `ShimmerBox` placeholders that mirror the real layout
(e.g. `ConfigsListSkeleton`, `ConcreteContentSkeleton`). Spinners are acceptable only for
tiny inline/initial cases and image progress.

### Covers / hero media
Full-bleed image + a `LinearGradient` (top→bottom, `transparent → transparent → backgroundColor`,
stops `0.0, 0.55, 1.0`) so the image melts into the page. Keep the shared element `Hero`
tag intact for gallery→detail transitions. **The gradient scrim must live _inside_ the
`Hero` child** (composited with the image, see `ConcreteCoverScrim`) — a sibling scrim is
left behind on the empty hero placeholder mid-flight and pops in at the end.

When two heroes share a tag but look different at rest (gallery card = rounded + dark
title gradient + title; concrete cover = square + background fade), attach
`flightShuttleBuilder: Heroes.crossfadeFlightShuttle` to **both** so the flight crossfades
the two treatments instead of hard-swapping to the destination's look at flight start.

## Conventions
- Localize all user-facing strings via `S.current.*` / `S.of(context)`; add keys to
  `lib/l10n/intl_en.arb` and run `dart run intl_utils:generate`.
- No non-critical code comments — match the surrounding comment-free style.
- Reuse shared widgets (`ServiceViewerMessage`, `Shimmer`, `ConfirmationDialog`,
  `concrete_viewer_widgets.dart`) instead of re-implementing.

## Redesigned so far
Extensions/repositories, service viewer, history, settings, bottom navigation,
confirmation/info dialogs, reader-settings sheet (reading-mode selector),
manga & anime concrete viewers.
