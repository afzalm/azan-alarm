import { Prayer } from '../types';
import { AppColors } from '../constants/theme';

/**
 * Get prayer display name
 */
export const getPrayerName = (prayer: Prayer): string => {
    const names: Record<Prayer, string> = {
        fajr: 'Fajr',
        dhuhr: 'Dhuhr',
        asr: 'Asr',
        maghrib: 'Maghrib',
        isha: 'Isha',
    };
    return names[prayer];
};

/**
 * Get prayer color
 */
export const getPrayerColor = (prayer: Prayer): string => {
    const colors: Record<Prayer, string> = {
        fajr: AppColors.fajrColor,
        dhuhr: AppColors.dhuhrColor,
        asr: AppColors.asrColor,
        maghrib: AppColors.maghribColor,
        isha: AppColors.ishaColor,
    };
    return colors[prayer];
};

/**
 * Get prayer icon name (for react-native-vector-icons)
 */
export const getPrayerIcon = (prayer: Prayer): string => {
    const icons: Record<Prayer, string> = {
        fajr: 'weather-sunset-up',
        dhuhr: 'weather-sunny',
        asr: 'weather-sunset-down',
        maghrib: 'weather-night',
        isha: 'moon-waning-crescent',
    };
    return icons[prayer];
};

/**
 * Get all prayers in order
 */
export const getAllPrayers = (): Prayer[] => {
    return ['fajr', 'dhuhr', 'asr', 'maghrib', 'isha'];
};

/**
 * Get next prayer from current time
 */
export const getNextPrayer = (prayerTimes: Record<Prayer, string>): Prayer | null => {
    const now = new Date();
    const prayers = getAllPrayers();

    for (const prayer of prayers) {
        const prayerTime = new Date(prayerTimes[prayer]);
        if (prayerTime > now) {
            return prayer;
        }
    }

    // If all prayers have passed, next is Fajr tomorrow
    return 'fajr';
};
