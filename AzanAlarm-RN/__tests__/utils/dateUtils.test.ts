import {
    formatTime,
    formatCountdown,
    hasTimePassed,
    getTodayDateString,
} from '../../src/utils/dateUtils';

describe('dateUtils', () => {
    describe('formatTime', () => {
        it('should format time in 12-hour format', () => {
            const date = new Date('2024-01-01T14:30:00');
            const result = formatTime(date, false);
            expect(result).toMatch(/02:30 PM/);
        });

        it('should format time in 24-hour format', () => {
            const date = new Date('2024-01-01T14:30:00');
            const result = formatTime(date, true);
            expect(result).toMatch(/14:30/);
        });
    });

    describe('formatCountdown', () => {
        it('should format hours and minutes', () => {
            const ms = 2 * 60 * 60 * 1000 + 30 * 60 * 1000; // 2h 30m
            expect(formatCountdown(ms)).toBe('2h 30m');
        });

        it('should format minutes and seconds', () => {
            const ms = 5 * 60 * 1000 + 45 * 1000; // 5m 45s
            expect(formatCountdown(ms)).toBe('5m 45s');
        });

        it('should format seconds only', () => {
            const ms = 30 * 1000; // 30s
            expect(formatCountdown(ms)).toBe('30s');
        });

        it('should return 0m for negative values', () => {
            expect(formatCountdown(-1000)).toBe('0m');
        });
    });

    describe('hasTimePassed', () => {
        it('should return true for past time', () => {
            const pastTime = new Date(Date.now() - 1000);
            expect(hasTimePassed(pastTime)).toBe(true);
        });

        it('should return false for future time', () => {
            const futureTime = new Date(Date.now() + 1000);
            expect(hasTimePassed(futureTime)).toBe(false);
        });
    });

    describe('getTodayDateString', () => {
        it('should return date in YYYY-MM-DD format', () => {
            const result = getTodayDateString();
            expect(result).toMatch(/^\d{4}-\d{2}-\d{2}$/);
        });
    });
});
