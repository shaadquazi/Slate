## Slate

Slate is a small, local‑first task manager built with Flutter.  
Tasks are stored on‑device using Hive and managed via Provider, with a dark, Material 3 UI and custom typography.

### Features

- **Tasks with rich metadata**: title, optional description, status (Pending / In Progress / Completed).
- **Smart status flow**: swipe right to move a task forward (pending → in progress → completed), swipe left to delete.
- **Repeatable tasks**: daily, weekly, monthly, or yearly with an optional end date; next occurrences are scheduled from when you complete a task.
- **Sections & filters**: tasks grouped by status with “show more/less”, plus filters by status and repeat.
- **Images**: attach a photo to a task, edit it later, and view it in a zoomable fullscreen dialog.
- **Offline‑friendly**: all data is stored locally in a Hive box (`todos`), no backend required.

### Running the app

- **Prerequisites**: Flutter SDK installed and a device/emulator set up.  
  See the Flutter docs if you need help: `https://docs.flutter.dev`.

Install dependencies:

```bash
flutter pub get
```

Run on a device or simulator:

```bash
flutter run
```

### Build & deploy

#### iOS

Build the iOS app:

```bash
flutter build ios
```

Clean and rebuild (e.g. after dependency or native changes):

```bash
flutter clean && flutter pub get && flutter build ios
```

#### Web release

Production web build (use `--base-href` if the app is served under a subpath, e.g. `/apps/slate/`):

```bash
flutter build web --release
```

# slate

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
