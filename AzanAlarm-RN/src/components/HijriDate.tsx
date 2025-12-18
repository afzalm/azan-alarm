import React from 'react';
import { View, Text, StyleSheet } from 'react-native';
import { getHijriDate } from '../utils/dateUtils';
import { AppColors } from '../constants/theme';

export const HijriDate: React.FC = () => {
    const { day, month, year } = getHijriDate();

    return (
        <View style={styles.container}>
            <Text style={styles.text}>
                {day} {month} {year} AH
            </Text>
        </View>
    );
};

const styles = StyleSheet.create({
    container: {
        paddingVertical: 8,
        paddingHorizontal: 16,
        backgroundColor: AppColors.secondaryContainer,
        borderRadius: 8,
        alignSelf: 'center',
    },
    text: {
        fontSize: 14,
        color: AppColors.onSurface,
        fontWeight: '500',
    },
});
