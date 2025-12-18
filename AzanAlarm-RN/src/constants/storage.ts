// Storage keys
export const STORAGE_KEYS = {
    SETTINGS: 'app_settings',
    CURRENT_LOCATION: 'current_location',
    SAVED_LOCATIONS: 'saved_locations',
    PRAYER_TIMES_CACHE: 'prayer_times_cache',
    ALARMS: 'alarms',
    USER_PROFILE: 'user_profile',
} as const;

// Cache durations (in milliseconds)
export const CACHE_DURATION = {
    PRAYER_TIMES: 24 * 60 * 60 * 1000, // 24 hours
    LOCATION: 7 * 24 * 60 * 60 * 1000, // 7 days
} as const;

// API endpoints
export const API_ENDPOINTS = {
    NOMINATIM_SEARCH: 'https://nominatim.openstreetmap.org/search',
    NOMINATIM_REVERSE: 'https://nominatim.openstreetmap.org/reverse',
} as const;
