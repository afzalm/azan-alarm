import React, { useState, useEffect } from 'react';
import { View, Text, StyleSheet } from 'react-native';
import { formatCountdown } from '../utils/dateUtils';
import { AppColors } from '../constants/theme';

interface CountdownTimerProps {
    milliseconds: number;
    prayerName?: string;
}

export const CountdownTimer: React.FC<CountdownTimerProps> = ({
    milliseconds,
    prayerName = 'Next Prayer',
}) => {
    const [countdown, setCountdown] = useState(milliseconds);

    useEffect(() => {
        setCountdown(milliseconds);
    }, [milliseconds]);

    useEffect(() => {
        const interval = setInterval(() => {
            setCountdown((prev) => Math.max(0, prev - 1000));
        }, 1000);

        return () => clearInterval(interval);
    }, []);

    const formattedCountdown = formatCountdown(countdown);
    const progress = countdown > 0 ? (countdown / (24 * 60 * 60 * 1000)) : 0;

    return (
        <View style={styles.container}>
            <View style={styles.circleContainer}>
                <View style={[styles.circle, { borderColor: AppColors.primary }]}>
                    <Text style={styles.countdownText}>{formattedCountdown}</Text>
                    <Text style={styles.labelText}>until {prayerName}</Text>
                </View>
            </View>
        </View>
    );
};

const styles = StyleSheet.create({
    container: {
        alignItems: 'center',
        paddingVertical: 20,
    },
    circleContainer: {
        position: 'relative',
    },
    circle: {
        width: 160,
        height: 160,
        borderRadius: 80,
        borderWidth: 8,
        justifyContent: 'center',
        alignItems: 'center',
        backgroundColor: AppColors.primaryContainer,
    },
    countdownText: {
        fontSize: 32,
        fontWeight: '700',
        color: AppColors.primary,
    },
    labelText: {
        fontSize: 14,
        color: AppColors.onSurface,
        marginTop: 4,
        opacity: 0.7,
    },
});
