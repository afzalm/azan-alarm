import { useState, useEffect } from 'react';
import { useQuery } from '@tanstack/react-query';
import { prayerTimesService } from '../services/PrayerTimesService';
import { storageService } from '../services/StorageService';
import { STORAGE_KEYS } from '../constants/storage';
import { Location, Prayer } from '../types';
import { getTodayDateString } from '../utils/dateUtils';

export const usePrayerTimes = () => {
    const [currentLocation, setCurrentLocationState] = useState<Location | null>(null);

    // Load current location from storage
    useEffect(() => {
        const location = storageService.get<Location>(STORAGE_KEYS.CURRENT_LOCATION);
        if (location) {
            setCurrentLocationState(location);
        }
    }, []);

    /**
     * Get today's prayer times
     */
    const {
        data: prayerTimes,
        isLoading: isLoadingPrayerTimes,
        error: prayerTimesError,
        refetch: refetchPrayerTimes
    } = useQuery({
        queryKey: ['prayerTimes', currentLocation?.latitude, currentLocation?.longitude],
        queryFn: async () => {
            if (!currentLocation) {
                return null;
            }
            const today = getTodayDateString();
            return await prayerTimesService.getPrayerTimes(currentLocation, today);
        },
        enabled: !!currentLocation,
        staleTime: 60 * 60 * 1000, // 1 hour
    });

    /**
     * Get next prayer countdown
     */
    const { data: nextPrayerCountdown = 0 } = useQuery({
        queryKey: ['nextPrayerCountdown', currentLocation?.latitude, currentLocation?.longitude],
        queryFn: async () => {
            if (!currentLocation) {
                return 0;
            }
            return await prayerTimesService.getNextPrayerCountdown(currentLocation);
        },
        enabled: !!currentLocation,
        refetchInterval: 1000, // Update every second
    });

    return {
        prayerTimes,
        isLoadingPrayerTimes,
        prayerTimesError,
        refetchPrayerTimes,
        nextPrayerCountdown,
        currentLocation,
    };
};
