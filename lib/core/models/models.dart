/// Data models for the AzanAlarm application

/// Location model representing a geographic location
class Location {
  final int? id;
  final String name;
  final String country;
  final double latitude;
  final double longitude;
  final String timezone;
  final bool isCurrent;
  final DateTime createdAt;

  const Location({
    this.id,
    required this.name,
    required this.country,
    required this.latitude,
    required this.longitude,
    required this.timezone,
    this.isCurrent = false,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'country': country,
      'latitude': latitude,
      'longitude': longitude,
      'timezone': timezone,
      'isCurrent': isCurrent,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      id: json['id'],
      name: json['name'] ?? '',
      country: json['country'] ?? '',
      latitude: json['latitude']?.toDouble() ?? 0.0,
      longitude: json['longitude']?.toDouble() ?? 0.0,
      timezone: json['timezone'] ?? '',
      isCurrent: json['isCurrent'] ?? false,
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['createdAt'] ?? 0),
    );
  }

  /// Get location as a formatted string
  String get displayName => '$name, $country';
  
  /// Check if this is the same location as another
  bool isSameLocation(Location other) {
    return latitude == other.latitude && 
           longitude == other.longitude;
  }
}

/// Prayer enumeration
enum Prayer {
  fajr,
  dhuhr,
  asr,
  maghrib,
  isha,
}

/// Prayer time model
class PrayerTime {
  final Prayer prayer;
  final DateTime time;
  final bool hasPassed;
  final DateTime? nextOccurrence;

  const PrayerTime({
    required this.prayer,
    required this.time,
    this.hasPassed = false,
    this.nextOccurrence,
  });

  Map<String, dynamic> toJson() {
    return {
      'prayer': prayer.name,
      'time': time.millisecondsSinceEpoch,
      'hasPassed': hasPassed,
      'nextOccurrence': nextOccurrence?.millisecondsSinceEpoch,
    };
  }

  factory PrayerTime.fromJson(Map<String, dynamic> json) {
    return PrayerTime(
      prayer: Prayer.values.firstWhere(
        (e) => e.name == json['prayer'],
        orElse: () => Prayer.fajr,
      ),
      time: DateTime.fromMillisecondsSinceEpoch(json['time'] ?? 0),
      hasPassed: json['hasPassed'] ?? false,
      nextOccurrence: json['nextOccurrence'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['nextOccurrence'])
          : null,
    );
  }
}

/// Alarm model
class Alarm {
  final int? id;
  final Prayer prayer;
  final int offsetMinutes; // Negative for before, positive for after
  final String? label;
  final String? soundPath;
  final bool isActive;
  final List<int> repeatDays;
  final bool vibrationEnabled;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Alarm({
    this.id,
    required this.prayer,
    required this.offsetMinutes,
    this.label,
    this.soundPath,
    this.isActive = true,
    this.repeatDays = const [],
    this.vibrationEnabled = true,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'prayer': prayer.name,
      'offsetMinutes': offsetMinutes,
      'label': label,
      'soundPath': soundPath,
      'isActive': isActive,
      'repeatDays': repeatDays,
      'vibrationEnabled': vibrationEnabled,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
    };
  }

  factory Alarm.fromJson(Map<String, dynamic> json) {
    return Alarm(
      id: json['id'],
      prayer: Prayer.values.firstWhere(
        (e) => e.name == json['prayer'],
        orElse: () => Prayer.fajr,
      ),
      offsetMinutes: json['offsetMinutes'] ?? 0,
      label: json['label'],
      soundPath: json['soundPath'],
      isActive: json['isActive'] ?? true,
      repeatDays: (json['repeatDays'] as List<dynamic>?)
              ?.map((e) => e as int)
              .toList() ??
          [],
      vibrationEnabled: json['vibrationEnabled'] ?? true,
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['createdAt'] ?? 0),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(json['updatedAt'] ?? 0),
    );
  }

  /// Get the actual alarm time by applying offset to prayer time
  DateTime getActualAlarmTime(DateTime prayerTime) {
    return prayerTime.add(Duration(minutes: offsetMinutes));
  }
  
  /// Check if alarm should trigger on a specific day
  bool shouldTriggerOnDay(DateTime date) {
    // 1 = Monday, 7 = Sunday (Dart DateTime format)
    final dayOfWeek = date.weekday;
    return repeatDays.isEmpty || repeatDays.contains(dayOfWeek);
  }
  
  /// Get alarm display label
  String get displayLabel {
    if (label != null && label!.isNotEmpty) {
      return label!;
    }
    
    final timeDirection = offsetMinutes < 0 ? 'before' : 'after';
    final timeOffset = offsetMinutes.abs();
    
    if (timeOffset == 0) {
      return 'At ${prayer.displayName} time';
    } else {
      return '$timeOffset min $timeDirection ${prayer.displayName}';
    }
  }

  Alarm copyWith({
    int? id,
    Prayer? prayer,
    int? offsetMinutes,
    String? label,
    String? soundPath,
    bool? isActive,
    List<int>? repeatDays,
    bool? vibrationEnabled,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Alarm(
      id: id ?? this.id,
      prayer: prayer ?? this.prayer,
      offsetMinutes: offsetMinutes ?? this.offsetMinutes,
      label: label ?? this.label,
      soundPath: soundPath ?? this.soundPath,
      isActive: isActive ?? this.isActive,
      repeatDays: repeatDays ?? this.repeatDays,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// Prayer calculation methods
enum PrayerCalculationMethod {
  muslimWorldLeague,
  egyptian,
  karachi,
  ummAlQura,
  gulf,
  moonsightingCommittee,
  northAmerica,
  other,
}

/// Juristic calculation methods
enum JuristicMethod {
  shafii,
  hanafi,
}

/// App theme options
enum AppTheme {
  light,
  dark,
  system,
}

/// Application settings model
class AppSettings {
  final PrayerCalculationMethod calculationMethod;
  final JuristicMethod juristicMethod;
  final String audioTheme;
  final bool is24HourFormat;
  final bool enableNotifications;
  final bool enableVibration;
  final AppTheme theme;
  final String language;

  const AppSettings({
    this.calculationMethod = PrayerCalculationMethod.muslimWorldLeague,
    this.juristicMethod = JuristicMethod.shafii,
    this.audioTheme = 'default',
    this.is24HourFormat = false,
    this.enableNotifications = true,
    this.enableVibration = true,
    this.theme = AppTheme.system,
    this.language = 'en',
  });

  Map<String, dynamic> toJson() {
    return {
      'calculationMethod': calculationMethod.name,
      'juristicMethod': juristicMethod.name,
      'audioTheme': audioTheme,
      'is24HourFormat': is24HourFormat,
      'enableNotifications': enableNotifications,
      'enableVibration': enableVibration,
      'theme': theme.name,
      'language': language,
    };
  }

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      calculationMethod: PrayerCalculationMethod.values.firstWhere(
        (e) => e.name == json['calculationMethod'],
        orElse: () => PrayerCalculationMethod.muslimWorldLeague,
      ),
      juristicMethod: JuristicMethod.values.firstWhere(
        (e) => e.name == json['juristicMethod'],
        orElse: () => JuristicMethod.shafii,
      ),
      audioTheme: json['audioTheme'] ?? 'default',
      is24HourFormat: json['is24HourFormat'] ?? false,
      enableNotifications: json['enableNotifications'] ?? true,
      enableVibration: json['enableVibration'] ?? true,
      theme: AppTheme.values.firstWhere(
        (e) => e.name == json['theme'],
        orElse: () => AppTheme.system,
      ),
      language: json['language'] ?? 'en',
    );
  }

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

  /// Convert settings to a map for storage
  Map<String, dynamic> toStorageMap() {
    return {
      'calculationMethod': calculationMethod.name,
      'juristicMethod': juristicMethod.name,
      'audioTheme': audioTheme,
      'is24HourFormat': is24HourFormat,
      'enableNotifications': enableNotifications,
      'enableVibration': enableVibration,
      'theme': theme.name,
      'language': language,
    };
  }
  
  /// Create settings from storage map
  static AppSettings fromStorageMap(Map<String, dynamic> map) {
    return AppSettings(
      calculationMethod: PrayerCalculationMethod.values.firstWhere(
        (e) => e.name == map['calculationMethod'],
        orElse: () => PrayerCalculationMethod.muslimWorldLeague,
      ),
      juristicMethod: JuristicMethod.values.firstWhere(
        (e) => e.name == map['juristicMethod'],
        orElse: () => JuristicMethod.shafii,
      ),
      audioTheme: map['audioTheme'] ?? 'default',
      is24HourFormat: map['is24HourFormat'] ?? false,
      enableNotifications: map['enableNotifications'] ?? true,
      enableVibration: map['enableVibration'] ?? true,
      theme: AppTheme.values.firstWhere(
        (e) => e.name == map['theme'],
        orElse: () => AppTheme.system,
      ),
      language: map['language'] ?? 'en',
    );
  }
}

/// Helper extension methods
extension PrayerExtension on Prayer {
  /// Get prayer display name
  String get displayName {
    switch (this) {
      case Prayer.fajr:
        return 'Fajr';
      case Prayer.dhuhr:
        return 'Dhuhr';
      case Prayer.asr:
        return 'Asr';
      case Prayer.maghrib:
        return 'Maghrib';
      case Prayer.isha:
        return 'Isha';
    }
  }
  
  /// Get prayer color for UI
  String get colorName {
    switch (this) {
      case Prayer.fajr:
        return 'fajrColor';
      case Prayer.dhuhr:
        return 'dhuhrColor';
      case Prayer.asr:
        return 'asrColor';
      case Prayer.maghrib:
        return 'maghribColor';
      case Prayer.isha:
        return 'ishaColor';
    }
  }
}