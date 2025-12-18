/// Riverpod providers for state management

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import '../services/services.dart';
import '../database/database_service.dart';

/// Provider for location service
final locationServiceProvider = Provider<LocationService>((ref) {
  return LocationService();
});

/// Provider for prayer times service
final prayerTimesServiceProvider = Provider<PrayerTimesService>((ref) {
  return PrayerTimesService();
});

/// Provider for settings service
final settingsServiceProvider = Provider<SettingsService>((ref) {
  return SettingsService();
});

/// Provider for alarm service
final alarmServiceProvider = Provider<AlarmService>((ref) {
  return AlarmService();
});

/// Provider for notification service
final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

/// Provider for database service
final databaseServiceProvider = Provider<DatabaseService>((ref) {
  return DatabaseService();
});

/// Current location provider
final currentLocationProvider = FutureProvider<Location?>((ref) async {
  final locationService = ref.watch(locationServiceProvider);
  return await locationService.getCurrentSavedLocation();
});

/// Current app settings provider
final appSettingsProvider = FutureProvider<AppSettings>((ref) async {
  final settingsService = ref.watch(settingsServiceProvider);
  return await settingsService.getSettings();
});

/// All alarms provider
final alarmsProvider = FutureProvider<List<Alarm>>((ref) async {
  final alarmService = ref.watch(alarmServiceProvider);
  return await alarmService.getAllAlarms();
});

/// Active alarms provider
final activeAlarmsProvider = FutureProvider<List<Alarm>>((ref) async {
  final alarmService = ref.watch(alarmServiceProvider);
  return await alarmService.getActiveAlarms();
});

/// Today's prayer times provider
final todayPrayerTimesProvider = FutureProvider<Map<Prayer, DateTime>>((ref) async {
  final locationAsync = ref.watch(currentLocationProvider);
  final settingsAsync = ref.watch(appSettingsProvider);
  
  final location = locationAsync.value;
  final settings = settingsAsync.value;
  
  if (location == null || settings == null) {
    return {};
  }
  
  final prayerTimesService = ref.watch(prayerTimesServiceProvider);
  return await prayerTimesService.getTodayPrayerTimes(location, settings);
});

/// Next prayer information provider
final nextPrayerProvider = Provider<(Prayer?, Duration)>((ref) {
  final prayerTimesAsync = ref.watch(todayPrayerTimesProvider);
  
  final prayerTimes = prayerTimesAsync.value;
  if (prayerTimes == null || prayerTimes.isEmpty) {
    return (null, Duration.zero);
  }
  
  final prayerTimesService = ref.watch(prayerTimesServiceProvider);
  final nextPrayer = prayerTimesService.getNextPrayer(prayerTimes);
  final countdown = prayerTimesService.getNextPrayerCountdown(prayerTimes);
  
  return (nextPrayer, countdown);
});

/// Saved locations provider
final savedLocationsProvider = FutureProvider<List<Location>>((ref) async {
  final locationService = ref.watch(locationServiceProvider);
  return await locationService.getSavedLocations();
});

/// Location search results provider
final locationSearchProvider = StateProvider<List<Location>>((ref) {
  return [];
});

/// Provider for updating app settings
final settingsUpdaterProvider = Provider<SettingsUpdater>((ref) {
  final settingsService = ref.watch(settingsServiceProvider);
  return SettingsUpdater(settingsService);
});

/// Provider for managing alarms
final alarmManagerProvider = Provider<AlarmManager>((ref) {
  final alarmService = ref.watch(alarmServiceProvider);
  final notificationService = ref.watch(notificationServiceProvider);
  final prayerTimesAsync = ref.watch(todayPrayerTimesProvider);
  
  return AlarmManager(
    alarmService,
    notificationService,
    prayerTimesAsync,
  );
});

/// Provider for location operations
final locationManagerProvider = Provider<LocationManager>((ref) {
  final locationService = ref.watch(locationServiceProvider);
  final settingsService = ref.watch(settingsServiceProvider);
  final savedLocationsAsync = ref.watch(savedLocationsProvider);
  
  return LocationManager(
    locationService,
    settingsService,
    savedLocationsAsync,
  );
});

/// Helper classes for complex operations

/// Class for updating app settings
class SettingsUpdater {
  final SettingsService _settingsService;

  SettingsUpdater(this._settingsService);

  Future<void> updateCalculationMethod(PrayerCalculationMethod method) async {
    await _settingsService.updateSetting('calculationMethod', method);
  }

  Future<void> updateJuristicMethod(JuristicMethod method) async {
    await _settingsService.updateSetting('juristicMethod', method);
  }

  Future<void> updateAudioTheme(String theme) async {
    await _settingsService.updateSetting('audioTheme', theme);
  }

  Future<void> updateTimeFormat(bool is24Hour) async {
    await _settingsService.updateSetting('is24HourFormat', is24Hour);
  }

  Future<void> updateNotifications(bool enabled) async {
    await _settingsService.updateSetting('enableNotifications', enabled);
  }

  Future<void> updateVibration(bool enabled) async {
    await _settingsService.updateSetting('enableVibration', enabled);
  }

  Future<void> updateTheme(AppTheme theme) async {
    await _settingsService.updateSetting('theme', theme);
  }

  Future<void> updateLanguage(String language) async {
    await _settingsService.updateSetting('language', language);
  }

  Future<void> resetToDefaults() async {
    await _settingsService.resetToDefaults();
  }
}

/// Class for managing alarms
class AlarmManager {
  final AlarmService _alarmService;
  final NotificationService _notificationService;
  final AsyncValue<Map<Prayer, DateTime>> _prayerTimesAsync;

  AlarmManager(
    this._alarmService,
    this._notificationService,
    this._prayerTimesAsync,
  );

  Future<int> createAlarm({
    required Prayer prayer,
    required int offsetMinutes,
    String? label,
    String? soundPath,
    List<int> repeatDays = const [],
    bool vibrationEnabled = true,
  }) async {
    final alarm = Alarm(
      prayer: prayer,
      offsetMinutes: offsetMinutes,
      label: label,
      soundPath: soundPath,
      isActive: true,
      repeatDays: repeatDays,
      vibrationEnabled: vibrationEnabled,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final id = await _alarmService.createAlarm(alarm);
    
    // Schedule the alarm if we have prayer times
    _scheduleAlarmIfPossible(alarm, id);
    
    return id;
  }

  Future<void> updateAlarm(Alarm alarm) async {
    await _alarmService.updateAlarm(alarm);
    _scheduleAlarmIfPossible(alarm, alarm.id!);
  }

  Future<void> deleteAlarm(int id) async {
    await _alarmService.deleteAlarm(id);
    await _alarmService.cancelAlarm(id);
  }

  Future<void> toggleAlarm(int id, bool isActive) async {
    await _alarmService.toggleAlarm(id, isActive);
  }

  void _scheduleAlarmIfPossible(Alarm alarm, int id) {
    final prayerTimes = _prayerTimesAsync.value;
    if (prayerTimes != null && prayerTimes.containsKey(alarm.prayer)) {
      final prayerTime = prayerTimes[alarm.prayer]!;
      final alarmTime = alarm.getActualAlarmTime(prayerTime);
      _alarmService.scheduleAlarm(alarm, prayerTime);
    }
  }

  Future<void> checkAndTriggerAlarms() async {
    final prayerTimes = _prayerTimesAsync.value;
    if (prayerTimes == null) return;

    final alarms = await _alarmService.getActiveAlarms();
    
    for (final alarm in alarms) {
      if (prayerTimes.containsKey(alarm.prayer)) {
        final prayerTime = prayerTimes[alarm.prayer]!;
        if (_alarmService.shouldAlarmTrigger(alarm, prayerTime)) {
          await _notificationService.showAlarmNotification(alarm);
        }
      }
    }
  }
}

/// Class for managing location operations
class LocationManager {
  final LocationService _locationService;
  final SettingsService _settingsService;
  final AsyncValue<List<Location>> _savedLocationsAsync;

  LocationManager(
    this._locationService,
    this._settingsService,
    this._savedLocationsAsync,
  );

  Future<Location?> getCurrentDeviceLocation() async {
    return await _locationService.getCurrentLocation();
  }

  Future<List<Location>> searchLocations(String query) async {
    return await _locationService.searchLocations(query);
  }

  Future<void> saveLocation(Location location) async {
    await _locationService.saveLocation(location);
  }

  Future<void> setCurrentLocation(Location location) async {
    await _locationService.setCurrentLocation(location);
  }

  Future<void> deleteLocation(int id) async {
    await _locationService.deleteLocation(id);
  }

  Future<List<Location>> getSavedLocations() async {
    return await _locationService.getSavedLocations();
  }

  Future<bool> hasLocationPermission() async {
    return await _locationService.hasLocationPermission();
  }

  Future<bool> requestLocationPermission() async {
    return await _locationService.requestLocationPermission();
  }

  double calculateDistance(Location location1, Location location2) {
    return _locationService.calculateDistance(location1, location2);
  }
}

/// Provider for app initialization status
final appInitializationProvider = StateProvider<bool>((ref) {
  return false;
});

/// Provider for handling loading states
final isLoadingProvider = StateProvider<bool>((ref) {
  return false;
});

/// Provider for error messages
final errorMessageProvider = StateProvider<String?>((ref) {
  return null;
});

/// Provider for success messages
final successMessageProvider = StateProvider<String?>((ref) {
  return null;
});

/// Helper method to clear messages
void clearMessages(WidgetRef ref) {
  ref.read(errorMessageProvider.notifier).state = null;
  ref.read(successMessageProvider.notifier).state = null;
}

/// Helper method to show error message
void showError(WidgetRef ref, String message) {
  ref.read(errorMessageProvider.notifier).state = message;
}

/// Helper method to show success message
void showSuccess(WidgetRef ref, String message) {
  ref.read(successMessageProvider.notifier).state = message;
}

/// Provider for theme mode based on app settings
final themeModeProvider = Provider<ThemeMode>((ref) {
  final settingsAsync = ref.watch(appSettingsProvider);
  
  final settings = settingsAsync.value;
  if (settings == null) return ThemeMode.system;
  
  switch (settings.theme) {
    case AppTheme.light:
      return ThemeMode.light;
    case AppTheme.dark:
      return ThemeMode.dark;
    case AppTheme.system:
    default:
      return ThemeMode.system;
  }
});

/// Provider for locale based on app settings
final localeProvider = Provider<Locale?>((ref) {
  final settingsAsync = ref.watch(appSettingsProvider);
  
  final settings = settingsAsync.value;
  if (settings == null || settings.language == 'en') return null;
  
  return Locale(settings.language);
});