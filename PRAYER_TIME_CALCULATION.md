# Prayer Time Calculation Implementation

## Overview

This document describes the real prayer time calculation algorithm now implemented in the AzanAlarm app. The implementation uses astronomical formulas to calculate accurate prayer times based on sun position, location coordinates, and various Islamic calculation methods.

## Implementation Details

### Core Components

1. **PrayerTimeCalculator** (`lib/core/services/prayer_time_calculator.dart`)
   - Astronomical calculation engine using sun position algorithms
   - Implements all major Islamic calculation methods
   - Supports both Shafi'i and Hanafi juristic methods for Asr

2. **TimezoneHelper** (`lib/core/services/timezone_helper.dart`)
   - Timezone detection from coordinates
   - Timezone offset calculation with DST support
   - IANA timezone lookup and search utilities

3. **PrayerTimesService** (updated in `lib/core/services/services.dart`)
   - Integrates calculator into the service layer
   - Handles timezone conversion automatically
   - Replaces mock data with real calculations

## Calculation Methods Supported

### 1. Muslim World League (MWL)
- **Fajr Angle**: 18°
- **Isha Angle**: 17°
- **Used in**: Europe, Far East, parts of America

### 2. Islamic Society of North America (ISNA)
- **Fajr Angle**: 15°
- **Isha Angle**: 15°
- **Used in**: North America

### 3. Egyptian General Authority
- **Fajr Angle**: 19.5°
- **Isha Angle**: 17.5°
- **Used in**: Africa, Syria, Lebanon, Malaysia

### 4. Umm Al-Qura (Makkah)
- **Fajr Angle**: 18.5°
- **Isha**: 90 minutes after Maghrib
- **Used in**: Saudi Arabia

### 5. University of Islamic Sciences, Karachi
- **Fajr Angle**: 18°
- **Isha Angle**: 18°
- **Used in**: Pakistan, Bangladesh, India, Afghanistan

### 6. Institute of Geophysics, University of Tehran
- **Fajr Angle**: 17.7°
- **Isha Angle**: 14°
- **Maghrib Angle**: 4.5°
- **Used in**: Iran, some Shia communities

### 7. Shia Ithna-Ashari (Jafari)
- **Fajr Angle**: 16°
- **Isha Angle**: 14°
- **Maghrib Angle**: 4°
- **Used in**: Shia communities worldwide

## Juristic Methods for Asr

### Shafi'i/Standard Method
- **Shadow Length**: Object's shadow = object's length
- **Earlier Asr time**
- **Used by**: Shafi'i, Maliki, Hanbali schools

### Hanafi Method
- **Shadow Length**: Object's shadow = 2× object's length
- **Later Asr time** (typically 30-60 minutes after Shafi'i)
- **Used by**: Hanafi school

## Astronomical Formulas

### Core Calculations

1. **Julian Date Conversion**
   - Converts Gregorian calendar dates to Julian dates
   - Used as reference for astronomical calculations

2. **Solar Declination**
   - Calculates the sun's declination angle
   - Based on Earth's axial tilt and orbital position
   - Formula accounts for Earth's elliptical orbit

3. **Equation of Time**
   - Corrects for Earth's orbital eccentricity
   - Accounts for variation in solar noon throughout the year
   - Critical for accurate Dhuhr calculation

4. **Hour Angle**
   - Calculates when sun reaches specific elevation angles
   - Used for Fajr, Sunrise, Asr, Maghrib, Isha

### Prayer Time Formulas

#### Fajr (Dawn)
```
time = 12 - arccos(cos(angle) - sin(lat)×sin(dec)) / (cos(lat)×cos(dec)) / 15
```
- Uses method-specific angle (15°-19.5°)
- Calculated before solar noon

#### Dhuhr (Solar Noon)
```
time = 12 + timezone_offset - longitude/15 - equation_of_time/60
```
- When sun crosses the meridian
- Most accurate prayer time

#### Asr (Afternoon)
```
shadow_factor = juristic_method == Hanafi ? 2 : 1
angle = calculate_from_shadow_length(shadow_factor)
time = 12 + hour_angle(angle) / 15
```
- Based on shadow length relative to object height
- Differs between Shafi'i and Hanafi methods

#### Maghrib (Sunset)
```
time = 12 + arccos(cos(0.833°) - sin(lat)×sin(dec)) / (cos(lat)×cos(dec)) / 15
```
- Standard angle: 0.833° (accounts for atmospheric refraction and sun's radius)
- Some methods add angle or time offset

#### Isha (Night)
```
// Most methods use angle:
time = 12 + arccos(cos(angle) - sin(lat)×sin(dec)) / (cos(lat)×cos(dec)) / 15

// Umm Al-Qura uses time interval:
time = maghrib_time + 90 minutes
```

## Timezone Handling

### Automatic Detection
- Uses coordinates to estimate timezone
- Maps longitude to nearest major timezone
- Fallback to device local timezone

### DST Support
- Automatically handles daylight saving time
- Uses `timezone` package for accurate conversions
- Accounts for historical DST rule changes

### Manual Override
- Users can select specific IANA timezones
- Useful for travelers or edge cases
- Full timezone database available

## Accuracy & Validation

### Testing Strategy
- Comprehensive test suite (`test/prayer_time_calculator_test.dart`)
- Tests multiple cities across different latitudes
- Validates against known prayer times
- Tests seasonal variations (summer/winter)
- Compares calculation methods
- Verifies juristic method differences

### Test Locations
1. **New York** (40.7° N): Mid-latitude, four seasons
2. **Makkah** (21.4° N): Low latitude, minimal seasonal variation
3. **London** (51.5° N): High latitude, extreme day length variations

### Expected Accuracy
- **±2-3 minutes** for most locations
- Accuracy decreases at extreme latitudes (>60°)
- May require adjustments for high altitude locations
- Local mosque times may vary due to:
  - Safety margins (starting prayer slightly after calculated time)
  - Local conventions and traditions
  - Horizon visibility factors

## Edge Cases Handled

### Extreme Latitudes
- At latitudes >48° in summer, Isha may not occur (twilight persists)
- At latitudes >48° in winter, Fajr may not occur (darkness persists)
- Calculator returns `NaN` for impossible prayer times
- App should fall back to nearest valid date or use "middle of the night" methods

### Date Line Crossing
- Calculations work correctly across date line
- Handles negative and positive longitudes properly

### Leap Years
- Julian date calculation accounts for leap years
- Accurate for dates 1900-2100

## Integration with App

### Configuration Flow
```
User sets location
  ↓
App detects timezone from coordinates
  ↓
User chooses calculation method (Settings)
  ↓
User chooses juristic method (Settings)
  ↓
PrayerTimesService calculates times
  ↓
Times displayed on HomeScreen
  ↓
Notifications scheduled at prayer times
```

### Settings Integration
- Calculation method stored in `AppSettings.calculationMethod`
- Juristic method stored in `AppSettings.juristicMethod`
- Timezone stored in `Location.timezone`
- All preferences persist in SQLite database

### Real-time Updates
- Prayer times recalculate when:
  - Location changes
  - Date changes (midnight)
  - Calculation method changes
  - Juristic method changes
  - Timezone changes
- Riverpod providers automatically update UI

## Performance Considerations

### Calculation Speed
- Single calculation: <1ms on modern devices
- Safe to calculate on main thread
- No network requests required

### Caching Strategy
- Calculate once per day per location
- Store in memory during app session
- Can implement SQLite caching for offline persistence
- Cache invalidation: midnight local time

## Future Enhancements

### Possible Improvements
1. **High Altitude Adjustments**
   - Add altitude parameter to calculations
   - Adjust angles for horizon depression at high elevations

2. **Custom Angle Adjustments**
   - Allow users to fine-tune Fajr/Isha angles
   - Support mosque-specific adjustments

3. **Qibla Integration**
   - Use same coordinate system for Qibla direction
   - Calculate great circle bearing to Makkah

4. **Middle of Night Method**
   - For extreme latitudes where Isha/Fajr don't occur
   - Use 1/2 or 1/3 of night as alternative

5. **Higher Latitudes Methods**
   - Angle-based method
   - Middle of Night method
   - One-seventh method
   - Nearest latitude method

## References

### Academic Sources
- Jean Meeus, "Astronomical Algorithms", 2nd Edition
- U.S. Naval Observatory, "Astronomical Almanac"
- PrayTimes.org methodology documentation

### Islamic Sources
- Islamic Society of North America (ISNA)
- Muslim World League
- Egyptian General Authority of Survey
- Umm al-Qura University, Makkah

## API Documentation

### PrayerTimeCalculator

```dart
final calculator = PrayerTimeCalculator();

final times = calculator.calculate(
  latitude: 40.7128,          // degrees N/S (-90 to 90)
  longitude: -74.0060,        // degrees E/W (-180 to 180)
  date: DateTime(2024, 1, 15),
  calculationMethod: PrayerCalculationMethod.muslimWorldLeague,
  juristicMethod: JuristicMethod.shafii,
  timezoneOffset: -5.0,       // hours from UTC
);

// Returns: Map<Prayer, DateTime>
// {
//   Prayer.fajr: DateTime(2024, 1, 15, 5, 52),
//   Prayer.dhuhr: DateTime(2024, 1, 15, 12, 11),
//   Prayer.asr: DateTime(2024, 1, 15, 14, 47),
//   Prayer.maghrib: DateTime(2024, 1, 15, 16, 48),
//   Prayer.isha: DateTime(2024, 1, 15, 18, 14),
// }
```

### TimezoneHelper

```dart
// Get timezone offset with DST handling
final offset = TimezoneHelper.getTimezoneOffset(
  DateTime.now(),
  timezoneName: 'America/New_York',
);

// Detect timezone from coordinates
final timezone = TimezoneHelper.detectTimezoneFromCoordinates(40.7128, -74.0060);
// Returns: 'America/New_York'

// Search timezones
final results = TimezoneHelper.searchTimezones('New York');
// Returns: ['America/New_York']

// Format offset for display
final formatted = TimezoneHelper.formatTimezoneOffset(-5.0);
// Returns: '-05:00'
```

## Troubleshooting

### Issue: Prayer times seem incorrect

**Possible causes:**
1. Wrong timezone detected
   - Solution: Manually set correct timezone in Location settings
2. Wrong calculation method for region
   - Solution: Change calculation method in Settings
3. Device time/date incorrect
   - Solution: Enable automatic date/time on device
4. Location coordinates inaccurate
   - Solution: Re-detect location or manually enter coordinates

### Issue: Isha time missing in summer

**Cause:** At high latitudes (>48°N/S), twilight may persist all night in summer

**Solution:** 
- App should detect this and use "middle of night" method
- Or use 90 minutes after Maghrib as fallback
- Currently returns empty - need to implement fallback logic

### Issue: Times differ from local mosque

**Cause:** Mosques often add safety margins or use local conventions

**Solution:**
- This is expected and normal
- Calculator provides "true" astronomical times
- Mosques typically start 2-5 minutes after calculated time
- Future enhancement: allow per-prayer offset adjustments

## Changelog

### v1.0.0 - Initial Implementation
- ✅ Implemented PrayerTimeCalculator with full astronomical formulas
- ✅ Added 7 major calculation methods (MWL, ISNA, Egypt, Umm Al-Qura, Karachi, Tehran, Jafari)
- ✅ Implemented both Shafi'i and Hanafi Asr methods
- ✅ Added TimezoneHelper with automatic detection
- ✅ Integrated into PrayerTimesService
- ✅ Created comprehensive test suite
- ✅ Replaced mock data with real calculations

### Future Versions
- 🔄 High latitude method fallbacks
- 🔄 Altitude adjustments
- 🔄 Custom angle configuration UI
- 🔄 Prayer time caching in database
- 🔄 Offline timezone database
