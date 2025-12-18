import React from 'react';
import { View, Text, StyleSheet, ScrollView, RefreshControl, TouchableOpacity, ActivityIndicator } from 'react-native';
import { AppColors } from '../../constants/theme';
import { usePrayerTimes } from '../../hooks/usePrayerTimes';
import { PrayerTimeCard } from '../../components/PrayerTimeCard';
import { CountdownTimer } from '../../components/CountdownTimer';
import { HijriDate } from '../../components/HijriDate';
import { getAllPrayers, getNextPrayer, getPrayerName } from '../../utils/prayerUtils';

export const HomeScreen = () => {
    const {
        prayerTimes,
        isLoadingPrayerTimes,
        refetchPrayerTimes,
        nextPrayerCountdown,
        currentLocation,
    } = usePrayerTimes();

    const [refreshing, setRefreshing] = React.useState(false);

    const onRefresh = async () => {
        setRefreshing(true);
        await refetchPrayerTimes();
        setRefreshing(false);
    };

    const nextPrayer = prayerTimes ? getNextPrayer(prayerTimes) : null;
    const nextPrayerName = nextPrayer ? getPrayerName(nextPrayer) : 'Next Prayer';

    if (!currentLocation) {
        return (
            <View style={styles.centerContainer}>
                <Text style={styles.emptyTitle}>No Location Set</Text>
                <Text style={styles.emptyText}>
                    Please go to the Location tab to set your location
                </Text>
            </View>
        );
    }

    if (isLoadingPrayerTimes && !prayerTimes) {
        return (
            <View style={styles.centerContainer}>
                <ActivityIndicator size="large" color={AppColors.primary} />
                <Text style={styles.loadingText}>Loading prayer times...</Text>
            </View>
        );
    }

    return (
        <ScrollView
            style={styles.container}
            contentContainerStyle={styles.contentContainer}
            refreshControl={
                <RefreshControl refreshing={refreshing} onRefresh={onRefresh} />
            }
        >
            {/* Location Header */}
            <View style={styles.locationHeader}>
                <View>
                    <Text style={styles.locationName}>{currentLocation.name}</Text>
                    <Text style={styles.locationCountry}>{currentLocation.country}</Text>
                </View>
                <TouchableOpacity style={styles.changeButton}>
                    <Text style={styles.changeButtonText}>Change</Text>
                </TouchableOpacity>
            </View>

            {/* Hijri Date */}
            <View style={styles.hijriContainer}>
                <HijriDate />
            </View>

            {/* Countdown Timer */}
            {nextPrayerCountdown > 0 && (
                <CountdownTimer
                    milliseconds={nextPrayerCountdown}
                    prayerName={nextPrayerName}
                />
            )}

            {/* Prayer Times List */}
            <View style={styles.prayerTimesSection}>
                <Text style={styles.sectionTitle}>Today's Prayer Times</Text>
                {prayerTimes ? (
                    getAllPrayers().map((prayer) => (
                        <PrayerTimeCard
                            key={prayer}
                            prayer={prayer}
                            time={prayerTimes[prayer]}
                        />
                    ))
                ) : (
                    <Text style={styles.errorText}>Failed to load prayer times</Text>
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
    centerContainer: {
        flex: 1,
        justifyContent: 'center',
        alignItems: 'center',
        backgroundColor: AppColors.surface,
        padding: 20,
    },
    locationHeader: {
        flexDirection: 'row',
        justifyContent: 'space-between',
        alignItems: 'center',
        marginBottom: 16,
        padding: 16,
        backgroundColor: AppColors.primaryContainer,
        borderRadius: 12,
    },
    locationName: {
        fontSize: 20,
        fontWeight: '700',
        color: AppColors.onSurface,
    },
    locationCountry: {
        fontSize: 14,
        color: AppColors.onSurface,
        opacity: 0.7,
        marginTop: 4,
    },
    changeButton: {
        paddingHorizontal: 16,
        paddingVertical: 8,
        backgroundColor: AppColors.primary,
        borderRadius: 8,
    },
    changeButtonText: {
        color: AppColors.onPrimary,
        fontWeight: '600',
    },
    hijriContainer: {
        marginBottom: 16,
    },
    prayerTimesSection: {
        marginTop: 24,
    },
    sectionTitle: {
        fontSize: 18,
        fontWeight: '700',
        color: AppColors.onSurface,
        marginBottom: 12,
    },
    emptyTitle: {
        fontSize: 24,
        fontWeight: '700',
        color: AppColors.onSurface,
        marginBottom: 8,
    },
    emptyText: {
        fontSize: 16,
        color: AppColors.onSurface,
        opacity: 0.7,
        textAlign: 'center',
    },
    loadingText: {
        fontSize: 16,
        color: AppColors.onSurface,
        marginTop: 16,
    },
    errorText: {
        fontSize: 16,
        color: AppColors.error,
        textAlign: 'center',
        marginTop: 20,
    },
});
