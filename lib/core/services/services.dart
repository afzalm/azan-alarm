/// Core services for the AzanAlarm application

import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart'
    as flutter_local_notifications;
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tzdata;
import '../models/models.dart';
import '../database/database_service.dart';
import '../constants/app_constants.dart';
import 'prayer_time_calculator.dart';
import 'timezone_helper.dart';

/// Location service for handling GPS and location operations
class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  /// Check if location permission is granted
  Future<bool> hasLocationPermission() async {
    final permission = await Permission.location.status;
    return permission.isGranted;
  }

  /// Request location permission
  Future<bool> requestLocationPermission() async {
    final permission = await Permission.location.request();
    return permission.isGranted;
  }

  /// Get current device location
  Future<Location?> getCurrentLocation() async {
    try {
      // Check permission first
      if (!await hasLocationPermission()) {
        final granted = await requestLocationPermission();
        if (!granted) return null;
      }

      // Get current position
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      // Reverse geocode to get address
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        final placemark = placemarks.first;
        
        // Detect timezone from coordinates
        final detectedTimezone = TimezoneHelper.detectTimezoneFromCoordinates(
          position.latitude,
          position.longitude,
        );
        
        final location = Location(
          name: placemark.locality ?? placemark.subLocality ?? 'Unknown',
          country: placemark.country ?? 'Unknown',
          latitude: position.latitude,
          longitude: position.longitude,
          timezone: detectedTimezone ?? 'UTC',
          createdAt: DateTime.now(),
        );

        // Save as current location
        await setCurrentLocation(location);
        return location;
      }
    } catch (e) {
      print('Error getting current location: $e');
    }
    return null;
  }

  /// Search for locations by query
  Future<List<Location>> searchLocations(String query) async {
    if (query.isEmpty) return [];

    try {
      final locations = await locationFromAddress(query);
      final results = <Location>[];

      for (final location in locations) {
        // Get country info (we need to reverse geocode)
        final placemarks = await placemarkFromCoordinates(
          location.latitude,
          location.longitude,
        );

        if (placemarks.isNotEmpty) {
          final placemark = placemarks.first;
          
          // Detect timezone from coordinates
          final detectedTimezone = TimezoneHelper.detectTimezoneFromCoordinates(
            location.latitude,
            location.longitude,
          );
          
          results.add(Location(
            name: location.locality ?? location.subLocality ?? location.name ?? query,
            country: placemark.country ?? 'Unknown',
            latitude: location.latitude,
            longitude: location.longitude,
            timezone: detectedTimezone ?? 'UTC',
            createdAt: DateTime.now(),
          ));
        }
      }

      return results;
    } catch (e) {
      print('Error searching locations: $e');
      return [];
    }
  }

  /// Save location to database
  Future<int> saveLocation(Location location) async {
    return await LocationDatabase.insertOrUpdate(location);
  }

  /// Set current location
  Future<void> setCurrentLocation(Location location) async {
    location.isCurrent = true;
    await saveLocation(location);
  }

  /// Get current saved location
  Future<Location?> getCurrentSavedLocation() async {
    return await LocationDatabase.getCurrentLocation();
  }

  /// Get all saved locations
  Future<List<Location>> getSavedLocations() async {
    return await LocationDatabase.getAllLocations();
  }

  /// Delete saved location
  Future<int> deleteLocation(int id) async {
    return await LocationDatabase.deleteLocation(id);
  }

  /// Calculate distance between two locations in kilometers
  double calculateDistance(Location location1, Location location2) {
    return Geolocator.distanceBetween(
      location1.latitude,
      location1.longitude,
      location2.latitude,
      location2.longitude,
    ) / 1000; // Convert to kilometers
  }
}

/// Prayer times service for calculating and caching prayer times
class PrayerTimesService {
  static final PrayerTimesService _instance = PrayerTimesService._internal();
  factory PrayerTimesService() => _instance;
  PrayerTimesService._internal();

  final _calculator = PrayerTimeCalculator();

  /// Get prayer times for a specific location and date
  Future<Map<Prayer, DateTime>> getPrayerTimes(
    Location location,
    DateTime date,
    AppSettings settings,
  ) async {
    try {
      // Calculate timezone offset from UTC
      // Use the location's timezone if available, otherwise use local timezone
      final timezoneOffset = TimezoneHelper.getTimezoneOffset(
        date,
        timezoneName: location.timezone != 'UTC' ? location.timezone : null,
      );
      
      // Calculate prayer times using astronomical formulas
      final times = _calculator.calculate(
        latitude: location.latitude,
        longitude: location.longitude,
        date: date,
        calculationMethod: settings.calculationMethod,
        juristicMethod: settings.juristicMethod,
        timezoneOffset: timezoneOffset,
      );
      
      return times;
    } catch (e) {
      print('Error calculating prayer times: $e');
      return {};
    }
  }

  /// Get today's prayer times for current location
  Future<Map<Prayer, DateTime>> getTodayPrayerTimes(
    Location location,
    AppSettings settings,
  ) async {
    return await getPrayerTimes(location, DateTime.now(), settings);
  }

  /// Get next prayer countdown
  Duration getNextPrayerCountdown(
    Map<Prayer, DateTime> prayerTimes,
  ) {
    final now = DateTime.now();
    
    // Find the next prayer time
    for (final entry in prayerTimes.entries) {
      if (entry.value.isAfter(now)) {
        return entry.value.difference(now);
      }
    }
    
    // If all prayers have passed today, return time until Fajr tomorrow
    final fajrTomorrow = prayerTimes[Prayer.fajr]!.add(const Duration(days: 1));
    return fajrTomorrow.difference(now);
  }

  /// Get next prayer information
  Prayer? getNextPrayer(Map<Prayer, DateTime> prayerTimes) {
    final now = DateTime.now();
    
    for (final entry in prayerTimes.entries) {
      if (entry.value.isAfter(now)) {
        return entry.prayer;
      }
    }
    
    // If all prayers have passed, next prayer is Fajr
    return Prayer.fajr;
  }

  /// Check if it's time for a specific prayer
  bool isPrayerTime(Prayer prayer, DateTime prayerTime, {Duration tolerance = const Duration(minutes: 5)}) {
    final now = DateTime.now();
    final timeDiff = now.difference(prayerTime).inMinutes.abs();
    return timeDiff <= tolerance.inMinutes;
  }
}

/// Settings service for managing app settings
class SettingsService {
  static final SettingsService _instance = SettingsService._internal();
  factory SettingsService() => _instance;
  SettingsService._internal();

  /// Get current app settings
  Future<AppSettings> getSettings() async {
    try {
      final settingsMap = await SettingsDatabase.getAllSettings();
      
      if (settingsMap.isEmpty) {
        // Return default settings
        return const AppSettings();
      }
      
      return AppSettingsExtension.fromStorageMap(settingsMap);
    } catch (e) {
      print('Error loading settings: $e');
      return const AppSettings();
    }
  }

  /// Update app settings
  Future<void> updateSettings(AppSettings settings) async {
    try {
      final settingsMap = settings.toStorageMap();
      
      for (final entry in settingsMap.entries) {
        await SettingsDatabase.saveSetting(entry.key, entry.value.toString());
      }
    } catch (e) {
      print('Error saving settings: $e');
      rethrow;
    }
  }

  /// Reset settings to defaults
  Future<void> resetToDefaults() async {
    const defaultSettings = AppSettings();
    await updateSettings(defaultSettings);
  }

  /// Update specific setting
  Future<void> updateSetting(String key, dynamic value) async {
    final settings = await getSettings();
    
    AppSettings updatedSettings;
    switch (key) {
      case 'calculationMethod':
        updatedSettings = settings.copyWith(
          calculationMethod: value as PrayerCalculationMethod,
        );
        break;
      case 'juristicMethod':
        updatedSettings = settings.copyWith(
          juristicMethod: value as JuristicMethod,
        );
        break;
      case 'audioTheme':
        updatedSettings = settings.copyWith(
          audioTheme: value as String,
        );
        break;
      case 'is24HourFormat':
        updatedSettings = settings.copyWith(
          is24HourFormat: value as bool,
        );
        break;
      case 'enableNotifications':
        updatedSettings = settings.copyWith(
          enableNotifications: value as bool,
        );
        break;
      case 'enableVibration':
        updatedSettings = settings.copyWith(
          enableVibration: value as bool,
        );
        break;
      case 'theme':
        updatedSettings = settings.copyWith(
          theme: value as AppTheme,
        );
        break;
      case 'language':
        updatedSettings = settings.copyWith(
          language: value as String,
        );
        break;
      default:
        throw ArgumentError('Unknown setting: $key');
    }
    
    await updateSettings(updatedSettings);
  }

  /// Get setting value
  Future<T?> getSetting<T>(String key) async {
    final settings = await getSettings();
    
    switch (key) {
      case 'calculationMethod':
        return settings.calculationMethod as T;
      case 'juristicMethod':
        return settings.juristicMethod as T;
      case 'audioTheme':
        return settings.audioTheme as T;
      case 'is24HourFormat':
        return settings.is24HourFormat as T;
      case 'enableNotifications':
        return settings.enableNotifications as T;
      case 'enableVibration':
        return settings.enableVibration as T;
      case 'theme':
        return settings.theme as T;
      case 'language':
        return settings.language as T;
      default:
        return null;
    }
  }
}

/// Alarm service for managing prayer alarms
class AlarmService {
  static final AlarmService _instance = AlarmService._internal();
  factory AlarmService() => _instance;
  AlarmService._internal();

  /// Create a new alarm
  Future<int> createAlarm(Alarm alarm) async {
    try {
      final updatedAlarm = alarm.copyWith(
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      final id = await AlarmDatabase.insert(updatedAlarm);
      return id;
    } catch (e) {
      print('Error creating alarm: $e');
      rethrow;
    }
  }

  /// Update existing alarm
  Future<void> updateAlarm(Alarm alarm) async {
    try {
      final updatedAlarm = alarm.copyWith(
        updatedAt: DateTime.now(),
      );
      
      await AlarmDatabase.update(updatedAlarm);
    } catch (e) {
      print('Error updating alarm: $e');
      rethrow;
    }
  }

  /// Delete alarm
  Future<void> deleteAlarm(int id) async {
    try {
      await AlarmDatabase.delete(id);
    } catch (e) {
      print('Error deleting alarm: $e');
      rethrow;
    }
  }

  /// Get all alarms
  Future<List<Alarm>> getAllAlarms() async {
    try {
      return await AlarmDatabase.getAllAlarms();
    } catch (e) {
      print('Error getting alarms: $e');
      return [];
    }
  }

  /// Get active alarms
  Future<List<Alarm>> getActiveAlarms() async {
    try {
      return await AlarmDatabase.getActiveAlarms();
    } catch (e) {
      print('Error getting active alarms: $e');
      return [];
    }
  }

  /// Toggle alarm active status
  Future<void> toggleAlarm(int id, bool isActive) async {
    try {
      await AlarmDatabase.toggleAlarm(id, isActive);
    } catch (e) {
      print('Error toggling alarm: $e');
      rethrow;
    }
  }

  /// Get alarms for specific prayer
  Future<List<Alarm>> getAlarmsForPrayer(Prayer prayer) async {
    final allAlarms = await getAllAlarms();
    return allAlarms.where((alarm) => alarm.prayer == prayer).toList();
  }

  /// Check if alarm should trigger now
  bool shouldAlarmTrigger(Alarm alarm, DateTime prayerTime) {
    if (!alarm.isActive) return false;
    
    final alarmTime = alarm.getActualAlarmTime(prayerTime);
    final now = DateTime.now();
    
    // Check if it's time to trigger (within 1 minute tolerance)
    final timeDiff = now.difference(alarmTime).inMinutes.abs();
    return timeDiff <= 1;
  }

  /// Schedule alarm for system notifications
  Future<void> scheduleAlarm(Alarm alarm, DateTime prayerTime) async {
    final notify = NotificationService();
    final scheduleAt = alarm.getActualAlarmTime(prayerTime);
    await notify.scheduleNotificationAt(
      time: scheduleAt,
      title: 'Azan Alarm',
      body: alarm.displayLabel,
      payload: 'alarm:${alarm.id ?? 0}',
      id: alarm.id,
    );
  }

  /// Cancel scheduled alarm
  Future<void> cancelAlarm(int alarmId) async {
    // TODO: Implement alarm cancellation
    print('Canceling alarm: $alarmId');
  }
}

/// Notification service for handling system notifications
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  static final _fln = flutter_local_notifications.FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  /// Initialize notification service
  Future<void> initialize() async {
    if (_initialized) return;
    try {
      tzdata.initializeTimeZones();
    } catch (_) {}

    const androidInit = flutter_local_notifications.AndroidInitializationSettings('@mipmap/ic_launcher');
    const iOSInit = flutter_local_notifications.DarwinInitializationSettings();
    const initSettings = flutter_local_notifications.InitializationSettings(
      android: androidInit,
      iOS: iOSInit,
    );
    await _fln.initialize(initSettings);
    _initialized = true;
  }

  /// Request notification permissions
  Future<bool> requestPermissions() async {
    final status = await Permission.notification.request();
    final androidGranted = status.isGranted;
    final iosGranted = await _fln
        .resolvePlatformSpecificImplementation<flutter_local_notifications.IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);
    return androidGranted && (iosGranted ?? true);
  }

  /// Check if notification permissions are granted
  Future<bool> arePermissionsGranted() async {
    final status = await Permission.notification.status;
    return status.isGranted;
  }

  flutter_local_notifications.NotificationDetails _defaultDetails() {
    const androidDetails = flutter_local_notifications.AndroidNotificationDetails(
      AppConstants.defaultNotificationChannelId,
      AppConstants.defaultNotificationChannelName,
      channelDescription: AppConstants.defaultNotificationChannelDescription,
      importance: flutter_local_notifications.Importance.max,
      priority: flutter_local_notifications.Priority.high,
      playSound: true,
    );
    const iosDetails = flutter_local_notifications.DarwinNotificationDetails();
    return const flutter_local_notifications.NotificationDetails(android: androidDetails, iOS: iosDetails);
  }

  /// Show prayer time notification immediately
  Future<void> showPrayerNotification(Prayer prayer, DateTime time) async {
    await _fln.show(
      _hashId('prayer-${prayer.name}-${time.millisecondsSinceEpoch}'),
      'Prayer Time: ${prayer.displayName}',
      'It\'s time for ${prayer.displayName}',
      _defaultDetails(),
    );
  }

  /// Show alarm notification immediately
  Future<void> showAlarmNotification(Alarm alarm) async {
    await _fln.show(
      _hashId('alarm-${alarm.id ?? alarm.displayLabel}-${DateTime.now().millisecondsSinceEpoch}'),
      'Azan Alarm',
      alarm.displayLabel,
      _defaultDetails(),
    );
  }

  /// Show general notification immediately
  Future<void> showNotification({
    required String title,
    required String body,
    String? channelId,
    int? id,
  }) async {
    await _fln.show(id ?? _hashId('now-$title-$body'), title, body, _defaultDetails());
  }

  /// Schedule a notification at a specific DateTime (local tz)
  Future<void> scheduleNotificationAt({
    required DateTime time,
    required String title,
    required String body,
    String payload = '',
    int? id,
  }) async {
    await initialize();
    final granted = await arePermissionsGranted();
    if (!granted) {
      final req = await requestPermissions();
      if (!req) return;
    }
    final tzTime = tz.TZDateTime.from(time, tz.local);
    await _fln.zonedSchedule(
      id ?? _hashId('sched-${title}-${time.millisecondsSinceEpoch}'),
      title,
      body,
      tzTime,
      _defaultDetails(),
      androidScheduleMode: flutter_local_notifications.AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: flutter_local_notifications.UILocalNotificationDateInterpretation.absoluteTime,
      payload: payload,
    );
  }

  /// Cancel notification
  Future<void> cancelNotification(int id) async {
    await _fln.cancel(id);
  }

  /// Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await _fln.cancelAll();
  }

  int _hashId(String s) => s.hashCode & 0x7fffffff;
}

/// Extension for AppSettings copyWith method
extension AppSettingsCopyWith on AppSettings {
  AppSettings copyWith({
    PrayerCalculationMethod? calculationMethod,
    JuristicMethod? juristicMethod,
    String? audioTheme,
    bool? is24HourFormat,
    bool? enableNotifications,
    bool? enableVibration,
    AppTheme? theme,
    String? language,
  }) {
    return AppSettings(
      calculationMethod: calculationMethod ?? this.calculationMethod,
      juristicMethod: juristicMethod ?? this.juristicMethod,
      audioTheme: audioTheme ?? this.audioTheme,
      is24HourFormat: is24HourFormat ?? this.is24HourFormat,
      enableNotifications: enableNotifications ?? this.enableNotifications,
      enableVibration: enableVibration ?? this.enableVibration,
      theme: theme ?? this.theme,
      language: language ?? this.language,
    );
  }
}