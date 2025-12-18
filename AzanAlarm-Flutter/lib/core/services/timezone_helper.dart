/// Timezone helper utilities for prayer time calculations
/// Helps convert between UTC and local timezones accurately

import 'package:timezone/timezone.dart' as tz;

class TimezoneHelper {
  /// Get timezone offset in hours for a given location and date
  /// This accounts for daylight saving time changes
  static double getTimezoneOffset(DateTime date, {String? timezoneName}) {
    try {
      // If timezone name is provided, use it
      if (timezoneName != null && timezoneName.isNotEmpty) {
        final location = tz.getLocation(timezoneName);
        final tzDateTime = tz.TZDateTime.from(date, location);
        return tzDateTime.timeZoneOffset.inHours.toDouble() +
            (tzDateTime.timeZoneOffset.inMinutes % 60) / 60.0;
      }
      
      // Otherwise, use local timezone
      final localOffset = date.timeZoneOffset;
      return localOffset.inHours.toDouble() + 
          (localOffset.inMinutes % 60) / 60.0;
    } catch (e) {
      // Fallback to local timezone offset
      final localOffset = date.timeZoneOffset;
      return localOffset.inHours.toDouble() + 
          (localOffset.inMinutes % 60) / 60.0;
    }
  }
  
  /// Detect timezone from coordinates (best effort)
  /// Returns IANA timezone identifier (e.g., 'America/New_York')
  /// This is a simplified version - for production, use a timezone lookup service
  static String? detectTimezoneFromCoordinates(double latitude, double longitude) {
    // This is a very rough approximation based on longitude
    // In production, you should use a proper timezone lookup service/API
    // or a package like 'timezone_helper' or 'geo_timezone'
    
    final offsetHours = (longitude / 15.0).round();
    
    // Try to map to common timezones based on offset
    final commonTimezones = {
      -12: 'Pacific/Fiji',
      -11: 'Pacific/Samoa',
      -10: 'Pacific/Honolulu',
      -9: 'America/Anchorage',
      -8: 'America/Los_Angeles',
      -7: 'America/Denver',
      -6: 'America/Chicago',
      -5: 'America/New_York',
      -4: 'America/Halifax',
      -3: 'America/Sao_Paulo',
      -2: 'Atlantic/South_Georgia',
      -1: 'Atlantic/Azores',
      0: 'Europe/London',
      1: 'Europe/Paris',
      2: 'Europe/Athens',
      3: 'Asia/Riyadh',
      4: 'Asia/Dubai',
      5: 'Asia/Karachi',
      6: 'Asia/Dhaka',
      7: 'Asia/Bangkok',
      8: 'Asia/Singapore',
      9: 'Asia/Tokyo',
      10: 'Australia/Sydney',
      11: 'Pacific/Noumea',
      12: 'Pacific/Auckland',
    };
    
    return commonTimezones[offsetHours];
  }
  
  /// Get all available timezone names
  static List<String> getAllTimezones() {
    return tz.timeZoneDatabase.locations.keys.toList()..sort();
  }
  
  /// Search timezones by name or region
  static List<String> searchTimezones(String query) {
    final lowercaseQuery = query.toLowerCase();
    return getAllTimezones()
        .where((tz) => tz.toLowerCase().contains(lowercaseQuery))
        .toList();
  }
  
  /// Format timezone offset for display (e.g., "+05:30", "-08:00")
  static String formatTimezoneOffset(double offsetHours) {
    final hours = offsetHours.floor().abs();
    final minutes = ((offsetHours.abs() - hours) * 60).round();
    final sign = offsetHours >= 0 ? '+' : '-';
    return '$sign${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';
  }
}
