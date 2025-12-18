# AzanAlarm (Flutter)

Islamic prayer-time companion that surfaces today's timetable, shows the next prayer countdown, and lets you set Azan-style alarms with custom offsets. Built with Flutter + Riverpod and designed to run on Android and iOS.

## Current Features
- Prayer timetable: five daily prayers with status (upcoming/passed) and next-prayer countdown (mock calculation for now).
- Location handling: save current/manual locations, switch quickly, and show the active location on the home screen.
- Alarms: create per-prayer alarms with offsets (before/after), repeat days, vibration toggle, and labels; scheduling hooks wired for local notifications.
- Notifications: local notification service scaffolded (Flutter Local Notifications + timezone) with permission requests and immediate/scheduled notifications.
- Settings: calculation/juristic methods, 12h/24h format, notification/vibration toggles, theme and language preferences.
- Navigation: bottom navigation shell (Home, Alarms, Location, Settings) plus Qibla compass and Islamic calendar placeholder screens.

## Tech Stack
- Flutter 3.24.5, Dart 3.5.4
- State: Riverpod (`flutter_riverpod`)
- Routing: `go_router`
- Location: `geolocator`, `geocoding`, `permission_handler`
- Storage: `sqflite`, `shared_preferences` style settings map
- Notifications/Alarms: `flutter_local_notifications`, `android_alarm_manager_plus`, `timezone`
- Audio: `just_audio`, `audio_session`
- Firebase packages included for future auth/sync/analytics (not wired yet)

## Project Structure (key parts)
```
lib/
  core/
    router/         # GoRouter config and shell navigation
    models/         # Location, Prayer, Alarm, AppSettings
    providers/      # Riverpod providers and managers
    services/       # Location, prayer times, alarms, notifications, settings
    database/       # SQLite helpers for locations, alarms, settings
    theme/          # Light/dark themes and color helpers
    constants/      # App-wide constants
  presentation/
    screens/        # Home, Alarms, Location, Settings, Qibla, Calendar, sheets
    widgets/        # Reusable UI components
assets/             # Images, audio (Azan), icons, fonts (Poppins)
```

## Getting Started
1) Install Flutter 3.24.5+ (Dart 3.5.4).  
2) Install project deps:  
   `flutter pub get`
3) (Optional) Run codegen if you add annotations later:  
   `flutter pub run build_runner build --delete-conflicting-outputs`
4) Launch on a device/emulator:  
   `flutter run`

## Platform Notes
- Location: requires runtime permissions; make sure Android/iOS manifests include location + notification permissions.
- Notifications/alarms: the service is scaffolded; verify exact alarm scheduling on device/emulator and configure channels as needed.
- Timezones: placeholder timezone handling is present; verify for your region before release.

## Roadmap / Gaps
- Replace mock prayer-time calculation with a production source (e.g., `pray_times` or a trusted API) and add caching.
- Wire alarm scheduling to `android_alarm_manager_plus` and background execution.
- Implement real Qibla compass and Islamic calendar data.
- Add Firebase-backed auth/sync, analytics, crash reporting.
- Add tests (unit/widget/integration) once calculation and scheduling are finalized.
