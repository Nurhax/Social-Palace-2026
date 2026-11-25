# SoPal (Social Palace)

SoPal is a Flutter app for tracking social links, inspired by Persona's Social
Links and styled with a comic-book look.

## Features

- Branded splash and ID screens. Create named local IDs and sign in by
  entering one; each ID has its own Social Link list.
- Add, edit, and delete Social Links; choose from 13 arcana.
- Track each link's level (1–10), adjust EXP, and mark favourites.
- Add dated logs to each link and browse them from the Logs tab.
- View link and log totals, see the lowest-level link, and switch between
  Persona 5, Persona 4, and Persona 3 color palettes.
- Comic-style text, ribbons, buttons, and badges, with bundled logo, navigation,
  header, and arcana artwork.

## Run

Install the Flutter SDK, then from the project directory run:

```bash
flutter pub get
flutter run
```

## Data and assets

Social Links, logs, saved IDs, the last-used ID, and the selected palette are
stored locally with `shared_preferences`. An ID is only a local profile name;
there is no account service, backend, or cloud sync. Data is tied to the
device's app storage and may be lost if that storage is cleared or the app is
uninstalled.

Image assets are in `assets/images/`, with arcana glyphs in
`assets/images/arcana/`. Flutter draws the comic shapes and much of the
interface in code; missing optional images have built-in fallbacks.
