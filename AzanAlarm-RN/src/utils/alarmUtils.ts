import dayjs from 'dayjs';
import { Alarm, Prayer } from '../types';
import { DAY_NAMES, REPEAT_PATTERNS } from '../constants/alarms';

/**
 * Calculate next alarm time based on prayer time and offset
 */
export const calculateNextAlarmTime = (
    prayerTime: string,
    offsetMinutes: number,
    repeatDays: number[]
): Date => {
    const prayerDate = new Date(prayerTime);
    const alarmTime = new Date(prayerDate.getTime() + offsetMinutes * 60 * 1000);

    // If alarm time has passed today and repeat days are set
    if (alarmTime < new Date() && repeatDays.length > 0) {
        // Find next occurrence
        const today = new Date().getDay();
        let daysToAdd = 1;

        for (let i = 1; i <= 7; i++) {
            const nextDay = (today + i) % 7;
            if (repeatDays.includes(nextDay)) {
                daysToAdd = i;
                break;
            }
        }

        alarmTime.setDate(alarmTime.getDate() + daysToAdd);
    }

    return alarmTime;
};

/**
 * Format alarm display text
 */
export const formatAlarmText = (alarm: Alarm, prayerTime?: string): string => {
    const offsetText = formatOffsetText(alarm.offsetMinutes);
    const repeatText = formatRepeatDaysText(alarm.repeatDays);

    let text = `${alarm.prayer} ${offsetText}`;
    if (alarm.label) {
        text += ` - ${alarm.label}`;
    }
    if (repeatText) {
        text += ` (${repeatText})`;
    }

    return text;
};

/**
 * Format offset text (e.g., "15 min before", "30 min after")
 */
export const formatOffsetText = (offsetMinutes: number): string => {
    if (offsetMinutes === 0) {
        return 'at prayer time';
    }

    const absOffset = Math.abs(offsetMinutes);
    const direction = offsetMinutes < 0 ? 'before' : 'after';

    if (absOffset < 60) {
        return `${absOffset} min ${direction}`;
    } else {
        const hours = Math.floor(absOffset / 60);
        const minutes = absOffset % 60;
        if (minutes === 0) {
            return `${hours}h ${direction}`;
        }
        return `${hours}h ${minutes}m ${direction}`;
    }
};

/**
 * Format repeat days text (e.g., "Daily", "Weekdays", "Mon, Wed, Fri")
 */
export const formatRepeatDaysText = (repeatDays: number[]): string => {
    if (repeatDays.length === 0) {
        return 'Never';
    }

    if (repeatDays.length === 7) {
        return 'Daily';
    }

    // Check for weekdays
    const weekdays = REPEAT_PATTERNS.WEEKDAYS;
    if (repeatDays.length === weekdays.length &&
        repeatDays.every(day => weekdays.includes(day))) {
        return 'Weekdays';
    }

    // Check for weekends
    const weekends = REPEAT_PATTERNS.WEEKENDS;
    if (repeatDays.length === weekends.length &&
        repeatDays.every(day => weekends.includes(day))) {
        return 'Weekends';
    }

    // Custom days
    return repeatDays
        .sort()
        .map(day => DAY_NAMES[day])
        .join(', ');
};

/**
 * Validate alarm data
 */
export const validateAlarm = (alarm: Partial<Alarm>): string | null => {
    if (!alarm.prayer) {
        return 'Please select a prayer';
    }

    if (alarm.offsetMinutes === undefined) {
        return 'Please set an offset time';
    }

    if (!alarm.repeatDays || alarm.repeatDays.length === 0) {
        return 'Please select at least one day';
    }

    return null;
};

/**
 * Check if alarm should trigger today
 */
export const shouldAlarmTriggerToday = (alarm: Alarm): boolean => {
    const today = new Date().getDay();
    return alarm.repeatDays.includes(today);
};

/**
 * Get next alarm occurrence time
 */
export const getNextAlarmOccurrence = (
    alarm: Alarm,
    prayerTime: string
): Date | null => {
    if (!alarm.isActive) {
        return null;
    }

    return calculateNextAlarmTime(prayerTime, alarm.offsetMinutes, alarm.repeatDays);
};
