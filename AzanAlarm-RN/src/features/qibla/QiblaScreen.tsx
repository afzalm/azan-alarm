import React, { useState, useEffect } from 'react';
import { View, Text, StyleSheet, ActivityIndicator } from 'react-native';
import { useTheme } from '../../hooks/useTheme';
import { useLocation } from '../../hooks/useLocation';
import { calculateQiblaDirection, calculateDistanceToMecca } from '../../services/QiblaService';

export const QiblaScreen = () => {
    const { colors } = useTheme();
    const { getCurrentLocation, isGettingLocation } = useLocation();
    const [qiblaDirection, setQiblaDirection] = useState<number | null>(null);
    const [distance, setDistance] = useState<number | null>(null);
    const [locationName, setLocationName] = useState<string>('');

    useEffect(() => {
        loadQiblaDirection();
    }, []);

    const loadQiblaDirection = async () => {
        try {
            const location = await getCurrentLocation();
            if (location) {
                const direction = calculateQiblaDirection(location.latitude, location.longitude);
                const dist = calculateDistanceToMecca(location.latitude, location.longitude);

                setQiblaDirection(direction);
                setDistance(dist);
                setLocationName(location.name);
            }
        } catch (error) {
            console.error('Failed to get Qibla direction:', error);
        }
    };

    const styles = createStyles(colors);

    if (isGettingLocation || qiblaDirection === null) {
        return (
            <View style={styles.centerContainer}>
                <ActivityIndicator size="large" color={colors.primary} />
                <Text style={styles.loadingText}>Getting your location...</Text>
            </View>
        );
    }

    return (
        <View style={styles.container}>
            <View style={styles.header}>
                <Text style={styles.title}>Qibla Direction</Text>
                <Text style={styles.locationText}>{locationName}</Text>
            </View>

            {/* Compass Circle */}
            <View style={styles.compassContainer}>
                <View style={styles.compass}>
                    {/* Direction indicator */}
                    <View
                        style={[
                            styles.directionIndicator,
                            { transform: [{ rotate: `${qiblaDirection}deg` }] },
                        ]}
                    >
                        <View style={styles.arrow} />
                    </View>

                    {/* Center dot */}
                    <View style={styles.centerDot} />

                    {/* Direction text */}
                    <Text style={styles.directionText}>
                        {Math.round(qiblaDirection)}°
                    </Text>
                </View>

                {/* Cardinal directions */}
                <Text style={[styles.cardinalText, styles.northText]}>N</Text>
                <Text style={[styles.cardinalText, styles.eastText]}>E</Text>
                <Text style={[styles.cardinalText, styles.southText]}>S</Text>
                <Text style={[styles.cardinalText, styles.westText]}>W</Text>
            </View>

            {/* Distance Info */}
            <View style={styles.infoContainer}>
                <Text style={styles.infoLabel}>Distance to Mecca</Text>
                <Text style={styles.infoValue}>
                    {distance ? `${Math.round(distance).toLocaleString()} km` : '-'}
                </Text>
            </View>

            <Text style={styles.note}>
                Note: For accurate results, ensure your device is on a flat surface and away from magnetic interference.
            </Text>
        </View>
    );
};

const createStyles = (colors: any) => StyleSheet.create({
    container: {
        flex: 1,
        backgroundColor: colors.background,
        padding: 20,
    },
    centerContainer: {
        flex: 1,
        justifyContent: 'center',
        alignItems: 'center',
        backgroundColor: colors.background,
    },
    header: {
        alignItems: 'center',
        marginBottom: 40,
    },
    title: {
        fontSize: 28,
        fontWeight: '700',
        color: colors.onSurface,
        marginBottom: 8,
    },
    locationText: {
        fontSize: 16,
        color: colors.onSurface,
        opacity: 0.7,
    },
    compassContainer: {
        alignItems: 'center',
        justifyContent: 'center',
        marginVertical: 40,
        position: 'relative',
    },
    compass: {
        width: 280,
        height: 280,
        borderRadius: 140,
        backgroundColor: colors.surface,
        borderWidth: 4,
        borderColor: colors.primary,
        justifyContent: 'center',
        alignItems: 'center',
        position: 'relative',
    },
    directionIndicator: {
        position: 'absolute',
        width: 4,
        height: 120,
        backgroundColor: colors.primary,
        top: 20,
    },
    arrow: {
        width: 0,
        height: 0,
        borderLeftWidth: 10,
        borderRightWidth: 10,
        borderBottomWidth: 20,
        borderLeftColor: 'transparent',
        borderRightColor: 'transparent',
        borderBottomColor: colors.primary,
        position: 'absolute',
        top: -20,
        left: -8,
    },
    centerDot: {
        width: 16,
        height: 16,
        borderRadius: 8,
        backgroundColor: colors.primary,
    },
    directionText: {
        position: 'absolute',
        bottom: 40,
        fontSize: 32,
        fontWeight: '700',
        color: colors.primary,
    },
    cardinalText: {
        position: 'absolute',
        fontSize: 20,
        fontWeight: '600',
        color: colors.onSurface,
    },
    northText: {
        top: -30,
    },
    eastText: {
        right: -30,
    },
    southText: {
        bottom: -30,
    },
    westText: {
        left: -30,
    },
    infoContainer: {
        alignItems: 'center',
        marginTop: 40,
        padding: 20,
        backgroundColor: colors.surface,
        borderRadius: 12,
    },
    infoLabel: {
        fontSize: 14,
        color: colors.onSurface,
        opacity: 0.7,
        marginBottom: 8,
    },
    infoValue: {
        fontSize: 24,
        fontWeight: '700',
        color: colors.primary,
    },
    note: {
        fontSize: 12,
        color: colors.onSurface,
        opacity: 0.6,
        textAlign: 'center',
        marginTop: 20,
        paddingHorizontal: 20,
    },
    loadingText: {
        fontSize: 16,
        color: colors.onSurface,
        marginTop: 16,
    },
});
