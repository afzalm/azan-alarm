import React from 'react';
import { View, Text, StyleSheet, TouchableOpacity } from 'react-native';
import { DAY_NAMES, REPEAT_PATTERNS } from '../constants/alarms';
import { AppColors } from '../constants/theme';

interface RepeatDaysSelectorProps {
    selectedDays: number[];
    onDaysChange: (days: number[]) => void;
}

export const RepeatDaysSelector: React.FC<RepeatDaysSelectorProps> = ({
    selectedDays,
    onDaysChange,
}) => {
    const toggleDay = (day: number) => {
        if (selectedDays.includes(day)) {
            onDaysChange(selectedDays.filter(d => d !== day));
        } else {
            onDaysChange([...selectedDays, day].sort());
        }
    };

    const setPreset = (days: number[]) => {
        onDaysChange(days);
    };

    return (
        <View style={styles.container}>
            <Text style={styles.label}>Repeat</Text>

            {/* Presets */}
            <View style={styles.presetsContainer}>
                <TouchableOpacity
                    style={[
                        styles.presetButton,
                        selectedDays.length === 7 && styles.presetButtonActive,
                    ]}
                    onPress={() => setPreset(REPEAT_PATTERNS.DAILY)}
                >
                    <Text
                        style={[
                            styles.presetText,
                            selectedDays.length === 7 && styles.presetTextActive,
                        ]}
                    >
                        Daily
                    </Text>
                </TouchableOpacity>

                <TouchableOpacity
                    style={[
                        styles.presetButton,
                        selectedDays.length === 5 &&
                        selectedDays.every(d => REPEAT_PATTERNS.WEEKDAYS.includes(d)) &&
                        styles.presetButtonActive,
                    ]}
                    onPress={() => setPreset(REPEAT_PATTERNS.WEEKDAYS)}
                >
                    <Text
                        style={[
                            styles.presetText,
                            selectedDays.length === 5 &&
                            selectedDays.every(d => REPEAT_PATTERNS.WEEKDAYS.includes(d)) &&
                            styles.presetTextActive,
                        ]}
                    >
                        Weekdays
                    </Text>
                </TouchableOpacity>

                <TouchableOpacity
                    style={[
                        styles.presetButton,
                        selectedDays.length === 2 &&
                        selectedDays.every(d => REPEAT_PATTERNS.WEEKENDS.includes(d)) &&
                        styles.presetButtonActive,
                    ]}
                    onPress={() => setPreset(REPEAT_PATTERNS.WEEKENDS)}
                >
                    <Text
                        style={[
                            styles.presetText,
                            selectedDays.length === 2 &&
                            selectedDays.every(d => REPEAT_PATTERNS.WEEKENDS.includes(d)) &&
                            styles.presetTextActive,
                        ]}
                    >
                        Weekends
                    </Text>
                </TouchableOpacity>
            </View>

            {/* Day buttons */}
            <View style={styles.daysContainer}>
                {DAY_NAMES.map((day, index) => (
                    <TouchableOpacity
                        key={index}
                        style={[
                            styles.dayButton,
                            selectedDays.includes(index) && styles.dayButtonActive,
                        ]}
                        onPress={() => toggleDay(index)}
                    >
                        <Text
                            style={[
                                styles.dayText,
                                selectedDays.includes(index) && styles.dayTextActive,
                            ]}
                        >
                            {day}
                        </Text>
                    </TouchableOpacity>
                ))}
            </View>
        </View>
    );
};

const styles = StyleSheet.create({
    container: {
        marginVertical: 16,
    },
    label: {
        fontSize: 16,
        fontWeight: '600',
        color: AppColors.onSurface,
        marginBottom: 12,
    },
    presetsContainer: {
        flexDirection: 'row',
        gap: 8,
        marginBottom: 12,
    },
    presetButton: {
        paddingHorizontal: 16,
        paddingVertical: 8,
        borderRadius: 8,
        backgroundColor: AppColors.surfaceVariant,
    },
    presetButtonActive: {
        backgroundColor: AppColors.primary,
    },
    presetText: {
        fontSize: 14,
        color: AppColors.onSurface,
        fontWeight: '500',
    },
    presetTextActive: {
        color: AppColors.onPrimary,
    },
    daysContainer: {
        flexDirection: 'row',
        justifyContent: 'space-between',
    },
    dayButton: {
        width: 44,
        height: 44,
        borderRadius: 22,
        backgroundColor: AppColors.surfaceVariant,
        justifyContent: 'center',
        alignItems: 'center',
    },
    dayButtonActive: {
        backgroundColor: AppColors.primary,
    },
    dayText: {
        fontSize: 14,
        fontWeight: '600',
        color: AppColors.onSurface,
    },
    dayTextActive: {
        color: AppColors.onPrimary,
    },
});
