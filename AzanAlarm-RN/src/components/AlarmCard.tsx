import React from 'react';
import { View, Text, StyleSheet, TouchableOpacity, Switch } from 'react-native';
import { Alarm } from '../types';
import { getPrayerName, getPrayerColor } from '../utils/prayerUtils';
import { formatOffsetText, formatRepeatDaysText } from '../utils/alarmUtils';
import { AppColors } from '../constants/theme';

interface AlarmCardProps {
    alarm: Alarm;
    onToggle?: (isActive: boolean) => void;
    onEdit?: () => void;
    onDelete?: () => void;
}

export const AlarmCard: React.FC<AlarmCardProps> = ({
    alarm,
    onToggle,
    onEdit,
    onDelete,
}) => {
    const prayerName = getPrayerName(alarm.prayer);
    const prayerColor = getPrayerColor(alarm.prayer);
    const offsetText = formatOffsetText(alarm.offsetMinutes);
    const repeatText = formatRepeatDaysText(alarm.repeatDays);

    return (
        <View style={[styles.container, { borderLeftColor: prayerColor }]}>
            <View style={styles.header}>
                <View style={styles.leftSection}>
                    <View style={[styles.indicator, { backgroundColor: prayerColor }]} />
                    <View>
                        <Text style={[styles.prayerName, !alarm.isActive && styles.inactiveText]}>
                            {prayerName}
                        </Text>
                        <Text style={[styles.offsetText, !alarm.isActive && styles.inactiveText]}>
                            {offsetText}
                        </Text>
                    </View>
                </View>
                <Switch
                    value={alarm.isActive}
                    onValueChange={onToggle}
                    trackColor={{ false: AppColors.surfaceVariant, true: prayerColor }}
                    thumbColor={AppColors.onPrimary}
                />
            </View>

            {alarm.label && (
                <Text style={[styles.label, !alarm.isActive && styles.inactiveText]}>
                    {alarm.label}
                </Text>
            )}

            <View style={styles.footer}>
                <Text style={[styles.repeatText, !alarm.isActive && styles.inactiveText]}>
                    {repeatText}
                </Text>
                <View style={styles.actions}>
                    {onEdit && (
                        <TouchableOpacity style={styles.actionButton} onPress={onEdit}>
                            <Text style={styles.actionText}>Edit</Text>
                        </TouchableOpacity>
                    )}
                    {onDelete && (
                        <TouchableOpacity style={styles.actionButton} onPress={onDelete}>
                            <Text style={[styles.actionText, styles.deleteText]}>Delete</Text>
                        </TouchableOpacity>
                    )}
                </View>
            </View>
        </View>
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
    header: {
        flexDirection: 'row',
        justifyContent: 'space-between',
        alignItems: 'center',
        marginBottom: 8,
    },
    leftSection: {
        flexDirection: 'row',
        alignItems: 'center',
        flex: 1,
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
    offsetText: {
        fontSize: 14,
        color: AppColors.onSurface,
        opacity: 0.7,
        marginTop: 2,
    },
    label: {
        fontSize: 14,
        color: AppColors.onSurface,
        marginBottom: 8,
        marginLeft: 24,
    },
    footer: {
        flexDirection: 'row',
        justifyContent: 'space-between',
        alignItems: 'center',
        marginTop: 8,
    },
    repeatText: {
        fontSize: 12,
        color: AppColors.onSurface,
        opacity: 0.6,
    },
    actions: {
        flexDirection: 'row',
        gap: 12,
    },
    actionButton: {
        paddingHorizontal: 12,
        paddingVertical: 6,
    },
    actionText: {
        fontSize: 14,
        color: AppColors.primary,
        fontWeight: '500',
    },
    deleteText: {
        color: AppColors.error,
    },
    inactiveText: {
        opacity: 0.4,
    },
});
