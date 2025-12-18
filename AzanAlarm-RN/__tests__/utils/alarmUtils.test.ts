import {
    formatOffsetText,
    formatRepeatDaysText,
    validateAlarm,
    calculateNextAlarmTime,
} from '../../src/utils/alarmUtils';
import { REPEAT_PATTERNS } from '../../src/constants/alarms';
import { Prayer } from '../../src/types';

describe('alarmUtils', () => {
    describe('formatOffsetText', () => {
        it('should format zero offset', () => {
            expect(formatOffsetText(0)).toBe('at prayer time');
        });

        it('should format positive offset in minutes', () => {
            expect(formatOffsetText(15)).toBe('15 min after');
            expect(formatOffsetText(30)).toBe('30 min after');
        });

        it('should format negative offset in minutes', () => {
            expect(formatOffsetText(-15)).toBe('15 min before');
            expect(formatOffsetText(-30)).toBe('30 min before');
        });

        it('should format offset in hours', () => {
            expect(formatOffsetText(60)).toBe('1h after');
            expect(formatOffsetText(-60)).toBe('1h before');
        });

        it('should format offset in hours and minutes', () => {
            expect(formatOffsetText(75)).toBe('1h 15m after');
            expect(formatOffsetText(-90)).toBe('1h 30m before');
        });
    });

    describe('formatRepeatDaysText', () => {
        it('should format no repeat days', () => {
            expect(formatRepeatDaysText([])).toBe('Never');
        });

        it('should format daily', () => {
            expect(formatRepeatDaysText(REPEAT_PATTERNS.DAILY)).toBe('Daily');
        });

        it('should format weekdays', () => {
            expect(formatRepeatDaysText(REPEAT_PATTERNS.WEEKDAYS)).toBe('Weekdays');
        });

        it('should format weekends', () => {
            expect(formatRepeatDaysText(REPEAT_PATTERNS.WEEKENDS)).toBe('Weekends');
        });

        it('should format custom days', () => {
            expect(formatRepeatDaysText([1, 3, 5])).toBe('Mon, Wed, Fri');
        });
    });

    describe('validateAlarm', () => {
        it('should return null for valid alarm', () => {
            const alarm = {
                prayer: 'fajr' as Prayer,
                offsetMinutes: 0,
                repeatDays: [1, 2, 3],
            };
            expect(validateAlarm(alarm)).toBeNull();
        });

        it('should return error for missing prayer', () => {
            const alarm = {
                offsetMinutes: 0,
                repeatDays: [1, 2, 3],
            };
            expect(validateAlarm(alarm)).toBe('Please select a prayer');
        });

        it('should return error for missing offset', () => {
            const alarm = {
                prayer: 'fajr' as Prayer,
                repeatDays: [1, 2, 3],
            };
            expect(validateAlarm(alarm)).toBe('Please set an offset time');
        });

        it('should return error for missing repeat days', () => {
            const alarm = {
                prayer: 'fajr' as Prayer,
                offsetMinutes: 0,
                repeatDays: [],
            };
            expect(validateAlarm(alarm)).toBe('Please select at least one day');
        });
    });

    describe('calculateNextAlarmTime', () => {
        it('should calculate next alarm time with positive offset', () => {
            const prayerTime = new Date().toISOString();
            const result = calculateNextAlarmTime(prayerTime, 15, [0, 1, 2, 3, 4, 5, 6]);
            expect(result).toBeInstanceOf(Date);
        });

        it('should calculate next alarm time with negative offset', () => {
            const prayerTime = new Date().toISOString();
            const result = calculateNextAlarmTime(prayerTime, -15, [0, 1, 2, 3, 4, 5, 6]);
            expect(result).toBeInstanceOf(Date);
        });
    });
});
