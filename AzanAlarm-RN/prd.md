# React Native Azan/Alarm App - Detailed Implementation Plan

## 📋 Project Overview

### App Name: AzanAlarm
### Platform: Android & iOS (React Native + TypeScript)
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

## 🧰 Technical Architecture

### Framework & Tools
- **React Native CLI**: 0.75+ with Hermes enabled for low-latency JS execution
- **Language & Tooling**: TypeScript 5.x with ESLint, Prettier, and Metro configs
- **State Management**: TanStack Query for prayer + location caches and Zustand for local UI state
- **Navigation**: React Navigation (native stack + bottom tabs) with safe-area handling
- **Local Storage**: MMKV and AsyncStorage for configuration, cached prayer data, and alarms
- **API Integration**: Axios (REST/GraphQL ready) plus custom hooks for background refresh

### Core Dependencies
```json
{
  "dependencies": {
    "@react-native-async-storage/async-storage": "^1.20.1",
    "@react-native-community/netinfo": "^10.0.0",
    "@react-native-community/geolocation": "^2.0.2",
    "@react-navigation/bottom-tabs": "^6.9.7",
    "@react-navigation/native": "^6.1.6",
    "@react-navigation/native-stack": "^6.10.10",
    "@tanstack/react-query": "^5.5.0",
    "axios": "^1.6.0",
    "dayjs": "^1.11.9",
    "expo-file-system": "^15.5.1",
    "react": "18.2.0",
    "react-native": "0.75.0",
    "react-native-gesture-handler": "^2.12.0",
    "react-native-mmkv": "^2.2.3",
    "react-native-notifications": "^5.2.1",
    "react-native-permissions": "^3.10.4",
    "react-native-reanimated": "^3.4.0",
    "react-native-safe-area-context": "^4.5.0",
    "react-native-screens": "^3.25.0",
    "react-native-vector-icons": "^9.2.0",
    "react-native-background-actions": "^2.0.1",
    "react-native-background-timer": "^2.4.1"
  },
  "devDependencies": {
    "@types/react": "^18.2.21",
    "@types/react-native": "^0.76.4",
    "@typescript-eslint/eslint-plugin": "^6.8.1",
    "@typescript-eslint/parser": "^6.8.1",
    "eslint": "^9.9.0",
    "eslint-config-airbnb-typescript": "^17.0.0",
    "eslint-config-prettier": "^9.0.0",
    "eslint-plugin-import": "^2.30.3",
    "eslint-plugin-jsx-a11y": "^7.9.1",
    "eslint-plugin-react": "^7.33.2",
    "eslint-plugin-react-hooks": "^4.6.0",
    "metro-react-native-babel-preset": "^0.76.0",
    "prettier": "^3.3.1",
    "typescript": "^5.2.2",
    "jest": "^29.7.0",
    "ts-jest": "^29.1.1"
  }
}
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

### Data Models (TypeScript)
```ts
export type Prayer = 'fajr' | 'dhuhr' | 'asr' | 'maghrib' | 'isha';

export interface Location {
  id?: number;
  name: string;
  country: string;
  latitude: number;
  longitude: number;
  timezone: string;
  isCurrent?: boolean;
  createdAt: string;
}

export interface PrayerTime {
  prayer: Prayer;
  time: string; // ISO 8601
  hasPassed: boolean;
  nextOccurrence?: string;
}

export interface Alarm {
  id?: string;
  prayer: Prayer;
  offsetMinutes: number;
  label?: string;
  soundId?: string;
  isActive: boolean;
  repeatDays: number[];
  vibrationEnabled: boolean;
  createdAt: string;
  updatedAt: string;
}

export interface AppSettings {
  calculationMethod: PrayerCalculationMethod;
  juristicMethod: JuristicMethod;
  audioTheme: string;
  is24HourFormat: boolean;
  enableNotifications: boolean;
  enableVibration: boolean;
  theme: AppTheme;
  language: string;
}

export enum PrayerCalculationMethod {
  MuslimWorldLeague = 'muslim_world_league',
  Egyptian = 'egyptian',
  Karachi = 'karachi',
  UmmAlQura = 'umm_al_qura',
  Gulf = 'gulf',
  MoonsightingCommittee = 'moonsighting_committee',
  NorthAmerica = 'north_america',
  Other = 'other',
}

export enum JuristicMethod {
  Shafii = 'shafii',
  Hanafi = 'hanafi',
}

export enum AppTheme {
  Light = 'light',
  Dark = 'dark',
  System = 'system',
}
```

## 🔧 Core Services Architecture

### Service Layer
```ts
import { Alarm, AppSettings, Location, Prayer } from '../models';

export interface LocationService {
  getCurrentLocation(): Promise<Location | null>;
  searchLocations(query: string): Promise<Location[]>;
  saveLocation(location: Location): Promise<void>;
  getSavedLocations(): Promise<Location[]>;
  setCurrentLocation(location: Location): Promise<void>;
}

export interface PrayerTimesService {
  getPrayerTimes(location: Location, date: string): Promise<Record<Prayer, string>>;
  cachePrayerTimes(location: Location, date: string, payload: Record<Prayer, string>): Promise<void>;
  getCachedPrayerTimes(location: Location, date: string): Promise<Record<Prayer, string> | null>;
  getNextPrayerCountdown(location: Location): Promise<number>;
}

export interface AlarmService {
  scheduleAlarm(alarm: Alarm): Promise<void>;
  cancelAlarm(alarmId: string): Promise<void>;
  updateAlarm(alarm: Alarm): Promise<void>;
  getAllAlarms(): Promise<Alarm[]>;
  toggleAlarm(alarmId: string, isActive: boolean): Promise<void>;
}

export interface NotificationService {
  initialize(): Promise<void>;
  showAlarmNotification(alarm: Alarm): Promise<void>;
  showPrayerReminder(prayer: Prayer, time: string): Promise<void>;
  requestPermissions(): Promise<void>;
  arePermissionsGranted(): Promise<boolean>;
}

export interface SettingsService {
  getSettings(): Promise<AppSettings>;
  updateSettings(settings: AppSettings): Promise<void>;
  resetToDefaults(): Promise<void>;
}
```

---

## 🎨 UI/UX Design System

### Color Scheme (Material Design 3)
```ts
export const AppColors = {
  primary: '#1E88E5',
  primaryContainer: '#E3F2FD',
  onPrimary: '#FFFFFF',
  secondary: '#8E24AA',
  secondaryContainer: '#F3E5F5',
  onSecondary: '#FFFFFF',
  fajrColor: '#4A148C',
  dhuhrColor: '#F57C00',
  asrColor: '#2E7D32',
  maghribColor: '#D84315',
  ishaColor: '#1565C0',
  surface: '#FAFAFA',
  surfaceVariant: '#F5F5F5',
  onSurface: '#212121',
  success: '#4CAF50',
  warning: '#FF9800',
  error: '#F44336',
};
```

### Typography
```ts
export const AppTextStyles = {
  h1: { fontSize: 32, fontWeight: '700', letterSpacing: -0.5 },
  h2: { fontSize: 24, fontWeight: '600', letterSpacing: -0.25 },
  bodyLarge: { fontSize: 16, fontWeight: '400', letterSpacing: 0.5 },
  prayerTime: { fontSize: 20, fontWeight: '600', letterSpacing: 1.0 },
};
```

---

## ⚡ Implementation Phases

### Phase 1: Foundation (Week 1-2)
**Priority: Critical**

#### 1.1 Project Setup
- [ ] React Native project initialization with the TypeScript template
- [ ] Package dependencies setup (native and Firebase modules)
- [ ] Folder structure organization (features/services/hooks)
- [ ] Git repository setup
- [ ] CI/CD pipeline configuration (Metro caching, release builds)

#### 1.2 Basic Architecture
- [ ] React Query + Zustand provider setup for async/state separation
- [ ] React Navigation stack/bottom-tab configuration with deep linking
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

#### 2. React Native Firebase Dependencies
```bash
yarn add \
  @react-native-firebase/app @react-native-firebase/auth @react-native-firebase/firestore \
  @react-native-firebase/storage @react-native-firebase/analytics @react-native-firebase/messaging \
  @react-native-firebase/crashlytics @react-native-firebase/perf @react-native-firebase/remote-config
yarn add @react-native-google-signin/google-signin react-native-apple-authentication
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

#### 6. Firebase Service Implementation (React Native)
```ts
import auth from '@react-native-firebase/auth';
import firestore from '@react-native-firebase/firestore';
import analytics from '@react-native-firebase/analytics';
import { Alarm } from '../models'; // shared domain models

export class FirebaseAuthService {
  async registerWithEmail(email: string, password: string) {
    const credential = await auth().createUserWithEmailAndPassword(email, password);
    await firestore()
      .collection('users')
      .doc(credential.user?.uid)
      .set(
        {
          email,
          createdAt: firestore.FieldValue.serverTimestamp(),
          subscription: 'free',
          preferences: {
            calculationMethod: 'muslim_world_league',
            juristicMethod: 'shafii',
            theme: 'system',
            language: 'en',
          },
        },
        { merge: true },
      );
    return credential;
  }

  async syncAlarms(alarms: Alarm[]) {
    const userId = auth().currentUser?.uid;
    if (!userId) throw new Error('User not authenticated');

    const batch = firestore().batch();
    alarms.forEach((alarm) => {
      const docRef = firestore()
        .collection('users')
        .doc(userId)
        .collection('alarms')
        .doc(alarm.id);
      batch.set(docRef, alarm);
    });
    await batch.commit();
  }

  listenAlarms(onUpdate: (alarms: Alarm[]) => void) {
    const userId = auth().currentUser?.uid;
    if (!userId) return () => {};

    return firestore()
      .collection('users')
      .doc(userId)
      .collection('alarms')
      .onSnapshot((snapshot) => {
        onUpdate(
          snapshot.docs.map((doc) => ({ id: doc.id, ...(doc.data() as Alarm) })),
        );
      });
  }

  async logAnalyticsEvent(eventName: string, metadata: Record<string, unknown> = {}) {
    await analytics().logEvent(eventName, metadata);
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
- **Familiarity**: React Native already uses JavaScript/TypeScript, so the backend and app share the same language
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

## 📦 Development Environment Setup

### Required Tools
1. **Node.js**: 18+ (LTS, powers the React Native CLI and Metro bundler)
2. **React Native CLI & Yarn**: bootstrap, linking, and native module installation
3. **Android Studio**: emulator and SDK management
4. **Xcode**: iOS builds + Simulator
5. **Git**: version control
6. **VS Code**: rich TypeScript + React Native tooling

### VS Code Extensions (Recommended)
- React Native Tools
- ESLint
- Prettier
- GitLens
- Material Icon Theme

### Development Commands
```bash
# Project setup
npx react-native init azan_alarm_app --template react-native-template-typescript
cd azan_alarm_app
yarn install
npx pod-install ios

# Runtime
yarn start
npx react-native run-android
npx react-native run-ios

# Testing & verification
yarn test
yarn lint
npx react-native doctor
```


## 📝 Next Steps

### Immediate Actions
1. Install Node.js 18+, Yarn, and React Native CLI
2. Set up Android/iOS toolchains and emulators
3. Create GitHub repository
4. Initialize React Native project with the TypeScript template
5. Set up feature/service folder structure

### First Week Goals
1. Complete Phase 1.1 (Project Setup)
2. Implement React Query + Zustand architecture
3. Set up MMKV/SQLite schema and caching
4. Create basic UI screens
5. Test location services

### Review Points
- Weekly progress reviews
- Code quality checks
- Performance testing
- User feedback incorporation

---

This comprehensive plan provides a solid foundation for building a professional-grade azan alarm app. The phased approach ensures manageable development cycles while maintaining focus on core functionality and user experience.
