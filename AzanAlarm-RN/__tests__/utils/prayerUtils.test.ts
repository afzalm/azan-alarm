import {
    getPrayerName,
    getPrayerColor,
    getAllPrayers,
    getNextPrayer,
} from '../../src/utils/prayerUtils';
import { Prayer } from '../../src/types';

describe('prayerUtils', () => {
    describe('getPrayerName', () => {
        it('should return correct prayer names', () => {
            expect(getPrayerName('fajr')).toBe('Fajr');
            expect(getPrayerName('dhuhr')).toBe('Dhuhr');
            expect(getPrayerName('asr')).toBe('Asr');
            expect(getPrayerName('maghrib')).toBe('Maghrib');
            expect(getPrayerName('isha')).toBe('Isha');
        });
    });

    describe('getPrayerColor', () => {
        it('should return color for each prayer', () => {
            const prayers: Prayer[] = ['fajr', 'dhuhr', 'asr', 'maghrib', 'isha'];
            prayers.forEach(prayer => {
                const color = getPrayerColor(prayer);
                expect(color).toBeTruthy();
                expect(typeof color).toBe('string');
            });
        });
    });

    describe('getAllPrayers', () => {
        it('should return all prayers in order', () => {
            const prayers = getAllPrayers();
            expect(prayers).toEqual(['fajr', 'dhuhr', 'asr', 'maghrib', 'isha']);
        });
    });

    describe('getNextPrayer', () => {
        it('should return next prayer', () => {
            const now = new Date();
            const prayerTimes = {
                fajr: new Date(now.getTime() - 1000).toISOString(),
                dhuhr: new Date(now.getTime() + 1000).toISOString(),
                asr: new Date(now.getTime() + 2000).toISOString(),
                maghrib: new Date(now.getTime() + 3000).toISOString(),
                isha: new Date(now.getTime() + 4000).toISOString(),
            };

            expect(getNextPrayer(prayerTimes)).toBe('dhuhr');
        });

        it('should return fajr when all prayers passed', () => {
            const now = new Date();
            const prayerTimes = {
                fajr: new Date(now.getTime() - 5000).toISOString(),
                dhuhr: new Date(now.getTime() - 4000).toISOString(),
                asr: new Date(now.getTime() - 3000).toISOString(),
                maghrib: new Date(now.getTime() - 2000).toISOString(),
                isha: new Date(now.getTime() - 1000).toISOString(),
            };

            expect(getNextPrayer(prayerTimes)).toBe('fajr');
        });
    });
});
