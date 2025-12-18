import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_azan_alarm/core/services/prayer_time_calculator.dart';
import 'package:flutter_azan_alarm/core/models/models.dart';

void main() {
  group('PrayerTimeCalculator', () {
    final calculator = PrayerTimeCalculator();

    test('calculates prayer times for New York (MWL method)', () {
      // New York: 40.7128° N, 74.0060° W
      // Date: January 15, 2024
      // Timezone: EST (UTC-5)
      final times = calculator.calculate(
        latitude: 40.7128,
        longitude: -74.0060,
        date: DateTime(2024, 1, 15),
        calculationMethod: PrayerCalculationMethod.muslimWorldLeague,
        juristicMethod: JuristicMethod.shafii,
        timezoneOffset: -5.0,
      );

      expect(times.length, 5);
      expect(times.containsKey(Prayer.fajr), true);
      expect(times.containsKey(Prayer.dhuhr), true);
      expect(times.containsKey(Prayer.asr), true);
      expect(times.containsKey(Prayer.maghrib), true);
      expect(times.containsKey(Prayer.isha), true);

      // Verify approximate times (within reasonable range for New York in January)
      final fajr = times[Prayer.fajr]!;
      final dhuhr = times[Prayer.dhuhr]!;
      final asr = times[Prayer.asr]!;
      final maghrib = times[Prayer.maghrib]!;
      final isha = times[Prayer.isha]!;

      // Fajr should be early morning (around 5:30-6:30 AM in winter)
      expect(fajr.hour, inInclusiveRange(5, 7));
      
      // Dhuhr should be around solar noon (around 12:00 PM)
      expect(dhuhr.hour, inInclusiveRange(11, 13));
      
      // Asr should be afternoon (around 2:00-3:00 PM in winter)
      expect(asr.hour, inInclusiveRange(13, 15));
      
      // Maghrib should be evening (around 4:30-5:30 PM in winter)
      expect(maghrib.hour, inInclusiveRange(16, 18));
      
      // Isha should be night (around 6:00-7:00 PM in winter)
      expect(isha.hour, inInclusiveRange(17, 20));

      // Prayer times should be in chronological order
      expect(fajr.isBefore(dhuhr), true);
      expect(dhuhr.isBefore(asr), true);
      expect(asr.isBefore(maghrib), true);
      expect(maghrib.isBefore(isha), true);
    });

    test('calculates prayer times for Makkah (Umm al-Qura method)', () {
      // Makkah: 21.4225° N, 39.8262° E
      // Date: June 15, 2024 (summer)
      // Timezone: AST (UTC+3)
      final times = calculator.calculate(
        latitude: 21.4225,
        longitude: 39.8262,
        date: DateTime(2024, 6, 15),
        calculationMethod: PrayerCalculationMethod.ummAlQura,
        juristicMethod: JuristicMethod.shafii,
        timezoneOffset: 3.0,
      );

      expect(times.length, 5);
      
      final fajr = times[Prayer.fajr]!;
      final dhuhr = times[Prayer.dhuhr]!;
      final maghrib = times[Prayer.maghrib]!;
      final isha = times[Prayer.isha]!;

      // Verify times are reasonable for Makkah in summer
      expect(fajr.hour, inInclusiveRange(3, 5));
      expect(dhuhr.hour, inInclusiveRange(11, 13));
      expect(maghrib.hour, inInclusiveRange(18, 20));
      expect(isha.hour, inInclusiveRange(19, 22));
      
      // Umm al-Qura method: Isha is 90 minutes after Maghrib
      final ishaOffset = isha.difference(maghrib).inMinutes;
      expect(ishaOffset, closeTo(90, 2)); // Allow 2 minute tolerance for rounding
    });

    test('calculates prayer times for London (ISNA method)', () {
      // London: 51.5074° N, 0.1278° W
      // Date: July 15, 2024 (summer - long days)
      // Timezone: BST (UTC+1)
      final times = calculator.calculate(
        latitude: 51.5074,
        longitude: -0.1278,
        date: DateTime(2024, 7, 15),
        calculationMethod: PrayerCalculationMethod.isna,
        juristicMethod: JuristicMethod.shafii,
        timezoneOffset: 1.0,
      );

      expect(times.length, 5);
      
      final fajr = times[Prayer.fajr]!;
      final maghrib = times[Prayer.maghrib]!;

      // In London summer, Fajr is very early and Maghrib very late
      expect(fajr.hour, inInclusiveRange(1, 4));
      expect(maghrib.hour, inInclusiveRange(20, 22));
    });

    test('Hanafi Asr calculation differs from Shafii', () {
      // Same location and date, different juristic methods
      final latitude = 40.7128;
      final longitude = -74.0060;
      final date = DateTime(2024, 3, 15);
      final timezoneOffset = -4.0; // EDT

      final shafiiTimes = calculator.calculate(
        latitude: latitude,
        longitude: longitude,
        date: date,
        calculationMethod: PrayerCalculationMethod.muslimWorldLeague,
        juristicMethod: JuristicMethod.shafii,
        timezoneOffset: timezoneOffset,
      );

      final hanafiTimes = calculator.calculate(
        latitude: latitude,
        longitude: longitude,
        date: date,
        calculationMethod: PrayerCalculationMethod.muslimWorldLeague,
        juristicMethod: JuristicMethod.hanafi,
        timezoneOffset: timezoneOffset,
      );

      final shafiiAsr = shafiiTimes[Prayer.asr]!;
      final hanafiAsr = hanafiTimes[Prayer.asr]!;

      // Hanafi Asr should be later than Shafii Asr
      expect(hanafiAsr.isAfter(shafiiAsr), true);
      
      // Difference should be reasonable (typically 30-60 minutes)
      final difference = hanafiAsr.difference(shafiiAsr).inMinutes;
      expect(difference, inInclusiveRange(15, 90));
    });

    test('different calculation methods produce different Fajr times', () {
      final latitude = 40.7128;
      final longitude = -74.0060;
      final date = DateTime(2024, 3, 15);
      final timezoneOffset = -4.0;

      final mwlTimes = calculator.calculate(
        latitude: latitude,
        longitude: longitude,
        date: date,
        calculationMethod: PrayerCalculationMethod.muslimWorldLeague,
        juristicMethod: JuristicMethod.shafii,
        timezoneOffset: timezoneOffset,
      );

      final isnaTimes = calculator.calculate(
        latitude: latitude,
        longitude: longitude,
        date: date,
        calculationMethod: PrayerCalculationMethod.isna,
        juristicMethod: JuristicMethod.shafii,
        timezoneOffset: timezoneOffset,
      );

      final egyptTimes = calculator.calculate(
        latitude: latitude,
        longitude: longitude,
        date: date,
        calculationMethod: PrayerCalculationMethod.egyptianGeneralAuthority,
        juristicMethod: JuristicMethod.shafii,
        timezoneOffset: timezoneOffset,
      );

      // Different calculation methods should produce different Fajr times
      final mwlFajr = mwlTimes[Prayer.fajr]!;
      final isnaFajr = isnaTimes[Prayer.fajr]!;
      final egyptFajr = egyptTimes[Prayer.fajr]!;

      // MWL uses 18°, ISNA uses 15°, Egypt uses 19.5°
      // Smaller angle = later Fajr time
      expect(isnaFajr.isAfter(mwlFajr), true); // ISNA (15°) is later than MWL (18°)
      expect(mwlFajr.isAfter(egyptFajr), true); // MWL (18°) is later than Egypt (19.5°)
    });

    test('prayer times adjust correctly with seasons', () {
      final latitude = 40.7128;
      final longitude = -74.0060;
      final timezoneOffset = -5.0;

      // Winter (January)
      final winterTimes = calculator.calculate(
        latitude: latitude,
        longitude: longitude,
        date: DateTime(2024, 1, 15),
        calculationMethod: PrayerCalculationMethod.muslimWorldLeague,
        juristicMethod: JuristicMethod.shafii,
        timezoneOffset: timezoneOffset,
      );

      // Summer (July)
      final summerTimes = calculator.calculate(
        latitude: latitude,
        longitude: longitude,
        date: DateTime(2024, 7, 15),
        calculationMethod: PrayerCalculationMethod.muslimWorldLeague,
        juristicMethod: JuristicMethod.shafii,
        timezoneOffset: timezoneOffset - 1, // DST adjustment
      );

      final winterFajr = winterTimes[Prayer.fajr]!;
      final winterMaghrib = winterTimes[Prayer.maghrib]!;
      final summerFajr = summerTimes[Prayer.fajr]!;
      final summerMaghrib = summerTimes[Prayer.maghrib]!;

      // Summer: Fajr earlier, Maghrib later (longer days)
      expect(summerFajr.hour, lessThan(winterFajr.hour));
      expect(summerMaghrib.hour, greaterThan(winterMaghrib.hour));
    });
  });
}
