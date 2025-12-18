/// App-wide constants and configuration
class AppConstants {
  // App Information
  static const String appName = 'AzanAlarm';
  static const String appVersion = '1.0.0';
  
  // Database
  static const String databaseName = 'azan_alarm.db';
  static const int databaseVersion = 1;
  
  // Prayer Times
  static const List<String> prayerNames = [
    'Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'
  ];
  
  // Default Settings
  static const String defaultCalculationMethod = 'muslimWorldLeague';
  static const String defaultJuristicMethod = 'shafii';
  static const bool default24HourFormat = false;
  static const bool defaultNotificationsEnabled = true;
  static const bool defaultVibrationEnabled = true;
  
  // Animation Durations
  static const Duration shortAnimationDuration = Duration(milliseconds: 200);
  static const Duration mediumAnimationDuration = Duration(milliseconds: 300);
  static const Duration longAnimationDuration = Duration(milliseconds: 500);
  
  // API Endpoints (for future use)
  static const String baseUrl = 'https://api.azanalarm.com';
  static const String prayerTimesApiUrl = '$baseUrl/v1/prayer-times';
  static const String locationsApiUrl = '$baseUrl/v1/locations';
  
  // Cache Settings
  static const Duration prayerTimesCacheExpiry = Duration(days: 7);
  static const Duration locationCacheExpiry = Duration(days: 30);
  
  // Notification Settings
  static const String defaultNotificationChannelId = 'azan_alarms';
  static const String defaultNotificationChannelName = 'Azan Alarms';
  static const String defaultNotificationChannelDescription = 'Prayer time alarms and reminders';
  
  // File Paths
  static const String audioDirectory = 'assets/audio/';
  static const String imagesDirectory = 'assets/images/';
  static const String iconsDirectory = 'assets/icons/';
  
  // SharedPreferences Keys
  static const String spCurrentLocation = 'current_location';
  static const String spUserSettings = 'user_settings';
  static const String spFirstLaunch = 'first_launch';
  static const String spLastPrayerTimeUpdate = 'last_prayer_time_update';
}