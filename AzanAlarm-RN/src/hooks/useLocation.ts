import { useState, useEffect } from 'react';
import { useQuery } from '@tanstack/react-query';
import { locationService } from '../services/LocationService';
import { Location } from '../types';

export const useLocation = () => {
    const [isGettingLocation, setIsGettingLocation] = useState(false);
    const [locationError, setLocationError] = useState<string | null>(null);

    /**
     * Get current GPS location
     */
    const getCurrentLocation = async () => {
        setIsGettingLocation(true);
        setLocationError(null);

        try {
            const location = await locationService.getCurrentLocation();
            return location;
        } catch (error) {
            const errorMessage = error instanceof Error ? error.message : 'Failed to get location';
            setLocationError(errorMessage);
            throw error;
        } finally {
            setIsGettingLocation(false);
        }
    };

    /**
     * Search for locations
     */
    const searchLocations = async (query: string): Promise<Location[]> => {
        if (!query || query.trim().length < 2) {
            return [];
        }

        try {
            return await locationService.searchLocations(query);
        } catch (error) {
            console.error('Failed to search locations:', error);
            return [];
        }
    };

    /**
     * Get saved locations
     */
    const { data: savedLocations = [], refetch: refetchSavedLocations } = useQuery({
        queryKey: ['savedLocations'],
        queryFn: () => locationService.getSavedLocations(),
    });

    /**
     * Save a location
     */
    const saveLocation = async (location: Location) => {
        await locationService.saveLocation(location);
        refetchSavedLocations();
    };

    /**
     * Set current location
     */
    const setCurrentLocation = async (location: Location) => {
        await locationService.setCurrentLocation(location);
    };

    return {
        getCurrentLocation,
        searchLocations,
        savedLocations,
        saveLocation,
        setCurrentLocation,
        isGettingLocation,
        locationError,
    };
};
