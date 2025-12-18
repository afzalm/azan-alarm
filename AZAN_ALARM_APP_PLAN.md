# Flutter Azan/Alarm App - Detailed Implementation Plan

## 📋 Project Overview

### App Name: AzanAlarm
### Platform: Android & iOS (Flutter)
### Purpose: Islamic prayer times app with customizable alarm system

---

## 🎯 Core Requirements

### Primary Features
1. **Prayer Times Display**: Show accurate 5 daily prayer times based on location
2. **Location Services**: GPS detection + Manual location selection
3. **Smart Alarms**: Set multiple alarms before/after any prayer time
4. **Notifications**: Reliable alarm notifications with custom sounds
5. **Settings**: Comprehensive customization options

### Secondary Features
1. **User Authentication**: Secure login/signup with profile management
2. **Cloud Sync**: Synchronize alarms and settings across devices
3. **Qibla Direction**: Compass pointing to Mecca
4. **Islamic Calendar**: Hijri date display
5. **Prayer Reminders**: Gentle notifications before prayer times
6. **Dark/Light Theme**: System-aware theming
7. **Multi-language**: Support for multiple languages
8. **Analytics & Logging**: User behavior tracking and app performance monitoring

---

## 🏗️ Technical Architecture

### Framework & Tools
- **Flutter SDK**: 3.24.5 (Stable)
- **State Management**: Riverpod (recommended for scalability)
- **Navigation**: Go Router (type-safe routing)
- **Local Storage**: SQLite + SharedPreferences
- **API Integration**: RESTful APIs for location and prayer data

### Core Dependencies
```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # State Management
  flutter_riverpod: ^2.4.9
  riverpod_annotation: ^2.3.3
  
  # Navigation
  go_router: ^12.1.3
  
  # Location Services
  geolocator: ^10.1.0
  geocoding: ^2.1.1
  
  # Notifications & Alarms
  flutter_local_notifications: ^16.3.0
  android_alarm_manager_plus: ^3.0.2
  
  # Prayer Times
  pray_times: ^0.2.0
  
  # Storage
  shared_preferences: ^2.2.2
  sqflite: ^2.3.0
  path_provider: ^2.1.1
  
  # Permissions
  permission_handler: ^11.0.1
  
  # UI & Utils
  material_color_utilities: ^0.8.0
  intl: ^0.18.1
  timezone: ^0.9.2
  
  # Audio
  just_audio: ^0.9.36
  audio_session: ^0.1.16
  
  # Network
  dio: ^5.4.0
  connectivity_plus: ^5.0.2

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0
  riverpod_generator: ^2.3.9
  build_runner: ^2.4.7
  custom_lint: ^0.5.7
```

---

## 📱 Screen Architecture & Navigation

### Screen Hierarchy
```
├── MainApp (Router Setup)
├── AuthWrapper (Future: User Profiles)
│
├── Bottom Navigation Shell
│   ├── 🏠 HomeScreen
│   │   ├── Location Header
│   │   ├── Today's Prayer Times
│   │   ├── Next Prayer Countdown
│   │   └── Quick Actions
│   │
│   ├── ⏰ AlarmsScreen
│   │   ├── Alarm List
│   │   ├── Add/Edit Alarm Sheet
│   │   └── Alarm Settings
│   │
│   ├── 📍 LocationScreen
│   │   ├── Current Location Card
│   │   ├── Search Location
│   │   └── Saved Locations
│   │
│   └── ⚙️ SettingsScreen
│       ├── General Settings
│       ├── Prayer Settings
│       ├── Audio Settings
│       └── About Screen
│
├── Modal/Sheet Screens
│   ├── PrayerTimeDetailSheet
│   ├── LocationPickerSheet
│   └── AlarmCreationSheet
│
└── Fullscreen Screens
    ├── QiblaCompassScreen
    ├── IslamicCalendarScreen
    └── OnboardingScreen
```

---

## 🗄️ Data Architecture

### Database Schema (SQLite)
```sql
-- Locations Table
CREATE TABLE locations (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  country TEXT NOT NULL,
  latitude REAL NOT NULL,
  longitude REAL NOT NULL,
  timezone TEXT NOT NULL,
  is_current BOOLEAN DEFAULT FALSE,
  created_at INTEGER NOT NULL
);

-- Alarms Table
CREATE TABLE alarms (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  prayer_type TEXT NOT NULL, -- 'fajr', 'dhuhr', 'asr', 'maghrib', 'isha'
  offset_minutes INTEGER NOT NULL, -- negative for before, positive for after
  label TEXT,
  sound_path TEXT,
  is_active BOOLEAN DEFAULT TRUE,
  repeat_days TEXT, -- JSON array of days: [1,2,3,4,5]
  vibration_enabled BOOLEAN DEFAULT TRUE,
  created_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL
);

-- Prayer Times Cache Table
CREATE TABLE prayer_times_cache (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  location_id INTEGER NOT NULL,
  date TEXT NOT NULL, -- YYYY-MM-DD format
  fajr_time TEXT NOT NULL,
  dhuhr_time TEXT NOT NULL,
  asr_time TEXT NOT NULL,
  maghrib_time TEXT NOT NULL,
  isha_time TEXT NOT NULL,
  calculation_method TEXT NOT NULL,
  created_at INTEGER NOT NULL,
  FOREIGN KEY (location_id) REFERENCES locations (id)
);

-- Settings Table
CREATE TABLE settings (
  key TEXT PRIMARY KEY,
  value TEXT NOT NULL,
  updated_at INTEGER NOT NULL
);
```

### Data Models (Dart)
```dart
// Location Model
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
}

// Prayer Time Model
class PrayerTime {
  final Prayer prayer;
  final DateTime time;
  final bool hasPassed;
  final DateTime? nextOccurrence;

  const PrayerTime({
    required this.prayer,
    required this.time,
    required this.hasPassed,
    this.nextOccurrence,
  });
}

enum Prayer { fajr, dhuhr, asr, maghrib, isha }

// Alarm Model
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
    required this.isActive,
    required this.repeatDays,
    this.vibrationEnabled = true,
    required this.createdAt,
    required this.updatedAt,
  });
}

// Settings Model
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
}

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

enum JuristicMethod { shafii, hanafi }

enum AppTheme { light, dark, system }
```

---

## 🔧 Core Services Architecture

### Service Layer
```dart
// Location Service
abstract class LocationService {
  Future<Location?> getCurrentLocation();
  Future<List<Location>> searchLocations(String query);
  Future<void> saveLocation(Location location);
  Future<List<Location>> getSavedLocations();
  Future<void> setCurrentLocation(Location location);
}

// Prayer Times Service
abstract class PrayerTimesService {
  Future<Map<Prayer, DateTime>> getPrayerTimes(Location location, DateTime date);
  Future<void> cachePrayerTimes(Location location, DateTime date);
  Future<Map<Prayer, DateTime>?> getCachedPrayerTimes(Location location, DateTime date);
  Duration getNextPrayerCountdown(Location location);
}

// Alarm Service
abstract class AlarmService {
  Future<void> scheduleAlarm(Alarm alarm);
  Future<void> cancelAlarm(int alarmId);
  Future<void> updateAlarm(Alarm alarm);
  Future<List<Alarm>> getAllAlarms();
  Future<void> toggleAlarm(int alarmId, bool isActive);
}

// Notification Service
abstract class NotificationService {
  Future<void> initialize();
  Future<void> showAlarmNotification(Alarm alarm);
  Future<void> showPrayerReminder(Prayer prayer, DateTime time);
  Future<void> requestPermissions();
  Future<bool> arePermissionsGranted();
}

// Settings Service
abstract class SettingsService {
  Future<AppSettings> getSettings();
  Future<void> updateSettings(AppSettings settings);
  Future<void> resetToDefaults();
}
```

---

## 🎨 UI/UX Design System

### Color Scheme (Material Design 3)
```dart
class AppColors {
  // Primary Colors
  static const Color primary = Color(0xFF1E88E5); // Islamic Blue
  static const Color primaryContainer = Color(0xFFE3F2FD);
  static const Color onPrimary = Color(0xFFFFFFFF);
  
  // Secondary Colors
  static const Color secondary = Color(0xFF8E24AA); // Islamic Purple
  static const Color secondaryContainer = Color(0xFFF3E5F5);
  static const Color onSecondary = Color(0xFFFFFFFF);
  
  // Prayer-Specific Colors
  static const Color fajrColor = Color(0xFF4A148C); // Dark Purple
  static const Color dhuhrColor = Color(0xFFF57C00); // Orange
  static const Color asrColor = Color(0xFF2E7D32); // Green
  static const Color maghribColor = Color(0xFFD84315); // Deep Orange
  static const Color ishaColor = Color(0xFF1565C0); // Blue
  
  // Surface Colors
  static const Color surface = Color(0xFFFAFAFA);
  static const Color surfaceVariant = Color(0xFFF5F5F5);
  static const Color onSurface = Color(0xFF212121);
  
  // Status Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFF44336);
}
```

### Typography
```dart
class AppTextStyles {
  static const TextStyle h1 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.5,
  );
  
  static const TextStyle h2 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.25,
  );
  
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    letterSpacing: 0.5,
  );
  
  static const TextStyle prayerTime = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    letterSpacing: 1.0,
  );
}
```

---

## ⚡ Implementation Phases

### Phase 1: Foundation (Week 1-2)
**Priority: Critical**

#### 1.1 Project Setup
- [ ] Flutter project initialization
- [ ] Package dependencies setup
- [ ] Folder structure organization
- [ ] Git repository setup
- [ ] CI/CD pipeline configuration

#### 1.2 Basic Architecture
- [ ] Riverpod provider setup
- [ ] Go Router configuration
- [ ] Database initialization
- [ ] Service layer interfaces
- [ ] Error handling framework

#### 1.3 Core Services
- [ ] Location service implementation
- [ ] SQLite database setup
- [ ] Settings service basic implementation
- [ ] Permission handling

### Phase 2: Core Features (Week 3-4)
**Priority: High**

#### 2.1 Location Features
- [ ] GPS location detection
- [ ] Manual location search
- [ ] Location favorites management
- [ ] Location caching

#### 2.2 Prayer Times
- [ ] Prayer times calculation implementation
- [ ] Multiple calculation methods
- [ ] Timezone handling
- [ ] Prayer times caching
- [ ] Offline functionality

#### 2.3 Basic UI
- [ ] Home screen with prayer times
- [ ] Location selection screen
- [ ] Basic settings screen
- [ ] Navigation system

### Phase 3: Alarm System (Week 5-6)
**Priority: High**

#### 3.1 Alarm Core
- [ ] Alarm creation interface
- [ ] Alarm scheduling service
- [ ] Notification system setup
- [ ] Alarm persistence
- [ ] Background execution handling

#### 3.2 Advanced Alarm Features
- [ ] Multiple alarms per prayer
- [ ] Custom offset times (before/after)
- [ ] Repeat patterns
- [ ] Custom alarm sounds
- [ ] Vibration settings

#### 3.3 Alarm Management
- [ ] Alarm list screen
- [ ] Alarm editing interface
- [ ] Quick enable/disable
- [ ] Bulk operations

### Phase 4: Advanced Features (Week 7-8)
**Priority: Medium**

#### 4.1 Enhanced UI/UX
- [ ] Material Design 3 implementation
- [ ] Dark/light theme support
- [ ] Animations and transitions
- [ ] Responsive design
- [ ] Accessibility features

#### 4.2 Additional Features
- [ ] Qibla compass
- [ ] Islamic calendar
- [ ] Prayer reminders
- [ ] Multiple language support
- [ ] Export/import settings

#### 4.3 Audio Features
- [ ] Custom adhan sounds
- [ ] Audio management
- [ ] Volume controls
- [ ] Fade in/out effects

### Phase 5: Polish & Testing (Week 9-10)
**Priority: Medium**

#### 5.1 Testing
- [ ] Unit tests for business logic
- [ ] Widget tests for UI components
- [ ] Integration tests for user flows
- [ ] Performance testing
- [ ] Memory leak testing

#### 5.2 Platform Integration
- [ ] Android-specific optimizations
- [ ] iOS-specific adaptations
- [ ] Background execution testing
- [ ] Battery optimization handling

#### 5.3 Launch Preparation
- [ ] App store assets preparation
- [ ] Privacy policy implementation
- [ ] User documentation
- [ ] Analytics integration
- [ ] Crash reporting setup

---

## 🔍 Key Technical Challenges & Solutions

### 1. Accurate Prayer Times Calculation
**Challenge**: Different regions use different calculation methods

**Solution**:
```dart
class PrayerTimesCalculator {
  static Map<PrayerCalculationMethod, CalculationParams> get calculationMethods => {
    PrayerCalculationMethod.muslimWorldLeague: CalculationParams(
      fajrAngle: 18.0,
      ishaAngle: 17.0,
      juristicMethod: JuristicMethod.shafii,
    ),
    PrayerCalculationMethod.egyptian: CalculationParams(
      fajrAngle: 19.5,
      ishaAngle: 17.5,
      juristicMethod: JuristicMethod.shafii,
    ),
    // ... other methods
  };
}
```

### 2. Background Alarm Execution
**Challenge**: Alarms must work when app is closed

**Solution**:
- Use `android_alarm_manager_plus` for Android
- Implement background fetch for iOS
- Fallback to local notifications
- Battery whitelist optimization

### 3. Location Privacy & Accuracy
**Challenge**: Balance accuracy with user privacy

**Solution**:
- Request minimal necessary permissions
- Provide manual location option
- Cache location data locally
- Clear location data on user request

### 4. Time Zone Handling
**Challenge**: Accurate times across time zones

**Solution**:
```dart
class TimeZoneHandler {
  static DateTime adjustForTimeZone(DateTime utcTime, String timeZone) {
    return utcTime.toLocal().toUtc(); // Convert to UTC first
  }
  
  static String getFormattedTime(DateTime time, bool is24Hour) {
    return DateFormat(is24Hour ? 'HH:mm' : 'hh:mm a').format(time);
  }
}
```

---

## 📊 Performance Considerations

### 1. Prayer Times Caching
- Cache 30 days of prayer times per location
- Refresh cache weekly or when location changes
- Use background sync for updates

### 2. Memory Management
- Lazy loading of prayer times
- Dispose audio resources properly
- Clear unused location caches
- Optimize image assets

### 3. Battery Optimization
- Minimize GPS usage
- Use efficient scheduling for alarms
- Reduce background processing
- Implement wake locks only when necessary

---

## 🔐 Security & Privacy

### 1. Location Data
- Store only necessary location coordinates
- Never share location data with third parties
- Allow users to delete location history
- Use encrypted storage for sensitive data

### 2. Permissions
- Request permissions only when needed
- Provide clear explanations for each permission
- Allow users to revoke permissions
- Graceful degradation when permissions denied

### 3. Data Storage
- Use SQLite encryption for sensitive data
- Implement secure SharedPreferences alternatives
- Clear data on app uninstall
- No unnecessary data collection

---

## 🚀 Deployment & Maintenance

### 1. App Store Preparation
- Prepare app store screenshots and descriptions
- Create app icons and splash screens
- Write privacy policy and terms of service
- Set up app store accounts

### 2. Version Management
- Semantic versioning (MAJOR.MINOR.PATCH)
- Changelog maintenance
- Backward compatibility considerations
- Database migration strategies

### 3. Monitoring & Analytics
- Crash reporting implementation
- Performance monitoring
- User behavior analytics
- Feature usage tracking

### 4. Updates & Support
- Regular prayer times database updates
- Bug fix schedule
- User feedback collection
- Feature roadmap planning

---

## 📈 Success Metrics

### 1. Technical Metrics
- App startup time < 3 seconds
- Alarm accuracy within 10 seconds
- Battery usage < 2% per day
- Crash rate < 0.1%

### 2. User Engagement
- Daily active users
- Alarm creation frequency
- Location change patterns
- Feature adoption rates

### 3. Quality Metrics
- App store rating > 4.5 stars
- User satisfaction surveys
- Support ticket volume
- Feature request analysis

---

## 🌐 Backend Architecture - Authentication & Logging

### Recommended Tech Stack Options

#### Option 1: Node.js + TypeScript (Recommended for Rapid Development)
```javascript
// Backend Stack
- Runtime: Node.js 18+
- Framework: Express.js + TypeScript
- Database: PostgreSQL + Redis (caching)
- ORM: Prisma
- Authentication: JWT + Refresh Tokens
- Email: SendGrid or AWS SES
- File Storage: AWS S3
- Logging: Winston + ELK Stack
- Monitoring: Sentry + New Relic
```

#### Option 2: Python + FastAPI (Recommended for Data-Intensive Features)
```python
# Backend Stack
- Runtime: Python 3.11+
- Framework: FastAPI
- Database: PostgreSQL + Redis
- ORM: SQLAlchemy
- Authentication: OAuth2 + JWT
- Email: SendGrid
- File Storage: AWS S3
- Logging: Loguru + ELK Stack
- Monitoring: Sentry + Prometheus
```

#### Option 3: Firebase Backend (Recommended for Simplicity & Scalability)
```javascript
// Firebase Stack
- Authentication: Firebase Auth
- Database: Firestore
- Storage: Firebase Storage
- Functions: Cloud Functions (Node.js)
- Hosting: Firebase Hosting
- Analytics: Firebase Analytics
- Performance: Firebase Performance Monitoring
```

### 🎯 MVP Recommendation: Firebase Backend

**Firebase is EXCELLENT for MVP because:**

#### ✅ **Advantages for MVP**
- **Rapid Development**: Set up in minutes, not weeks
- **Zero Infrastructure**: No server management needed
- **Built-in Authentication**: Email/password, Google, Apple sign-in
- **Real-time Database**: Perfect for sync functionality
- **Free Tier**: Generous free limits for MVP testing
- **Scalability**: Auto-scales as user base grows
- **Security**: Built-in security rules and encryption
- **Analytics**: Firebase Analytics included
- **Push Notifications**: FCM integration is seamless

#### 💰 **Cost Comparison (First 10K Users)**
- **Firebase**: ~$0-25/month (Spark/Hobby plan)
- **Node.js Setup**: $50-100/month (server + database + hosting)
- **Time to Market**: Firebase (2 weeks) vs Node.js (4-6 weeks)

#### 🔧 **When to Choose Firebase vs Node.js**
| Scenario | Firebase | Node.js |
|----------|----------|---------|
| **MVP/Startup** | ✅ Best choice | ❌ Overkill |
| **< 100K users** | ✅ Perfect | ✅ Good |
| **Need custom logic** | ⚠️ Limited | ✅ Excellent |
| **Complex queries** | ⚠️ Firestore limitations | ✅ PostgreSQL power |
| **Enterprise integration** | ⚠️ Limited | ✅ Excellent |

### Firebase MVP Implementation Plan

#### 1. Firebase Services to Use
```yaml
Core Services:
  - Firebase Authentication (Email, Google, Apple)
  - Cloud Firestore (Real-time sync)
  - Firebase Storage (Audio files, user images)
  - Cloud Functions (Server-side logic)
  - Firebase Analytics (User behavior)
  - Firebase Crashlytics (Error reporting)
  - Firebase Performance Monitoring
  - Firebase App Distribution (Beta testing)
```

#### 2. Flutter Firebase Dependencies
```yaml
dependencies:
  # Core Firebase
  firebase_core: ^2.24.2
  firebase_auth: ^4.15.3
  cloud_firestore: ^4.13.6
  firebase_storage: ^11.5.6
  firebase_analytics: ^10.7.4
  firebase_crashlytics: ^3.4.8
  firebase_performance: ^0.9.3+8
  
  # Additional
  google_sign_in: ^6.1.6
  sign_in_with_apple: ^6.1.1
```

#### 3. Firebase Data Structure (Firestore)
```dart
// Users Collection
Collection('users') {
  userId: {
    'email': 'user@example.com',
    'fullName': 'John Doe',
    'phone': '+1234567890',
    'emailVerified': true,
    'createdAt': Timestamp,
    'lastLogin': Timestamp,
    'subscription': 'free', // 'free', 'premium'
    'preferences': {
      'calculationMethod': 'muslim_world_league',
      'juristicMethod': 'shafii',
      'theme': 'system',
      'language': 'en',
      'notifications': true,
      'vibration': true
    }
  }
}

// Devices Subcollection
Collection('users/{userId}/devices') {
  deviceId: {
    'deviceName': 'iPhone 14',
    'deviceType': 'ios',
    'platformVersion': '17.0',
    'appVersion': '1.0.0',
    'pushToken': 'fcm_token_here',
    'isActive': true,
    'lastUsed': Timestamp
  }
}

// Alarms Collection
Collection('users/{userId}/alarms') {
  alarmId: {
    'prayer': 'fajr',
    'offsetMinutes': -15,
    'label': 'Morning Reminder',
    'soundPath': 'audio/adhan_mekka.mp3',
    'isActive': true,
    'repeatDays': [1,2,3,4,5],
    'vibrationEnabled': true,
    'deviceId': 'device_uuid',
    'createdAt': Timestamp,
    'updatedAt': Timestamp
  }
}

// Locations Collection
Collection('users/{userId}/locations') {
  locationId: {
    'name': 'Mecca',
    'country': 'Saudi Arabia',
    'latitude': 21.4225,
    'longitude': 39.8262,
    'timezone': 'Asia/Riyadh',
    'isCurrent': true,
    'createdAt': Timestamp
  }
}

// Analytics Collection (write-only)
Collection('analytics') {
  eventId: {
    'userId': 'user_id',
    'deviceId': 'device_id',
    'eventType': 'alarm_created',
    'eventData': {
      'prayer': 'fajr',
      'offset': -15
    },
    'timestamp': Timestamp,
    'appVersion': '1.0.0',
    'platform': 'ios'
  }
}
```

#### 4. Firebase Security Rules
```javascript
// firestore.rules
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can only access their own data
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
      
      // Device management
      match /devices/{deviceId} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
      
      // Alarms sync
      match /alarms/{alarmId} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
      
      // Locations
      match /locations/{locationId} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
    }
    
    // Analytics (write-only for apps)
    match /analytics/{eventId} {
      allow create: if request.auth != null;
      allow read: if false; // No read access
    }
  }
}
```

#### 5. Firebase Cloud Functions Examples
```javascript
// functions/src/index.js
const functions = require('firebase-functions');
const admin = require('firebase-admin');

admin.initializeApp();

// Sync alarms across devices
exports.syncAlarmAcrossDevices = functions.firestore
  .document('users/{userId}/alarms/{alarmId}')
  .onWrite(async (change, context) => {
    const { userId, alarmId } = context.params;
    const newData = change.after.data();
    
    if (!newData) return null;
    
    // Get all user devices
    const devices = await admin.firestore()
      .collection(`users/${userId}/devices`)
      .where('isActive', '==', true)
      .get();
    
    // Send push notification to other devices
    const promises = [];
    devices.forEach(doc => {
      const device = doc.data();
      if (device.pushToken) {
        promises.push(
          admin.messaging().send({
            token: device.pushToken,
            notification: {
              title: 'Alarm Synced',
              body: `${newData.prayer} alarm updated`
            },
            data: {
              type: 'alarm_sync',
              alarmId: alarmId
            }
          })
        );
      }
    });
    
    return Promise.all(promises);
  });

// User analytics aggregation
exports.trackUserActivity = functions.analytics.eventLog().onLog((event) => {
  const user = event.user;
  const eventName = event.eventName;
  
  // Process analytics data
  return admin.firestore().collection('analytics').add({
    userId: user ? user.userId : null,
    eventType: eventName,
    eventData: event.params,
    timestamp: admin.firestore.FieldValue.serverTimestamp()
  });
});
```

#### 6. Firebase Service Implementation (Flutter)
```dart
// services/firebase_auth_service.dart
class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<UserCredential> registerWithEmail(String email, String password) async {
    try {
      final result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Create user profile in Firestore
      await _firestore.collection('users').doc(result.user!.uid).set({
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
        'subscription': 'free',
        'preferences': {
          'calculationMethod': 'muslim_world_league',
          'juristicMethod': 'shafii',
          'theme': 'system',
          'language': 'en',
        }
      });
      
      return result;
    } catch (e) {
      throw AuthException.fromFirebase(e);
    }
  }

  Future<void> syncAlarms(List<Alarm> alarms) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('User not authenticated');
    
    final batch = _firestore.batch();
    
    for (final alarm in alarms) {
      final docRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('alarms')
          .doc(alarm.id);
      
      batch.set(docRef, alarm.toMap());
    }
    
    await batch.commit();
  }

  Stream<List<Alarm>> getAlarmsStream() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return Stream.value([]);
    
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('alarms')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Alarm.fromMap(doc.data(), doc.id))
            .toList());
  }
}
```

### Migration Strategy: Firebase → Node.js

#### Phase 1: MVP with Firebase (Weeks 1-4)
- Quick launch with Firebase backend
- Validate market and user needs
- Gather feedback and analytics

#### Phase 2: Scale-Up (Months 3-6)
- Monitor Firebase costs and limitations
- Plan migration if custom features needed
- Gradually migrate specific services

#### Phase 3: Custom Backend (Months 6+)
- Migrate to Node.js if needed
- Maintain Firebase for specific services
- Hybrid approach possible

### Firebase MVP Cost Analysis

#### Free Tier Limits (Spark Plan)
```yaml
Authentication: 10K monthly active users
Firestore: 1GB storage, 50K reads/day, 20K writes/day
Storage: 1GB
Cloud Functions: 125K invocations/month
Analytics: Free unlimited
Crashlytics: Free unlimited
```

#### Estimated Usage for 10K Users
```yaml
Daily reads: ~30K (prayer times, alarms, settings)
Daily writes: ~15K (new alarms, settings changes)
Storage: ~500MB (user data + audio files)
Functions: ~50K invocations/month

Monthly Cost: $0-25 (well within free tier)
```

### Chosen Recommendation: Node.js + TypeScript Stack (For Production)

**Why this stack for full production?**
- **Familiarity**: JavaScript/TypeScript matches Flutter's Dart syntax
- **Performance**: Node.js handles real-time features well
- **Scalability**: Proven stack for millions of users
- **Ecosystem**: Rich npm ecosystem
- **Cost-Effective**: Open-source technologies
- **Team Skills**: Easier to find developers

**Recommendation: Start with Firebase MVP, then evaluate if custom backend is needed.**

### Backend Project Structure
```
azan-alarm-backend/
├── src/
│   ├── controllers/          # Request handlers
│   │   ├── auth.controller.ts
│   │   ├── user.controller.ts
│   │   ├── alarm.controller.ts
│   │   └── analytics.controller.ts
│   ├── services/            # Business logic
│   │   ├── auth.service.ts
│   │   ├── user.service.ts
│   │   ├── notification.service.ts
│   │   └── sync.service.ts
│   ├── models/              # Database models
│   │   ├── User.ts
│   │   ├── Device.ts
│   │   ├── AlarmSync.ts
│   │   └── UserSession.ts
│   ├── middleware/          # Express middleware
│   │   ├── auth.middleware.ts
│   │   ├── validation.middleware.ts
│   │   └── logging.middleware.ts
│   ├── routes/              # API routes
│   │   ├── auth.routes.ts
│   │   ├── user.routes.ts
│   │   ├── sync.routes.ts
│   │   └── analytics.routes.ts
│   ├── utils/               # Utility functions
│   │   ├── jwt.util.ts
│   │   ├── encryption.util.ts
│   │   └── validation.util.ts
│   ├── config/              # Configuration
│   │   ├── database.ts
│   │   ├── redis.ts
│   │   └── email.ts
│   └── app.ts               # Express app setup
├── prisma/                  # Database schema
│   ├── schema.prisma
│   └── migrations/
├── tests/                   # Test files
├── docker/                  # Docker configuration
├── docs/                    # API documentation
├── package.json
├── tsconfig.json
└── Dockerfile
```

### Database Schema (PostgreSQL)
```sql
-- Users Table
CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  email VARCHAR(255) UNIQUE NOT NULL,
  password_hash VARCHAR(255) NOT NULL,
  full_name VARCHAR(255),
  phone VARCHAR(20),
  email_verified BOOLEAN DEFAULT FALSE,
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  last_login TIMESTAMP WITH TIME ZONE
);

-- User Sessions Table
CREATE TABLE user_sessions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  device_id VARCHAR(255) NOT NULL,
  device_type VARCHAR(50), -- 'android', 'ios'
  device_token TEXT, -- FCM token
  refresh_token VARCHAR(500) NOT NULL,
  expires_at TIMESTAMP WITH TIME ZONE NOT NULL,
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  last_used TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- User Devices Table
CREATE TABLE user_devices (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  device_id VARCHAR(255) NOT NULL,
  device_name VARCHAR(255),
  device_type VARCHAR(50),
  platform_version VARCHAR(50),
  app_version VARCHAR(50),
  push_token TEXT,
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Alarm Sync Table
CREATE TABLE alarm_sync (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  device_id VARCHAR(255) NOT NULL,
  alarm_data JSONB NOT NULL, -- Encrypted alarm data
  sync_action VARCHAR(20) NOT NULL, -- 'create', 'update', 'delete'
  sync_status VARCHAR(20) DEFAULT 'pending', -- 'pending', 'synced', 'failed'
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  synced_at TIMESTAMP WITH TIME ZONE
);

-- User Settings Sync Table
CREATE TABLE user_settings_sync (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  device_id VARCHAR(255) NOT NULL,
  settings_data JSONB NOT NULL, -- Encrypted settings
  sync_status VARCHAR(20) DEFAULT 'pending',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  synced_at TIMESTAMP WITH TIME ZONE
);

-- Analytics Events Table
CREATE TABLE analytics_events (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES users(id) ON DELETE SET NULL,
  device_id VARCHAR(255),
  event_type VARCHAR(100) NOT NULL,
  event_data JSONB,
  session_id VARCHAR(255),
  timestamp TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  app_version VARCHAR(50),
  platform VARCHAR(50)
);

-- App Usage Logs Table
CREATE TABLE app_usage_logs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES users(id) ON DELETE SET NULL,
  device_id VARCHAR(255),
  session_start TIMESTAMP WITH TIME ZONE NOT NULL,
  session_end TIMESTAMP WITH TIME ZONE,
  session_duration INTEGER, -- in seconds
  features_used JSONB, -- Array of features used
  crash_reports JSONB,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

### API Endpoints Design

#### Authentication Endpoints
```typescript
// POST /api/auth/register
interface RegisterRequest {
  email: string;
  password: string;
  fullName?: string;
  phone?: string;
}

// POST /api/auth/login
interface LoginRequest {
  email: string;
  password: string;
  deviceId: string;
  deviceType: 'android' | 'ios';
  pushToken?: string;
}

// POST /api/auth/refresh
interface RefreshRequest {
  refreshToken: string;
}

// POST /api/auth/logout
interface LogoutRequest {
  refreshToken: string;
  deviceId: string;
}

// POST /api/auth/forgot-password
interface ForgotPasswordRequest {
  email: string;
}

// POST /api/auth/reset-password
interface ResetPasswordRequest {
  token: string;
  newPassword: string;
}
```

#### User Management Endpoints
```typescript
// GET /api/user/profile
interface UserProfileResponse {
  id: string;
  email: string;
  fullName: string;
  phone?: string;
  emailVerified: boolean;
  createdAt: string;
  lastLogin: string;
}

// PUT /api/user/profile
interface UpdateProfileRequest {
  fullName?: string;
  phone?: string;
}

// DELETE /api/user/account
interface DeleteAccountRequest {
  password: string;
  confirmation: string;
}

// GET /api/user/devices
interface UserDevicesResponse {
  devices: Array<{
    id: string;
    deviceName: string;
    deviceType: string;
    platformVersion: string;
    appVersion: string;
    isActive: boolean;
    lastUsed: string;
  }>;
}

// DELETE /api/user/devices/:deviceId
interface RemoveDeviceRequest {
  deviceId: string;
}
```

#### Sync Endpoints
```typescript
// POST /api/sync/alarms
interface SyncAlarmsRequest {
  alarms: Array<{
    id: string;
    prayer: string;
    offsetMinutes: number;
    label?: string;
    soundPath?: string;
    isActive: boolean;
    repeatDays: number[];
    vibrationEnabled: boolean;
    updatedAt: string;
  }>;
  deviceId: string;
  lastSyncTime?: string;
}

// GET /api/sync/alarms
interface GetSyncedAlarmsResponse {
  alarms: Alarm[];
  lastSyncTime: string;
  deviceId: string;
}

// POST /api/sync/settings
interface SyncSettingsRequest {
  settings: {
    calculationMethod: string;
    juristicMethod: string;
    audioTheme: string;
    is24HourFormat: boolean;
    enableNotifications: boolean;
    enableVibration: boolean;
    theme: string;
    language: string;
  };
  deviceId: string;
}
```

#### Analytics Endpoints
```typescript
// POST /api/analytics/events
interface AnalyticsEventRequest {
  eventType: string;
  eventData?: Record<string, any>;
  sessionId?: string;
  appVersion?: string;
  platform?: string;
}

// POST /api/analytics/session
interface SessionAnalyticsRequest {
  sessionStart: string;
  sessionEnd?: string;
  featuresUsed?: string[];
  crashReports?: Array<{
    error: string;
    stackTrace: string;
    timestamp: string;
  }>;
}
```

### Backend Implementation Key Features

#### 1. Authentication Service
```typescript
class AuthService {
  async register(userData: RegisterRequest): Promise<AuthResponse>;
  async login(credentials: LoginRequest): Promise<AuthResponse>;
  async refreshToken(refreshToken: string): Promise<TokenResponse>;
  async logout(refreshToken: string, deviceId: string): Promise<void>;
  async forgotPassword(email: string): Promise<void>;
  async resetPassword(token: string, newPassword: string): Promise<void>;
  async verifyEmail(token: string): Promise<void>;
}
```

#### 2. Sync Service
```typescript
class SyncService {
  async syncAlarms(userId: string, alarms: Alarm[], deviceId: string): Promise<void>;
  async getAlarmsForUser(userId: string, deviceId: string): Promise<Alarm[]>;
  async syncSettings(userId: string, settings: UserSettings, deviceId: string): Promise<void>;
  async resolveSyncConflicts(userId: string, deviceId: string): Promise<void>;
}
```

#### 3. Analytics Service
```typescript
class AnalyticsService {
  async trackEvent(userId: string, event: AnalyticsEvent): Promise<void>;
  async trackSession(userId: string, session: SessionData): Promise<void>;
  async getUserAnalytics(userId: string, timeRange: TimeRange): Promise<AnalyticsReport>;
  async getAppMetrics(timeRange: TimeRange): Promise<AppMetrics>;
}
```

### Security Implementation

#### 1. JWT Configuration
```typescript
const jwtConfig = {
  accessTokenExpiry: '15m',
  refreshTokenExpiry: '7d',
  issuer: 'azan-alarm-api',
  audience: 'azan-alarm-app',
  algorithm: 'RS256' // Asymmetric encryption
};
```

#### 2. Password Security
```typescript
import bcrypt from 'bcrypt';
import crypto from 'crypto';

class SecurityUtils {
  static async hashPassword(password: string): Promise<string> {
    return bcrypt.hash(password, 12);
  }
  
  static async comparePassword(password: string, hash: string): Promise<boolean> {
    return bcrypt.compare(password, hash);
  }
  
  static generateSecureToken(): string {
    return crypto.randomBytes(32).toString('hex');
  }
  
  static encryptSensitiveData(data: string, key: string): string {
    // AES-256 encryption for sensitive data
  }
}
```

#### 3. Rate Limiting
```typescript
import rateLimit from 'express-rate-limit';

const authLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 5, // 5 attempts per window
  message: 'Too many authentication attempts',
  standardHeaders: true,
  legacyHeaders: false,
});

const apiLimiter = rateLimit({
  windowMs: 1 * 60 * 1000, // 1 minute
  max: 100, // 100 requests per minute
  standardHeaders: true,
  legacyHeaders: false,
});
```

### Deployment Architecture

#### Docker Configuration
```dockerfile
# Dockerfile
FROM node:18-alpine

WORKDIR /app

COPY package*.json ./
RUN npm ci --only=production

COPY . .
RUN npm run build

EXPOSE 3000

CMD ["npm", "start"]
```

#### Docker Compose
```yaml
# docker-compose.yml
version: '3.8'

services:
  app:
    build: .
    ports:
      - "3000:3000"
    environment:
      - NODE_ENV=production
      - DATABASE_URL=postgresql://user:pass@db:5432/azan_alarm
      - REDIS_URL=redis://redis:6379
    depends_on:
      - db
      - redis

  db:
    image: postgres:15
    environment:
      - POSTGRES_DB=azan_alarm
      - POSTGRES_USER=user
      - POSTGRES_PASSWORD=pass
    volumes:
      - postgres_data:/var/lib/postgresql/data

  redis:
    image: redis:7-alpine
    volumes:
      - redis_data:/data

volumes:
  postgres_data:
  redis_data:
```

### Monitoring & Logging

#### Winston Logging Configuration
```typescript
import winston from 'winston';

const logger = winston.createLogger({
  level: 'info',
  format: winston.format.combine(
    winston.format.timestamp(),
    winston.format.errors({ stack: true }),
    winston.format.json()
  ),
  transports: [
    new winston.transports.File({ filename: 'logs/error.log', level: 'error' }),
    new winston.transports.File({ filename: 'logs/combined.log' }),
    new winston.transports.Console({
      format: winston.format.simple()
    })
  ]
});
```

#### Health Check Endpoint
```typescript
app.get('/health', async (req, res) => {
  try {
    await prisma.$queryRaw`SELECT 1`;
    await redis.ping();
    
    res.json({
      status: 'healthy',
      timestamp: new Date().toISOString(),
      uptime: process.uptime(),
      memory: process.memoryUsage(),
      version: process.env.npm_package_version
    });
  } catch (error) {
    res.status(503).json({
      status: 'unhealthy',
      error: error.message
    });
  }
});
```

---

## 🛠️ Development Environment Setup

### Required Tools
1. **Flutter SDK**: 3.24.5 or later
2. **Android Studio**: Latest stable version
3. **Xcode**: Latest version (for iOS development)
4. **Git**: Version control
5. **VS Code**: Optional, with Flutter extensions

### VS Code Extensions (Recommended)
- Flutter
- Dart
- Flutter Riverpod Snippets
- GitLens
- Material Icon Theme

### Development Commands
```bash
# Project setup
flutter create azan_alarm_app
cd azan_alarm_app

# Dependencies
flutter pub get

# Build commands
flutter build apk --release
flutter build ios --release

# Testing
flutter test
flutter analyze
```

---

## 📝 Next Steps

### Immediate Actions
1. Install Flutter SDK
2. Set up development environment
3. Create GitHub repository
4. Initialize Flutter project
5. Set up basic folder structure

### First Week Goals
1. Complete Phase 1.1 (Project Setup)
2. Implement basic Riverpod architecture
3. Set up database schema
4. Create basic UI screens
5. Test location services

### Review Points
- Weekly progress reviews
- Code quality checks
- Performance testing
- User feedback incorporation

---

This comprehensive plan provides a solid foundation for building a professional-grade azan alarm app. The phased approach ensures manageable development cycles while maintaining focus on core functionality and user experience.
