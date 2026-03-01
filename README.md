## Slate

Slate is a simple and clean task manager designed to help you stay organized. It helps you focus on your goals with a distraction-free interface and smart scheduling.

### Features

- **Easy Organizing**: Create tasks with titles and descriptions.
- **Smart Tracking**: Swipe to move tasks from "Pending" to "Done."
- **Repeating Tasks**: Set tasks to repeat daily, weekly, monthly, or yearly.
- **Natural Filtering**: View tasks due "Today," "This week," "This month," or "This year."
- **Smart Sorting**: The most urgent tasks automatically stay at the top.
- **Photo Attachments**: Add images to your tasks for extra context.
- **Always Available**: Works entirely offline and remembers your settings.

---

### How to Run

To get Slate up and running on your machine:

1. **Install dependencies**:
   ```bash
   flutter pub get
   ```

2. **Prepare the app**:
   ```bash
   flutter gen-l10n
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

3. **Launch**:
   ```bash
   flutter run
   ```

---

### How to Build & Release

#### For iOS
To create an iPhone app:
```bash
flutter build ios
```

#### For Web
To create a version for your website:
```bash
flutter build web --release
```
