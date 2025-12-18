import { Prayer } from '../types';

// Default alarm sounds
export const DEFAULT_ALARM_SOUNDS = [
    { id: 'default', name: 'Default', path: 'default' },
    { id: 'adhan_makkah', name: 'Adhan (Makkah)', path: 'adhan_makkah.mp3' },
    { id: 'adhan_madina', name: 'Adhan (Madina)', path: 'adhan_madina.mp3' },
    { id: 'adhan_mishari', name: 'Adhan (Mishari)', path: 'adhan_mishari.mp3' },
    { id: 'takbir_simple', name: 'Takbir (Simple)', path: 'takbir_simple.mp3' },
];

// Repeat patterns
export const REPEAT_PATTERNS = {
    DAILY: [0, 1, 2, 3, 4, 5, 6],
    WEEKDAYS: [1, 2, 3, 4, 5],
    WEEKENDS: [0, 6],
    NEVER: [],
};

// Day names
export const DAY_NAMES = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
export const DAY_NAMES_FULL = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];

// Offset ranges (in minutes)
export const OFFSET_MIN = -60; // 60 minutes before
export const OFFSET_MAX = 60;  // 60 minutes after
export const OFFSET_STEP = 5;  // 5-minute increments

// Notification channel (Android)
export const NOTIFICATION_CHANNEL = {
    ID: 'alarm_channel',
    NAME: 'Prayer Alarms',
    DESCRIPTION: 'Notifications for prayer time alarms',
    IMPORTANCE: 'high' as const,
};
