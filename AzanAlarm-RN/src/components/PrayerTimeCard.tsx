import React from 'react';
import { View, Text, StyleSheet, TouchableOpacity } from 'react-native';
import { Prayer } from '../types';
import { getPrayerName, getPrayerColor } from '../utils/prayerUtils';
import { formatTime, hasTimePassed } from '../utils/dateUtils';
import { AppColors } from '../constants/theme';

interface PrayerTimeCardProps {
    prayer: Prayer;
    time: string;
    is24Hour?: boolean;
    onPress?: () => void;
}

export const PrayerTimeCard: React.FC<PrayerTimeCardProps> = ({
    prayer,
    time,
    is24Hour = false,
    onPress,
}) => {
    const prayerName = getPrayerName(prayer);
    const prayerColor = getPrayerColor(prayer);
    const passed = hasTimePassed(time);
    const formattedTime = formatTime(time, is24Hour);

    return (
        <TouchableOpacity
            style={[styles.container, { borderLeftColor: prayerColor }]}
            onPress={onPress}
            activeOpacity={0.7}
        >
            <View style={styles.content}>
                <View style={styles.leftSection}>
                    <View style={[styles.indicator, { backgroundColor: prayerColor }]} />
                    <Text style={[styles.prayerName, passed && styles.passedText]}>
                        {prayerName}
                    </Text>
                </View>
                <Text style={[styles.time, passed && styles.passedText]}>
                    {formattedTime}
                </Text>
            </View>
            {passed && (
                <View style={styles.passedBadge}>
                    <Text style={styles.passedBadgeText}>Passed</Text>
                </View>
            )}
        </TouchableOpacity>
    );
};

const styles = StyleSheet.create({
    container: {
        backgroundColor: AppColors.surface,
        borderRadius: 12,
        padding: 16,
        marginVertical: 6,
        borderLeftWidth: 4,
        shadowColor: '#000',
        shadowOffset: { width: 0, height: 2 },
        shadowOpacity: 0.1,
        shadowRadius: 4,
        elevation: 3,
    },
    content: {
        flexDirection: 'row',
        justifyContent: 'space-between',
        alignItems: 'center',
    },
    leftSection: {
        flexDirection: 'row',
        alignItems: 'center',
    },
    indicator: {
        width: 12,
        height: 12,
        borderRadius: 6,
        marginRight: 12,
    },
    prayerName: {
        fontSize: 18,
        fontWeight: '600',
        color: AppColors.onSurface,
    },
    time: {
        fontSize: 20,
        fontWeight: '700',
        color: AppColors.primary,
    },
    passedText: {
        opacity: 0.5,
    },
    passedBadge: {
        position: 'absolute',
        top: 8,
        right: 8,
        backgroundColor: AppColors.surfaceVariant,
        paddingHorizontal: 8,
        paddingVertical: 4,
        borderRadius: 4,
    },
    passedBadgeText: {
        fontSize: 10,
        color: AppColors.onSurface,
        opacity: 0.6,
    },
});
