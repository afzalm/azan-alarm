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
