import { Coordinates, CalculationMethod, PrayerTimes as AdhanPrayerTimes, Prayer as AdhanPrayer, Madhab } from 'adhan';
import { Location, Prayer, PrayerCalculationMethod, JuristicMethod } from '../types';
import { storageService } from './StorageService';
import { STORAGE_KEYS, CACHE_DURATION } from '../constants/storage';
import { getTodayDateString } from '../utils/dateUtils';

export interface PrayerTimesService {
    getPrayerTimes(location: Location, date: string): Promise<Record<Prayer, string>>;
    cachePrayerTimes(location: Location, date: string, payload: Record<Prayer, string>): Promise<void>;
    getCachedPrayerTimes(location: Location, date: string): Promise<Record<Prayer, string> | null>;
    getNextPrayerCountdown(location: Location): Promise<number>;
}

interface CachedPrayerTimes {
    locationId: string;
    date: string;
    times: Record<Prayer, string>;
    calculationMethod: PrayerCalculationMethod;
    cachedAt: number;
}

class PrayerTimesServiceImpl implements PrayerTimesService {
    /**
     * Map our calculation method to adhan's CalculationMethod
     */
    private getAdhanCalculationMethod(method: PrayerCalculationMethod): CalculationMethod {
        const methodMap: Record<PrayerCalculationMethod, CalculationMethod> = {
            [PrayerCalculationMethod.MuslimWorldLeague]: CalculationMethod.MuslimWorldLeague(),
            [PrayerCalculationMethod.Egyptian]: CalculationMethod.Egyptian(),
            [PrayerCalculationMethod.Karachi]: CalculationMethod.Karachi(),
            [PrayerCalculationMethod.UmmAlQura]: CalculationMethod.UmmAlQura(),
            [PrayerCalculationMethod.Gulf]: CalculationMethod.Kuwait(),
            [PrayerCalculationMethod.MoonsightingCommittee]: CalculationMethod.MoonsightingCommittee(),
            [PrayerCalculationMethod.NorthAmerica]: CalculationMethod.NorthAmerica(),
            [PrayerCalculationMethod.Other]: CalculationMethod.MuslimWorldLeague(),
        };
        return methodMap[method];
    }

    /**
     * Map our juristic method to adhan's Madhab
     */
    private getAdhanMadhab(method: JuristicMethod): Madhab {
        return method === JuristicMethod.Hanafi ? Madhab.Hanafi : Madhab.Shafi;
    }

    /**
     * Calculate prayer times for a specific location and date
     */
    async getPrayerTimes(
        location: Location,
        date: string,
        calculationMethod: PrayerCalculationMethod = PrayerCalculationMethod.MuslimWorldLeague,
        juristicMethod: JuristicMethod = JuristicMethod.Shafii
    ): Promise<Record<Prayer, string>> {
        try {
            // Check cache first
            const cached = await this.getCachedPrayerTimes(location, date);
            if (cached) {
                return cached;
            }

            // Create coordinates
            const coordinates = new Coordinates(location.latitude, location.longitude);

            // Get calculation parameters
            const params = this.getAdhanCalculationMethod(calculationMethod);
            params.madhab = this.getAdhanMadhab(juristicMethod);

            // Parse date
            const dateObj = new Date(date);

            // Calculate prayer times
            const prayerTimes = new AdhanPrayerTimes(coordinates, dateObj, params);

            // Map to our format
            const times: Record<Prayer, string> = {
                fajr: prayerTimes.fajr.toISOString(),
                dhuhr: prayerTimes.dhuhr.toISOString(),
                asr: prayerTimes.asr.toISOString(),
                maghrib: prayerTimes.maghrib.toISOString(),
                isha: prayerTimes.isha.toISOString(),
            };

            // Cache the results
            await this.cachePrayerTimes(location, date, times);

            return times;
        } catch (error) {
            console.error('Failed to calculate prayer times:', error);
            throw error;
        }
    }

    /**
     * Cache prayer times
     */
    async cachePrayerTimes(
        location: Location,
        date: string,
        payload: Record<Prayer, string>
    ): Promise<void> {
        try {
            const cacheKey = `${STORAGE_KEYS.PRAYER_TIMES_CACHE}_${location.latitude}_${location.longitude}_${date}`;

            const cacheData: CachedPrayerTimes = {
                locationId: `${location.latitude}_${location.longitude}`,
                date,
                times: payload,
                calculationMethod: PrayerCalculationMethod.MuslimWorldLeague, // TODO: Get from settings
                cachedAt: Date.now(),
            };

            storageService.set(cacheKey, cacheData);
        } catch (error) {
            console.error('Failed to cache prayer times:', error);
        }
    }

    /**
     * Get cached prayer times
     */
    async getCachedPrayerTimes(
        location: Location,
        date: string
    ): Promise<Record<Prayer, string> | null> {
        try {
            const cacheKey = `${STORAGE_KEYS.PRAYER_TIMES_CACHE}_${location.latitude}_${location.longitude}_${date}`;

            const cached = storageService.get<CachedPrayerTimes>(cacheKey);

            if (!cached) {
                return null;
            }

            // Check if cache is expired (30 days)
            const cacheAge = Date.now() - cached.cachedAt;
            if (cacheAge > CACHE_DURATION.PRAYER_TIMES) {
                return null;
            }

            return cached.times;
        } catch (error) {
            console.error('Failed to get cached prayer times:', error);
            return null;
        }
    }

    /**
     * Get countdown to next prayer in milliseconds
     */
    async getNextPrayerCountdown(location: Location): Promise<number> {
        try {
            const today = getTodayDateString();
            const times = await this.getPrayerTimes(location, today);

            const now = new Date();
            const prayers: Prayer[] = ['fajr', 'dhuhr', 'asr', 'maghrib', 'isha'];

            // Find next prayer
            for (const prayer of prayers) {
                const prayerTime = new Date(times[prayer]);
                if (prayerTime > now) {
                    return prayerTime.getTime() - now.getTime();
                }
            }

            // All prayers passed, get tomorrow's Fajr
            const tomorrow = new Date();
            tomorrow.setDate(tomorrow.getDate() + 1);
            const tomorrowStr = tomorrow.toISOString().split('T')[0];
            const tomorrowTimes = await this.getPrayerTimes(location, tomorrowStr);
            const fajrTime = new Date(tomorrowTimes.fajr);

            return fajrTime.getTime() - now.getTime();
        } catch (error) {
            console.error('Failed to get next prayer countdown:', error);
            return 0;
        }
    }
}

export const prayerTimesService = new PrayerTimesServiceImpl();
