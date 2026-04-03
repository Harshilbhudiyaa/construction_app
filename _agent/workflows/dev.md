---
description: Developer workflow for the Construction App
---

Follow these steps to develop and verify the application:

1. **Get Dependencies**
   Run following command to fetch all required packages:
   ```bash
   flutter pub get
   ```

2. **Static Analysis**
   Check for any code quality issues or bugs:
   ```bash
   flutter analyze
   ```

3. **Run Unit Tests**
   Ensure all tests pass before committing:
   ```bash
   flutter test
   ```

4. **Run the App**
   Launch the app on your connected device or emulator:
   ```bash
   flutter run
   ```

5. **Generate Icons/Assets** (if applicable)
   If you change icons or launcher assets, run:
   ```bash
   flutter pub run flutter_launcher_icons:main
   ```
