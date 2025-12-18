import dayjs from 'dayjs';
import { Prayer } from '../types';

/**
 * Format time based on 24-hour preference
 */
export const formatTime = (date: Date | string, is24Hour: boolean = false): string => {
    const format = is24Hour ? 'HH:mm' : 'hh:mm A';
    return dayjs(date).format(format);
};

/**
 * Calculate time difference in milliseconds
 */
export const getTimeDifference = (targetTime: Date | string): number => {
    return dayjs(targetTime).diff(dayjs());
};

/**
 * Format countdown time (e.g., "2h 30m")
 */
export const formatCountdown = (milliseconds: number): string => {
    if (milliseconds < 0) {
        return '0m';
    }

    const hours = Math.floor(milliseconds / (1000 * 60 * 60));
    const minutes = Math.floor((milliseconds % (1000 * 60 * 60)) / (1000 * 60));
    const seconds = Math.floor((milliseconds % (1000 * 60)) / 1000);

    if (hours > 0) {
        return `${hours}h ${minutes}m`;
    } else if (minutes > 0) {
        return `${minutes}m ${seconds}s`;
    } else {
        return `${seconds}s`;
    }
};

/**
 * Get Hijri date (simplified - using approximation)
 * For production, use a proper Hijri calendar library
 */
export const getHijriDate = (): { day: number; month: string; year: number } => {
    // Simplified Hijri calculation (approximate)
    const gregorianDate = new Date();
    const gregorianYear = gregorianDate.getFullYear();
    const gregorianMonth = gregorianDate.getMonth() + 1;
    const gregorianDay = gregorianDate.getDate();

    // Approximate Hijri year (Gregorian year - 622) * 1.030684
    const hijriYear = Math.floor((gregorianYear - 622) * 1.030684);

    // Simplified month calculation
    const hijriMonths = [
        'Muharram', 'Safar', 'Rabi al-Awwal', 'Rabi al-Thani',
        'Jumada al-Awwal', 'Jumada al-Thani', 'Rajab', 'Shaban',
        'Ramadan', 'Shawwal', 'Dhul-Qadah', 'Dhul-Hijjah'
    ];

    const monthIndex = (gregorianMonth + Math.floor(hijriYear % 12)) % 12;

    return {
        day: gregorianDay,
        month: hijriMonths[monthIndex],
        year: hijriYear,
    };
};

/**
 * Check if a time has passed today
 */
export const hasTimePassed = (time: Date | string): boolean => {
    return dayjs(time).isBefore(dayjs());
};

/**
 * Get today's date string (YYYY-MM-DD)
 */
export const getTodayDateString = (): string => {
    return dayjs().format('YYYY-MM-DD');
};

/**
 * Get date string for a specific offset (e.g., +1 day, -1 day)
 */
export const getDateString = (offsetDays: number = 0): string => {
    return dayjs().add(offsetDays, 'day').format('YYYY-MM-DD');
};
