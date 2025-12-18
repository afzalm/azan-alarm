# Design Document: React Native Foundation Setup

## Overview

The React Native Foundation Setup establishes the core infrastructure for the AzanAlarm application. This design creates a scalable, maintainable architecture with clear separation of concerns between UI, state management, and business logic. The foundation uses industry-standard patterns and libraries to ensure the app can grow from MVP to production-grade application.

## Architecture

### High-Level Architecture Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                     React Native App                         │
├─────────────────────────────────────────────────────────────┤
│                                                               │
│  ┌──────────────────────────────────────────────────────┐   │
│  │              Navigation Layer                         │   │
│  │  (React Navigation - Bottom Tabs + Native Stacks)    │   │
│  └──────────────────────────────────────────────────────┘   │
│                           ↓                                   │
│  ┌──────────────────────────────────────────────────────┐   │
│  │              UI Components Layer                      │   │
│  │  (Screens, Reusable Components, Design System)       │   │
│  └──────────────────────────────────────────────────────┘   │
│                           ↓                                   │
│  ┌──────────────────────────────────────────────────────┐   │
│  │         State Management Layer                        │   │
│  │  ┌─────────────────┐  ┌──────────────────────────┐  │   │
│  │  │  Zustand Stores │  │  React Query (Async)     │  │   │
│  │  │  (UI State)     │  │  (Prayer Times, Alarms)  │  │   │
│  │  └─────────────────┘  └──────────────────────────┘  │   │
│  └──────────────────────────────────────────────────────┘   │
│                           ↓                                   │
│  ┌──────────────────────────────────────────────────────┐   │
│  │         Service Layer                                │   │
│  │  ┌──────────┐ ┌──────────┐ ┌──────────┐            │   │
│  │  │Location  │ │PrayerTime│ │Alarms    │ ...        │   │
│  │  │Service   │ │Service   │ │Service   │            │   │
│  │  └──────────┘ └──────────┘ └──────────┘            │   │
│  └──────────────────────────────────────────────────────┘   │
│                           ↓                                   │
│  ┌──────────────────────────────────────────────────────┐   │
│  │         Data Persistence Layer                       │   │
│  │  ┌──────────┐  ┌──────────┐  ┌──────────┐          │   │
│  │  │  MMKV    │  │ SQLite   │  │ Axios    │          │   │
│  │  │(Key-Val) │  │(Structured)│ (HTTP)   │          │   │
│  │  └──────────┘  └──────────┘  └──────────┘          │   │
│  └──────────────────────────────────────────────────────┘   │
│                                                               │
└─────────────────────────────────────────────────────────────┘
```

### Data Flow

```
User Interaction (UI)
        ↓
   Navigation/State Update
        ↓
   Zustand Store / React Query
        ↓
   Service Layer (Business Logic)
        ↓
   Data Persistence (MMKV/SQLite/API)
        ↓
   Response back to UI
        ↓
   Component Re-render
```

## Components and Interfaces

### 1. Navigation Architecture

#### Navigation Structure
```
RootNavigator
├── BottomTabNavigator
│   ├── HomeStack
│   │   ├── HomeScreen
│   │   └── PrayerDetailScreen
│   ├── AlarmsStack
│   │   ├── AlarmsScreen
│   │   └── AlarmDetailScreen
│   ├── LocationStack
│   │   ├── LocationScreen
│   │   └── LocationSearchScreen
│   └── SettingsStack
│       ├── SettingsScreen
│       ├── GeneralSettingsScreen
│       └── AboutScreen
└── ModalStack (Overlays)
    ├── LocationPickerModal
    └── AlarmCreationModal
```

#### Navigation Configuration
```typescript
// src/navigation/types.ts
export type RootStackParamList = {
  MainApp: undefined;
  OnboardingScreen: undefined;
};

export type BottomTabParamList = {
  HomeStack: undefined;
  AlarmsStack: undefined;
  LocationStack: undefined;
  SettingsStack: undefined;
};

export type HomeStackParamList = {
  HomeScreen: undefined;
  PrayerDetailScreen: { prayer: Prayer };
};

// Similar for other stacks...
```

### 2. State Management Architecture

#### Zustand Stores (UI State)
```typescript
// src/stores/themeStore.ts
interface ThemeState {
  theme: 'light' | 'dark' | 'system';
  setTheme: (theme: 'light' | 'dark' | 'system') => void;
}

export const useThemeStore = create<ThemeState>((set) => ({
  theme: 'system',
  setTheme: (theme) => set({ theme }),
}));

// src/stores/uiStore.ts
interface UIState {
  language: string;
  is24HourFormat: boolean;
  setLanguage: (lang: string) => void;
  setTimeFormat: (is24Hour: boolean) => void;
}

export const useUIStore = create<UIState>((set) => ({
  language: 'en',
  is24HourFormat: false,
  setLanguage: (lang) => set({ language: lang }),
  setTimeFormat: (is24Hour) => set({ is24HourFormat: is24Hour }),
}));
```

#### React Query Setup
```typescript
// src/api/queryClient.ts
import { QueryClient } from '@tanstack/react-query';

export const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      staleTime: 1000 * 60 * 5, // 5 minutes
      gcTime: 1000 * 60 * 10, // 10 minutes
      retry: 1,
    },
  },
});

// src/hooks/usePrayerTimes.ts
export const usePrayerTimes = (location: Location, date: string) => {
  return useQuery({
    queryKey: ['prayerTimes', location.id, date],
    queryFn: () => prayerTimesService.getPrayerTimes(location, date),
    staleTime: 1000 * 60 * 60, // 1 hour
  });
};
```

### 3. Service Layer

#### Service Interfaces
```typescript
// src/services/types.ts
export interface ServiceResponse<T> {
  data?: T;
  error?: ServiceError;
  isLoading: boolean;
}

export interface ServiceError {
  code: string;
  message: string;
  details?: Record<string, unknown>;
}

// src/services/LocationService.ts
export interface ILocationService {
  getCurrentLocation(): Promise<Location>;
  searchLocations(query: string): Promise<Location[]>;
  saveLocation(location: Location): Promise<void>;
  getSavedLocations(): Promise<Location[]>;
  setCurrentLocation(location: Location): Promise<void>;
}

export class LocationService implements ILocationService {
  private storage: IStorageService;
  private httpClient: AxiosInstance;

  constructor(storage: IStorageService, httpClient: AxiosInstance) {
    this.storage = storage;
    this.httpClient = httpClient;
  }

  async getCurrentLocation(): Promise<Location> {
    try {
      // Implementation
    } catch (error) {
      throw this.handleError(error);
    }
  }

  private handleError(error: unknown): ServiceError {
    // Consistent error handling
  }
}
```

#### Service Container
```typescript
// src/services/container.ts
export class ServiceContainer {
  private static instance: ServiceContainer;
  
  private locationService: ILocationService;
  private prayerTimesService: IPrayerTimesService;
  private alarmService: IAlarmService;
  private settingsService: ISettingsService;

  private constructor() {
    const storage = new StorageService();
    const httpClient = createAxiosInstance();
    
    this.locationService = new LocationService(storage, httpClient);
    this.prayerTimesService = new PrayerTimesService(storage, httpClient);
    this.alarmService = new AlarmService(storage);
    this.settingsService = new SettingsService(storage);
  }

  static getInstance(): ServiceContainer {
    if (!ServiceContainer.instance) {
      ServiceContainer.instance = new ServiceContainer();
    }
    return ServiceContainer.instance;
  }

  getLocationService(): ILocationService {
    return this.locationService;
  }

  // Similar getters for other services...
}
```

### 4. Storage Architecture

#### MMKV Setup
```typescript
// src/storage/mmkvStorage.ts
import { MMKV } from 'react-native-mmkv';

export const mmkvStorage = new MMKV({
  id: 'azan-alarm-storage',
});

export class MMKVStorageService implements IStorageService {
  set(key: string, value: unknown): void {
    mmkvStorage.set(key, JSON.stringify(value));
  }

  get<T>(key: string): T | null {
    const value = mmkvStorage.getString(key);
    return value ? JSON.parse(value) : null;
  }

  remove(key: string): void {
    mmkvStorage.delete(key);
  }

  clear(): void {
    mmkvStorage.clearAll();
  }
}
```

#### SQLite Setup
```typescript
// src/storage/database.ts
import SQLite from 'react-native-sqlite-storage';

export class DatabaseService {
  private db: SQLite.SQLiteDatabase | null = null;

  async initialize(): Promise<void> {
    this.db = await SQLite.openDatabase({
      name: 'azan_alarm.db',
      location: 'default',
    });
    await this.createTables();
  }

  private async createTables(): Promise<void> {
    if (!this.db) return;
    
    await this.db.executeSql(`
      CREATE TABLE IF NOT EXISTS prayer_times_cache (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        location_id INTEGER NOT NULL,
        date TEXT NOT NULL,
        fajr_time TEXT NOT NULL,
        dhuhr_time TEXT NOT NULL,
        asr_time TEXT NOT NULL,
        maghrib_time TEXT NOT NULL,
        isha_time TEXT NOT NULL,
        created_at INTEGER NOT NULL
      );
    `);
  }

  async query(sql: string, params: unknown[] = []): Promise<unknown[]> {
    if (!this.db) throw new Error('Database not initialized');
    const result = await this.db.executeSql(sql, params);
    return result[0].rows.raw();
  }
}
```

### 5. HTTP Client Configuration

```typescript
// src/api/httpClient.ts
import axios, { AxiosInstance } from 'axios';

export function createAxiosInstance(): AxiosInstance {
  const instance = axios.create({
    baseURL: process.env.API_BASE_URL || 'https://api.example.com',
    timeout: 10000,
  });

  // Request interceptor
  instance.interceptors.request.use(
    (config) => {
      // Add auth token, logging, etc.
      return config;
    },
    (error) => Promise.reject(error),
  );

  // Response interceptor
  instance.interceptors.response.use(
    (response) => response,
    (error) => {
      // Handle errors consistently
      return Promise.reject(error);
    },
  );

  return instance;
}
```

## Data Models

### Core TypeScript Interfaces
```typescript
// src/models/types.ts
export type Prayer = 'fajr' | 'dhuhr' | 'asr' | 'maghrib' | 'isha';

export interface Location {
  id?: string;
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
  calculationMethod: string;
  juristicMethod: string;
  audioTheme: string;
  is24HourFormat: boolean;
  enableNotifications: boolean;
  enableVibration: boolean;
  theme: 'light' | 'dark' | 'system';
  language: string;
}
```

## Correctness Properties

A property is a characteristic or behavior that should hold true across all valid executions of a system—essentially, a formal statement about what the system should do. Properties serve as the bridge between human-readable specifications and machine-verifiable correctness guarantees.

### Property 1: All Required Dependencies Installed
*For any* React Native project initialized with the foundation setup, all core packages (React Query, Zustand, React Navigation, MMKV, SQLite) should be present in package.json with compatible versions.
**Validates: Requirements 1.4**

### Property 2: Navigation Tabs Always Accessible
*For any* app state and navigation history, the bottom tab navigation should always be visible and all four tabs (Home, Alarms, Location, Settings) should be accessible.
**Validates: Requirements 2.1**

### Property 3: Tab Navigation Preserves State
*For any* tab navigation action, switching between tabs and returning to a tab should preserve the previous state of that tab's screen stack.
**Validates: Requirements 2.2**

### Property 4: Stack Navigation Maintains History
*For any* sequence of screen pushes within a tab, the navigation stack should maintain the correct order and allow popping back to previous screens.
**Validates: Requirements 2.3**

### Property 5: Deep Links Navigate Correctly
*For any* valid deep link URL, the app should navigate to the corresponding screen and pass the correct parameters.
**Validates: Requirements 2.4**

### Property 6: Safe Area Respected on iOS
*For any* screen on iOS, content should be positioned within the safe area boundaries (respecting notches and home indicators).
**Validates: Requirements 2.5**

### Property 7: Zustand Stores Initialize Successfully
*For any* app initialization, all Zustand stores (theme, UI, settings) should be created and accessible via their respective hooks.
**Validates: Requirements 3.1**

### Property 8: React Query Configured for Async Data
*For any* async data requirement (prayer times, locations, alarms), React Query should be configured with appropriate cache times and retry logic.
**Validates: Requirements 3.2**

### Property 9: State Persists to MMKV
*For any* state update marked for persistence, the state should be written to MMKV and retrievable after app restart.
**Validates: Requirements 3.3, 3.4**

### Property 10: Custom Hooks Provide State Access
*For any* component needing access to shared state, custom hooks should be available to access state without prop drilling.
**Validates: Requirements 3.5**

### Property 11: All Services Instantiate Successfully
*For any* app initialization, all required services (Location, PrayerTimes, Alarms, Notifications, Settings) should be created and accessible.
**Validates: Requirements 4.1**

### Property 12: Service Errors Return Typed Responses
*For any* service method call that fails, the error should be caught and returned as a typed ServiceError with code, message, and optional details.
**Validates: Requirements 4.2**

### Property 13: Axios Configured with Interceptors
*For any* HTTP request made through the app, it should pass through Axios interceptors for request/response handling.
**Validates: Requirements 4.3**

### Property 14: Persistence Interface Consistent
*For any* service needing to persist data, it should use the same interface (MMKV or SQLite) regardless of implementation.
**Validates: Requirements 4.4**

### Property 15: Services Support Dependency Injection
*For any* service, its dependencies should be injected via constructor, allowing for easy mocking in tests.
**Validates: Requirements 4.5**

### Property 16: Dark Mode Colors Applied Consistently
*For any* screen when dark mode is enabled, all text, backgrounds, and components should use dark theme colors.
**Validates: Requirements 5.5**

### Property 17: Settings Persist Immediately
*For any* settings change, the new value should be written to MMKV immediately and be available on next app launch.
**Validates: Requirements 6.2, 6.3**

### Property 18: SQLite Initialized for Caching
*For any* app initialization, SQLite should be initialized and prayer times cache table should be created.
**Validates: Requirements 6.4**

### Property 19: Service Errors Caught and Logged
*For any* error occurring in a service, it should be caught, logged with context, and returned as a typed error response.
**Validates: Requirements 7.1, 7.2**

### Property 20: Network Errors Display User-Friendly Messages
*For any* network request failure, a user-friendly error message should be displayed instead of technical error details.
**Validates: Requirements 7.3**

### Property 21: Unhandled Errors Prevented from Crashing
*For any* unhandled error in the app, an error boundary should catch it and display an error screen instead of crashing.
**Validates: Requirements 7.4**

### Property 22: Environment Variables Loaded Correctly
*For any* environment (dev, staging, prod), the corresponding .env file should be loaded and environment variables should be accessible.
**Validates: Requirements 8.3**

## Error Handling

### Error Handling Strategy

1. **Service Layer Errors**: All service methods wrap operations in try-catch blocks and return typed ServiceError objects
2. **Network Errors**: Axios interceptors catch network errors and transform them into user-friendly messages
3. **Component Errors**: Error boundaries catch React component errors and display fallback UI
4. **Async Errors**: React Query handles async errors with retry logic and error states
5. **Storage Errors**: Storage operations are wrapped with error handling and fallback strategies

### Error Boundary Implementation
```typescript
// src/components/ErrorBoundary.tsx
export class ErrorBoundary extends React.Component<Props, State> {
  componentDidCatch(error: Error, errorInfo: React.ErrorInfo) {
    logger.error('Error caught by boundary', { error, errorInfo });
  }

  render() {
    if (this.state.hasError) {
      return <ErrorScreen error={this.state.error} />;
    }
    return this.props.children;
  }
}
```

## Testing Strategy

### Unit Testing Approach
- Test service layer business logic with Jest
- Test utility functions and helpers
- Test store actions and selectors
- Mock external dependencies (API calls, storage)
- Target: 80%+ coverage for services and utilities

### Property-Based Testing Approach
- Use `fast-check` library for property-based tests
- Test universal properties that should hold across all inputs
- Generate random valid inputs and verify properties hold
- Run minimum 100 iterations per property test
- Tag each test with the property number and requirement reference

### Integration Testing
- Test navigation flows between screens
- Test state synchronization between stores and components
- Test service integration with storage layer
- Test error handling across layers

### Test Configuration
```typescript
// jest.config.js
module.exports = {
  preset: 'react-native',
  testEnvironment: 'node',
  setupFilesAfterEnv: ['<rootDir>/jest.setup.js'],
  moduleNameMapper: {
    '^@/(.*)$': '<rootDir>/src/$1',
  },
  collectCoverageFrom: [
    'src/**/*.{ts,tsx}',
    '!src/**/*.d.ts',
    '!src/index.ts',
  ],
};
```

### Property-Based Testing Library
- **Library**: `fast-check` (JavaScript/TypeScript property-based testing)
- **Configuration**: Minimum 100 runs per property
- **Format**: Each property test tagged with `**Feature: rn-foundation-setup, Property X: [property description]**`

### Example Property Test
```typescript
// src/services/__tests__/LocationService.property.test.ts
import fc from 'fast-check';

describe('LocationService - Property Tests', () => {
  it('**Feature: rn-foundation-setup, Property 11: All Services Instantiate Successfully**', () => {
    fc.assert(
      fc.property(fc.anything(), (input) => {
        const container = ServiceContainer.getInstance();
        expect(container.getLocationService()).toBeDefined();
        expect(container.getPrayerTimesService()).toBeDefined();
        expect(container.getAlarmService()).toBeDefined();
        expect(container.getSettingsService()).toBeDefined();
      }),
      { numRuns: 100 }
    );
  });
});
```

