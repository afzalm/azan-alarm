/// Database service for managing SQLite database operations

import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../constants/app_constants.dart';
import '../models/models.dart';

/// Database service singleton
class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  Database? _database;
  
  /// Get database instance
  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  /// Initialize database
  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, AppConstants.databaseName);
    
    return await openDatabase(
      path,
      version: AppConstants.databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  /// Create database tables
  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE locations (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        country TEXT NOT NULL,
        latitude REAL NOT NULL,
        longitude REAL NOT NULL,
        timezone TEXT NOT NULL,
        is_current BOOLEAN DEFAULT FALSE,
        created_at INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE alarms (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        prayer_type TEXT NOT NULL,
        offset_minutes INTEGER NOT NULL,
        label TEXT,
        sound_path TEXT,
        is_active BOOLEAN DEFAULT TRUE,
        repeat_days TEXT,
        vibration_enabled BOOLEAN DEFAULT TRUE,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE prayer_times_cache (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        location_id INTEGER NOT NULL,
        date TEXT NOT NULL,
        fajr_time TEXT NOT NULL,
        dhuhr_time TEXT NOT NULL,
        asr_time TEXT NOT NULL,
        maghrib_time TEXT NOT NULL,
        isha_time TEXT NOT NULL,
        calculation_method TEXT NOT NULL,
        created_at INTEGER NOT NULL,
        FOREIGN KEY (location_id) REFERENCES locations (id)
      )
    ''');

    await db.execute('''
      CREATE TABLE settings (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL,
        updated_at INTEGER NOT NULL
      )
    ''');

    // Create indexes for better performance
    await db.execute('CREATE INDEX idx_locations_current ON locations(is_current)');
    await db.execute('CREATE INDEX idx_alarms_active ON alarms(is_active)');
    await db.execute('CREATE INDEX idx_prayer_times_location_date ON prayer_times_cache(location_id, date)');
  }

  /// Handle database upgrades
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle database schema migrations here
    if (oldVersion < newVersion) {
      // Example migration logic
      // await db.execute('ALTER TABLE alarms ADD COLUMN new_column TEXT');
    }
  }

  /// Close database connection
  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }

  /// Clear all data (for testing or reset)
  Future<void> clearAllData() async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.delete('locations');
      await txn.delete('alarms');
      await txn.delete('prayer_times_cache');
      await txn.delete('settings');
    });
  }
}

/// Location database operations
class LocationDatabase {
  static const String _tableName = 'locations';
  
  /// Insert or update location
  static Future<int> insertOrUpdate(Location location) async {
    final db = await DatabaseService().database;
    
    // First, set all locations to not current
    await db.update(
      _tableName,
      {'is_current': 0},
    );
    
    // Insert or update the location
    if (location.id != null) {
      return await db.update(
        _tableName,
        location.toMap(),
        where: 'id = ?',
        whereArgs: [location.id],
      );
    } else {
      final id = await db.insert(_tableName, location.toMap());
      return id.toInt();
    }
  }
  
  /// Get current location
  static Future<Location?> getCurrentLocation() async {
    final db = await DatabaseService().database;
    final maps = await db.query(
      _tableName,
      where: 'is_current = ?',
      whereArgs: [1],
      limit: 1,
    );
    
    if (maps.isNotEmpty) {
      return Location.fromMap(maps.first);
    }
    return null;
  }
  
  /// Get all saved locations
  static Future<List<Location>> getAllLocations() async {
    final db = await DatabaseService().database;
    final maps = await db.query(
      _tableName,
      orderBy: 'created_at DESC',
    );
    
    return maps.map((map) => Location.fromMap(map)).toList();
  }
  
  /// Delete location
  static Future<int> deleteLocation(int id) async {
    final db = await DatabaseService().database;
    return await db.delete(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
  
  /// Search locations by name or country
  static Future<List<Location>> searchLocations(String query) async {
    final db = await DatabaseService().database;
    final maps = await db.query(
      _tableName,
      where: 'name LIKE ? OR country LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
      orderBy: 'created_at DESC',
    );
    
    return maps.map((map) => Location.fromMap(map)).toList();
  }
}

/// Alarm database operations
class AlarmDatabase {
  static const String _tableName = 'alarms';
  
  /// Insert alarm
  static Future<int> insert(Alarm alarm) async {
    final db = await DatabaseService().database;
    final id = await db.insert(_tableName, alarm.toMap());
    return id.toInt();
  }
  
  /// Update alarm
  static Future<int> update(Alarm alarm) async {
    final db = await DatabaseService().database;
    return await db.update(
      _tableName,
      alarm.toMap(),
      where: 'id = ?',
      whereArgs: [alarm.id],
    );
  }
  
  /// Delete alarm
  static Future<int> delete(int id) async {
    final db = await DatabaseService().database;
    return await db.delete(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
  
  /// Get all alarms
  static Future<List<Alarm>> getAllAlarms() async {
    final db = await DatabaseService().database;
    final maps = await db.query(
      _tableName,
      orderBy: 'created_at DESC',
    );
    
    return maps.map((map) => Alarm.fromMap(map)).toList();
  }
  
  /// Get active alarms
  static Future<List<Alarm>> getActiveAlarms() async {
    final db = await DatabaseService().database;
    final maps = await db.query(
      _tableName,
      where: 'is_active = ?',
      whereArgs: [1],
      orderBy: 'created_at DESC',
    );
    
    return maps.map((map) => Alarm.fromMap(map)).toList();
  }
  
  /// Toggle alarm active status
  static Future<int> toggleAlarm(int id, bool isActive) async {
    final db = await DatabaseService().database;
    return await db.update(
      _tableName,
      {'is_active': isActive ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}

/// Settings database operations
class SettingsDatabase {
  static const String _tableName = 'settings';
  
  /// Save setting
  static Future<void> saveSetting(String key, String value) async {
    final db = await DatabaseService().database;
    final now = DateTime.now().millisecondsSinceEpoch;
    
    await db.insert(
      _tableName,
      {
        'key': key,
        'value': value,
        'updated_at': now,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
  
  /// Get setting value
  static Future<String?> getSetting(String key) async {
    final db = await DatabaseService().database;
    final maps = await db.query(
      _tableName,
      where: 'key = ?',
      whereArgs: [key],
      limit: 1,
    );
    
    if (maps.isNotEmpty) {
      return maps.first['value'] as String?;
    }
    return null;
  }
  
  /// Get all settings as map
  static Future<Map<String, String>> getAllSettings() async {
    final db = await DatabaseService().database;
    final maps = await db.query(_tableName);
    
    final settings = <String, String>{};
    for (final map in maps) {
      settings[map['key'] as String] = map['value'] as String;
    }
    
    return settings;
  }
}

/// Extension methods for model serialization
extension LocationDatabaseExtension on Location {
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'country': country,
      'latitude': latitude,
      'longitude': longitude,
      'timezone': timezone,
      'is_current': isCurrent ? 1 : 0,
      'created_at': createdAt.millisecondsSinceEpoch,
    };
  }

  factory Location.fromMap(Map<String, dynamic> map) {
    return Location(
      id: map['id']?.toInt(),
      name: map['name'] ?? '',
      country: map['country'] ?? '',
      latitude: map['latitude']?.toDouble() ?? 0.0,
      longitude: map['longitude']?.toDouble() ?? 0.0,
      timezone: map['timezone'] ?? '',
      isCurrent: map['is_current'] == 1,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at']),
    );
  }
}

extension AlarmDatabaseExtension on Alarm {
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'prayer_type': prayer.name,
      'offset_minutes': offsetMinutes,
      'label': label,
      'sound_path': soundPath,
      'is_active': isActive ? 1 : 0,
      'repeat_days': repeatDays.join(','),
      'vibration_enabled': vibrationEnabled ? 1 : 0,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
    };
  }

  factory Alarm.fromMap(Map<String, dynamic> map) {
    return Alarm(
      id: map['id']?.toInt(),
      prayer: Prayer.values.firstWhere(
        (e) => e.name == map['prayer_type'],
        orElse: () => Prayer.fajr,
      ),
      offsetMinutes: map['offset_minutes'] ?? 0,
      label: map['label'],
      soundPath: map['sound_path'],
      isActive: map['is_active'] == 1,
      repeatDays: (map['repeat_days'] as String?)
              ?.split(',')
              .where((day) => day.isNotEmpty)
              .map((day) => int.parse(day))
              .toList() ??
          [],
      vibrationEnabled: map['vibration_enabled'] == 1,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at']),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updated_at']),
    );
  }
}