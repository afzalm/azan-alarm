/// Prayer time calculation using astronomical formulas
/// Based on the methodology from praytimes.org and other Islamic sources

import 'dart:math' as math;
import '../models/models.dart';

/// Prayer time calculator using astronomical algorithms
class PrayerTimeCalculator {
  /// Calculate prayer times for a given location and date
  /// 
  /// [latitude] in degrees (-90 to 90)
  /// [longitude] in degrees (-180 to 180)
  /// [date] the date for which to calculate prayer times
  /// [calculationMethod] the calculation method to use
  /// [juristicMethod] the juristic method for Asr calculation
  /// [timezoneOffset] timezone offset in hours from UTC (e.g., -5 for EST, +3 for Saudi Arabia)
  Map<Prayer, DateTime> calculate({
    required double latitude,
    required double longitude,
    required DateTime date,
    required PrayerCalculationMethod calculationMethod,
    required JuristicMethod juristicMethod,
    required double timezoneOffset,
  }) {
    // Get calculation parameters for the method
    final params = _getCalculationParams(calculationMethod);
    
    // Calculate Julian date
    final jd = _calculateJulianDate(date);
    
    // Calculate times in decimal hours (from midnight)
    final times = _calculatePrayerTimes(
      jd,
      latitude,
      longitude,
      timezoneOffset,
      params,
      juristicMethod,
    );
    
    // Convert decimal hours to DateTime objects
    return _convertToDateTime(date, times, timezoneOffset);
  }
  
  /// Get calculation parameters for a given method
  CalculationParams _getCalculationParams(PrayerCalculationMethod method) {
    switch (method) {
      case PrayerCalculationMethod.muslimWorldLeague:
        return CalculationParams(
          fajrAngle: 18.0,
          ishaAngle: 17.0,
          ishaInterval: 0,
          maghribAngle: 0,
          maghribInterval: 0,
        );
      
      case PrayerCalculationMethod.isna:
        return CalculationParams(
          fajrAngle: 15.0,
          ishaAngle: 15.0,
          ishaInterval: 0,
          maghribAngle: 0,
          maghribInterval: 0,
        );
      
      case PrayerCalculationMethod.egyptianGeneralAuthority:
        return CalculationParams(
          fajrAngle: 19.5,
          ishaAngle: 17.5,
          ishaInterval: 0,
          maghribAngle: 0,
          maghribInterval: 0,
        );
      
      case PrayerCalculationMethod.ummAlQura:
        return CalculationParams(
          fajrAngle: 18.5,
          ishaAngle: 0,
          ishaInterval: 90, // 90 minutes after Maghrib
          maghribAngle: 0,
          maghribInterval: 0,
        );
      
      case PrayerCalculationMethod.karachi:
        return CalculationParams(
          fajrAngle: 18.0,
          ishaAngle: 18.0,
          ishaInterval: 0,
          maghribAngle: 0,
          maghribInterval: 0,
        );
      
      case PrayerCalculationMethod.tehran:
        return CalculationParams(
          fajrAngle: 17.7,
          ishaAngle: 14.0,
          ishaInterval: 0,
          maghribAngle: 4.5,
          maghribInterval: 0,
        );
      
      case PrayerCalculationMethod.jafari:
        return CalculationParams(
          fajrAngle: 16.0,
          ishaAngle: 14.0,
          ishaInterval: 0,
          maghribAngle: 4.0,
          maghribInterval: 0,
        );
    }
  }
  
  /// Calculate Julian date from Gregorian date
  double _calculateJulianDate(DateTime date) {
    final year = date.year;
    final month = date.month;
    final day = date.day;
    
    if (month <= 2) {
      final adjustedYear = year - 1;
      final adjustedMonth = month + 12;
      return _julianFromGregorian(adjustedYear, adjustedMonth, day);
    }
    
    return _julianFromGregorian(year, month, day);
  }
  
  double _julianFromGregorian(int year, int month, int day) {
    final a = (14 - month) ~/ 12;
    final y = year + 4800 - a;
    final m = month + 12 * a - 3;
    
    return day + (153 * m + 2) ~/ 5 + 365 * y + y ~/ 4 - y ~/ 100 + y ~/ 400 - 32045;
  }
  
  /// Calculate prayer times
  Map<Prayer, double> _calculatePrayerTimes(
    double jd,
    double latitude,
    double longitude,
    double timezoneOffset,
    CalculationParams params,
    JuristicMethod juristicMethod,
  ) {
    // Calculate equation of time and solar declination
    final d = jd - 2451545.0; // Days since J2000.0
    final eqTime = _calculateEquationOfTime(d);
    final declination = _calculateSolarDeclination(d);
    
    // Calculate times
    final fajr = _calculateFajr(latitude, declination, params.fajrAngle);
    final sunrise = _calculateSunrise(latitude, declination);
    final dhuhr = _calculateDhuhr(longitude, timezoneOffset, eqTime);
    final asr = _calculateAsr(latitude, declination, juristicMethod);
    final maghrib = _calculateMaghrib(latitude, declination, params);
    final isha = _calculateIsha(latitude, declination, params, maghrib);
    
    return {
      Prayer.fajr: fajr,
      Prayer.dhuhr: dhuhr,
      Prayer.asr: asr,
      Prayer.maghrib: maghrib,
      Prayer.isha: isha,
    };
  }
  
  /// Calculate equation of time in minutes
  double _calculateEquationOfTime(double d) {
    // Mean anomaly of the Sun
    final g = 357.529 + 0.98560028 * d;
    final gRad = _degreesToRadians(g);
    
    // Mean longitude of the Sun
    final q = 280.459 + 0.98564736 * d;
    final qRad = _degreesToRadians(q);
    
    // Geocentric apparent ecliptic longitude of the Sun
    final l = q + 1.915 * math.sin(gRad) + 0.020 * math.sin(2 * gRad);
    final lRad = _degreesToRadians(l);
    
    // Mean obliquity of the ecliptic
    final e = 23.439 - 0.00000036 * d;
    final eRad = _degreesToRadians(e);
    
    // Right ascension
    final ra = _radiansToDegrees(math.atan2(math.cos(eRad) * math.sin(lRad), math.cos(lRad)));
    
    // Equation of time
    final eqTime = q - _fixHour(ra);
    return _fixHour(eqTime) * 4; // Convert to minutes
  }
  
  /// Calculate solar declination in degrees
  double _calculateSolarDeclination(double d) {
    // Mean anomaly of the Sun
    final g = 357.529 + 0.98560028 * d;
    final gRad = _degreesToRadians(g);
    
    // Mean longitude of the Sun
    final q = 280.459 + 0.98564736 * d;
    
    // Geocentric apparent ecliptic longitude of the Sun
    final l = q + 1.915 * math.sin(gRad) + 0.020 * math.sin(2 * gRad);
    final lRad = _degreesToRadians(l);
    
    // Mean obliquity of the ecliptic
    final e = 23.439 - 0.00000036 * d;
    final eRad = _degreesToRadians(e);
    
    // Solar declination
    return _radiansToDegrees(math.asin(math.sin(eRad) * math.sin(lRad)));
  }
  
  /// Calculate Fajr time (dawn)
  double _calculateFajr(double latitude, double declination, double angle) {
    return _calculateTimeForAngle(latitude, declination, angle, before: true);
  }
  
  /// Calculate Sunrise time
  double _calculateSunrise(double latitude, double declination) {
    // Sunrise angle is 0.833 degrees (atmospheric refraction + sun's radius)
    return _calculateTimeForAngle(latitude, declination, 0.833, before: true);
  }
  
  /// Calculate Dhuhr time (solar noon)
  double _calculateDhuhr(double longitude, double timezoneOffset, double eqTime) {
    // Dhuhr is when the sun crosses the meridian
    return 12 + timezoneOffset - longitude / 15.0 - eqTime / 60.0;
  }
  
  /// Calculate Asr time (afternoon)
  double _calculateAsr(double latitude, double declination, JuristicMethod method) {
    // Shadow factor: 1 for Shafi'i/Standard, 2 for Hanafi
    final shadowFactor = method == JuristicMethod.hanafi ? 2.0 : 1.0;
    
    final latRad = _degreesToRadians(latitude);
    final decRad = _degreesToRadians(declination);
    
    // Calculate the angle
    final numerator = math.sin(math.atan(1 / (shadowFactor + math.tan((latRad - decRad).abs()))));
    final denominator = math.sin(latRad) * math.sin(decRad) + math.cos(latRad) * math.cos(decRad);
    
    final angle = -_radiansToDegrees(math.asin((numerator - denominator) / (math.cos(latRad) * math.cos(decRad))));
    
    return _calculateTimeForAngle(latitude, declination, angle, before: false);
  }
  
  /// Calculate Maghrib time (sunset)
  double _calculateMaghrib(double latitude, double declination, CalculationParams params) {
    if (params.maghribAngle > 0) {
      // Some methods use an angle after sunset
      return _calculateTimeForAngle(latitude, declination, params.maghribAngle, before: false);
    } else if (params.maghribInterval > 0) {
      // Some methods use minutes after sunset
      final sunset = _calculateTimeForAngle(latitude, declination, 0.833, before: false);
      return sunset + params.maghribInterval / 60.0;
    } else {
      // Standard: 0.833 degrees (same as sunrise but after)
      return _calculateTimeForAngle(latitude, declination, 0.833, before: false);
    }
  }
  
  /// Calculate Isha time (night)
  double _calculateIsha(double latitude, double declination, CalculationParams params, double maghrib) {
    if (params.ishaInterval > 0) {
      // Some methods use minutes after Maghrib
      return maghrib + params.ishaInterval / 60.0;
    } else {
      // Standard: use angle
      return _calculateTimeForAngle(latitude, declination, params.ishaAngle, before: false);
    }
  }
  
  /// Calculate time for a given sun angle
  double _calculateTimeForAngle(double latitude, double declination, double angle, {required bool before}) {
    final latRad = _degreesToRadians(latitude);
    final decRad = _degreesToRadians(declination);
    final angleRad = _degreesToRadians(angle);
    
    // Hour angle
    final cosH = (math.cos(angleRad) - math.sin(latRad) * math.sin(decRad)) / 
                 (math.cos(latRad) * math.cos(decRad));
    
    // Check for invalid values (sun never rises/sets at extreme latitudes)
    if (cosH > 1 || cosH < -1) {
      return double.nan;
    }
    
    final h = _radiansToDegrees(math.acos(cosH));
    
    if (before) {
      return 12 - h / 15.0;
    } else {
      return 12 + h / 15.0;
    }
  }
  
  /// Convert decimal hours to DateTime objects
  Map<Prayer, DateTime> _convertToDateTime(DateTime date, Map<Prayer, double> times, double timezoneOffset) {
    final result = <Prayer, DateTime>{};
    
    for (final entry in times.entries) {
      final decimalHours = entry.value;
      
      if (decimalHours.isNaN) {
        // For extreme latitudes where prayer time doesn't occur
        // Use a reasonable default or skip
        continue;
      }
      
      final hours = decimalHours.floor();
      final minutes = ((decimalHours - hours) * 60).round();
      
      result[entry.key] = DateTime(
        date.year,
        date.month,
        date.day,
        hours,
        minutes,
      );
    }
    
    return result;
  }
  
  /// Convert degrees to radians
  double _degreesToRadians(double degrees) {
    return degrees * math.pi / 180.0;
  }
  
  /// Convert radians to degrees
  double _radiansToDegrees(double radians) {
    return radians * 180.0 / math.pi;
  }
  
  /// Fix hour to be in range [0, 24)
  double _fixHour(double hour) {
    return hour - 24.0 * (hour / 24.0).floor();
  }
}

/// Calculation parameters for different methods
class CalculationParams {
  final double fajrAngle;      // Sun angle for Fajr
  final double ishaAngle;      // Sun angle for Isha
  final int ishaInterval;      // Minutes after Maghrib for Isha (0 if using angle)
  final double maghribAngle;   // Sun angle for Maghrib (0 for standard sunset)
  final int maghribInterval;   // Minutes after sunset for Maghrib (0 if using angle)
  
  CalculationParams({
    required this.fajrAngle,
    required this.ishaAngle,
    required this.ishaInterval,
    required this.maghribAngle,
    required this.maghribInterval,
  });
}
