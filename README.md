# SoPal (Social Palace) — Flutter UI

A Flutter implementation of the "SoPal" Figma mockup — a Persona 5–styled
Social Link tracker app (red/black/white comic-book look, slanted ribbon
banners, arcana badges, jagged buttons).

## What's implemented

- **Splash screen** — animated logo intro.
- **Enter ID / Get ID** — simple auth flow (mock, no backend).
- **Main screen** — list of Social Links with arcana badge, name ribbon,
  level progress bar, favourite star, and +/- EXP buttons.
- **Add Social Link** — form with an Arcana Selection grid (13 arcana).
- **Social Link detail** — view/edit/delete a link.
- **Logs** — per-person log list + add-log screen.
- **Settings** — stats, least-favourite, ID, and a **Select Theme** screen
  that swaps the app's palette between P5 / P4 / P3-style colors.

All comic-style shapes (slanted ribbons, jagged "burst" buttons, outlined
headline text) are built with custom `ClipPath`/`CustomPainter` widgets in
`lib/widgets/comic_shapes.dart` and `lib/widgets/sopal_chrome.dart` — no
external design assets are required.

## Run it

```bash
flutter pub get
flutter run
```

State is a single in-memory `AppState` (`lib/state/app_state.dart`) shared
via a small `InheritedNotifier` — no external state-management package is
used, so `flutter pub get` only needs to fetch `cupertino_icons`.

## Notes / next steps

- Data is in-memory only (resets on restart). Wire it up to a backend or
  local storage (e.g. `sqflite`, `hive`, or your API) as a next step.
- The logo/arcana artwork is a simplified geometric approximation of the
  original hand-drawn mockup — swap in the real illustrated assets from
  Figma (export as SVG/PNG) for a pixel-perfect match if needed.
- Font: currently uses the default Material font with bold-italic +
  stroke-outline text to mimic the comic look. For an exact match, add the
  mockup's actual display font as a custom font asset.
