import React, { useState } from 'react';
import { View, Text, StyleSheet, ScrollView, TextInput, TouchableOpacity, ActivityIndicator, FlatList } from 'react-native';
import { AppColors } from '../../constants/theme';
import { useLocation } from '../../hooks/useLocation';
import { LocationCard } from '../../components/LocationCard';
import { Location } from '../../types';

export const LocationScreen = () => {
    const {
        getCurrentLocation,
        searchLocations,
        savedLocations,
        saveLocation,
        setCurrentLocation,
        isGettingLocation,
        locationError,
    } = useLocation();

    const [searchQuery, setSearchQuery] = useState('');
    const [searchResults, setSearchResults] = useState<Location[]>([]);
    const [isSearching, setIsSearching] = useState(false);

    const handleGetCurrentLocation = async () => {
        try {
            const location = await getCurrentLocation();
            if (location) {
                await setCurrentLocation(location);
                await saveLocation(location);
            }
        } catch (error) {
            console.error('Failed to get current location:', error);
        }
    };

    const handleSearch = async (query: string) => {
        setSearchQuery(query);

        if (query.trim().length < 2) {
            setSearchResults([]);
            return;
        }

        setIsSearching(true);
        try {
            const results = await searchLocations(query);
            setSearchResults(results);
        } catch (error) {
            console.error('Search failed:', error);
        } finally {
            setIsSearching(false);
        }
    };

    const handleSelectLocation = async (location: Location) => {
        await setCurrentLocation(location);
        await saveLocation(location);
        setSearchQuery('');
        setSearchResults([]);
    };

    return (
        <ScrollView style={styles.container} contentContainerStyle={styles.contentContainer}>
            {/* GPS Location Button */}
            <TouchableOpacity
                style={styles.gpsButton}
                onPress={handleGetCurrentLocation}
                disabled={isGettingLocation}
            >
                {isGettingLocation ? (
                    <ActivityIndicator color={AppColors.onPrimary} />
                ) : (
                    <Text style={styles.gpsButtonText}>📍 Use Current Location</Text>
                )}
            </TouchableOpacity>

            {locationError && (
                <View style={styles.errorContainer}>
                    <Text style={styles.errorText}>{locationError}</Text>
                </View>
            )}

            {/* Search Bar */}
            <View style={styles.searchSection}>
                <Text style={styles.sectionTitle}>Search Location</Text>
                <TextInput
                    style={styles.searchInput}
                    placeholder="Enter city name..."
                    value={searchQuery}
                    onChangeText={handleSearch}
                    autoCapitalize="words"
                />

                {isSearching && (
                    <ActivityIndicator style={styles.searchLoader} color={AppColors.primary} />
                )}

                {/* Search Results */}
                {searchResults.length > 0 && (
                    <View style={styles.searchResults}>
                        {searchResults.map((location, index) => (
                            <LocationCard
                                key={index}
                                location={location}
                                onSelect={() => handleSelectLocation(location)}
                                showActions={false}
                            />
                        ))}
                    </View>
                )}
            </View>

            {/* Saved Locations */}
            <View style={styles.savedSection}>
                <Text style={styles.sectionTitle}>Saved Locations</Text>
                {savedLocations.length === 0 ? (
                    <Text style={styles.emptyText}>No saved locations yet</Text>
                ) : (
                    savedLocations.map((location, index) => (
                        <LocationCard
                            key={index}
                            location={location}
                            onSelect={() => setCurrentLocation(location)}
                        />
                    ))
                )}
            </View>
        </ScrollView>
    );
};

const styles = StyleSheet.create({
    container: {
        flex: 1,
        backgroundColor: AppColors.surface,
    },
    contentContainer: {
        padding: 16,
    },
    gpsButton: {
        backgroundColor: AppColors.primary,
        padding: 16,
        borderRadius: 12,
        alignItems: 'center',
        marginBottom: 24,
    },
    gpsButtonText: {
        color: AppColors.onPrimary,
        fontSize: 16,
        fontWeight: '600',
    },
    errorContainer: {
        backgroundColor: AppColors.error + '20',
        padding: 12,
        borderRadius: 8,
        marginBottom: 16,
    },
    errorText: {
        color: AppColors.error,
        fontSize: 14,
    },
    searchSection: {
        marginBottom: 24,
    },
    sectionTitle: {
        fontSize: 18,
        fontWeight: '700',
        color: AppColors.onSurface,
        marginBottom: 12,
    },
    searchInput: {
        backgroundColor: AppColors.surfaceVariant,
        padding: 16,
        borderRadius: 12,
        fontSize: 16,
        color: AppColors.onSurface,
    },
    searchLoader: {
        marginTop: 12,
    },
    searchResults: {
        marginTop: 12,
    },
    savedSection: {
        marginBottom: 24,
    },
    emptyText: {
        fontSize: 14,
        color: AppColors.onSurface,
        opacity: 0.5,
        textAlign: 'center',
        marginTop: 20,
    },
});
