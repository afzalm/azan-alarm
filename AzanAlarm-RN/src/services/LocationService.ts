import Geolocation from '@react-native-community/geolocation';
import axios from 'axios';
import { Location } from '../types';
import { storageService } from './StorageService';
import { STORAGE_KEYS, API_ENDPOINTS } from '../constants/storage';
import { LocationError, NetworkError } from '../utils/ErrorHandler';
import { checkLocationPermission, requestLocationPermission, PermissionStatus } from '../utils/PermissionUtils';

export interface LocationService {
    getCurrentLocation(): Promise<Location | null>;
    searchLocations(query: string): Promise<Location[]>;
    saveLocation(location: Location): Promise<void>;
    getSavedLocations(): Promise<Location[]>;
    setCurrentLocation(location: Location): Promise<void>;
}

interface NominatimResult {
    place_id: number;
    lat: string;
    lon: string;
    display_name: string;
    address: {
        country?: string;
        city?: string;
        town?: string;
        village?: string;
    };
}

class LocationServiceImpl implements LocationService {
    /**
     * Get current location using GPS
     */
    async getCurrentLocation(): Promise<Location | null> {
        try {
            // Check permission first
            let permissionStatus = await checkLocationPermission();

            if (permissionStatus !== PermissionStatus.GRANTED) {
                permissionStatus = await requestLocationPermission();

                if (permissionStatus !== PermissionStatus.GRANTED) {
                    throw new LocationError(
                        'Location permission denied',
                        'PERMISSION_DENIED'
                    );
                }
            }

            // Get current position
            return new Promise((resolve, reject) => {
                Geolocation.getCurrentPosition(
                    async (position) => {
                        try {
                            const { latitude, longitude } = position.coords;

                            // Reverse geocode to get location name
                            const response = await axios.get<NominatimResult>(
                                API_ENDPOINTS.NOMINATIM_REVERSE,
                                {
                                    params: {
                                        lat: latitude,
                                        lon: longitude,
                                        format: 'json',
                                    },
                                    headers: {
                                        'User-Agent': 'AzanAlarm/1.0',
                                    },
                                }
                            );

                            const data = response.data;
                            const locationName = data.address.city ||
                                data.address.town ||
                                data.address.village ||
                                'Unknown';

                            const location: Location = {
                                name: locationName,
                                country: data.address.country || 'Unknown',
                                latitude,
                                longitude,
                                timezone: Intl.DateTimeFormat().resolvedOptions().timeZone,
                                isCurrent: true,
                                createdAt: new Date().toISOString(),
                            };

                            // Save as current location
                            await this.setCurrentLocation(location);

                            resolve(location);
                        } catch (error) {
                            reject(new NetworkError(
                                'Failed to reverse geocode location',
                                'GEOCODING_ERROR',
                                error as Error
                            ));
                        }
                    },
                    (error) => {
                        reject(new LocationError(
                            'Failed to get current location',
                            'GPS_ERROR',
                            error as any
                        ));
                    },
                    {
                        enableHighAccuracy: true,
                        timeout: 15000,
                        maximumAge: 10000,
                    }
                );
            });
        } catch (error) {
            console.error('Failed to get current location:', error);
            throw error;
        }
    }

    /**
     * Search for locations using Nominatim
     */
    async searchLocations(query: string): Promise<Location[]> {
        try {
            if (!query || query.trim().length < 2) {
                return [];
            }

            const response = await axios.get<NominatimResult[]>(
                API_ENDPOINTS.NOMINATIM_SEARCH,
                {
                    params: {
                        q: query,
                        format: 'json',
                        limit: 10,
                        addressdetails: 1,
                    },
                    headers: {
                        'User-Agent': 'AzanAlarm/1.0',
                    },
                }
            );

            return response.data.map((result) => ({
                name: result.address.city ||
                    result.address.town ||
                    result.address.village ||
                    result.display_name.split(',')[0],
                country: result.address.country || 'Unknown',
                latitude: parseFloat(result.lat),
                longitude: parseFloat(result.lon),
                timezone: Intl.DateTimeFormat().resolvedOptions().timeZone,
                createdAt: new Date().toISOString(),
            }));
        } catch (error) {
            throw new NetworkError(
                'Failed to search locations',
                'SEARCH_ERROR',
                error as Error
            );
        }
    }

    /**
     * Save a location to favorites
     */
    async saveLocation(location: Location): Promise<void> {
        try {
            const savedLocations = await this.getSavedLocations();

            // Check if location already exists
            const exists = savedLocations.some(
                (loc) => loc.latitude === location.latitude && loc.longitude === location.longitude
            );

            if (!exists) {
                const newLocation = {
                    ...location,
                    id: Date.now(),
                    createdAt: new Date().toISOString(),
                };

                savedLocations.push(newLocation);
                storageService.set(STORAGE_KEYS.SAVED_LOCATIONS, savedLocations);
            }
        } catch (error) {
            console.error('Failed to save location:', error);
            throw error;
        }
    }

    /**
     * Get all saved locations
     */
    async getSavedLocations(): Promise<Location[]> {
        try {
            const locations = storageService.get<Location[]>(STORAGE_KEYS.SAVED_LOCATIONS);
            return locations || [];
        } catch (error) {
            console.error('Failed to get saved locations:', error);
            return [];
        }
    }

    /**
     * Set current active location
     */
    async setCurrentLocation(location: Location): Promise<void> {
        try {
            const currentLocation = {
                ...location,
                isCurrent: true,
            };

            storageService.set(STORAGE_KEYS.CURRENT_LOCATION, currentLocation);
        } catch (error) {
            console.error('Failed to set current location:', error);
            throw error;
        }
    }
}

export const locationService = new LocationServiceImpl();
