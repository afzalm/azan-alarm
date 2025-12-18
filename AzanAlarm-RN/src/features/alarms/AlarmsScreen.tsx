import React, { useState } from 'react';
import { View, Text, StyleSheet, ScrollView, TouchableOpacity, Modal, TextInput, Alert } from 'react-native';
import { AppColors } from '../../constants/theme';
import { useAlarms } from '../../hooks/useAlarms';
import { AlarmCard } from '../../components/AlarmCard';
import { RepeatDaysSelector } from '../../components/RepeatDaysSelector';
import { Alarm, Prayer } from '../../types';
import { getAllPrayers, getPrayerName } from '../../utils/prayerUtils';
import { validateAlarm } from '../../utils/alarmUtils';
import { OFFSET_MIN, OFFSET_MAX, REPEAT_PATTERNS } from '../../constants/alarms';

export const AlarmsScreen = () => {
    const { alarms, createAlarm, updateAlarm, deleteAlarm, toggleAlarm, isLoading } = useAlarms();
    const [showModal, setShowModal] = useState(false);
    const [editingAlarm, setEditingAlarm] = useState<Alarm | null>(null);

    // Form state
    const [selectedPrayer, setSelectedPrayer] = useState<Prayer>('fajr');
    const [offsetMinutes, setOffsetMinutes] = useState(0);
    const [label, setLabel] = useState('');
    const [repeatDays, setRepeatDays] = useState<number[]>(REPEAT_PATTERNS.DAILY);
    const [vibrationEnabled, setVibrationEnabled] = useState(true);

    const handleAddAlarm = () => {
        setEditingAlarm(null);
        setSelectedPrayer('fajr');
        setOffsetMinutes(0);
        setLabel('');
        setRepeatDays(REPEAT_PATTERNS.DAILY);
        setVibrationEnabled(true);
        setShowModal(true);
    };

    const handleEditAlarm = (alarm: Alarm) => {
        setEditingAlarm(alarm);
        setSelectedPrayer(alarm.prayer);
        setOffsetMinutes(alarm.offsetMinutes);
        setLabel(alarm.label || '');
        setRepeatDays(alarm.repeatDays);
        setVibrationEnabled(alarm.vibrationEnabled);
        setShowModal(true);
    };

    const handleSaveAlarm = async () => {
        const alarmData: Partial<Alarm> = {
            prayer: selectedPrayer,
            offsetMinutes,
            label: label.trim(),
            repeatDays,
            vibrationEnabled,
        };

        const error = validateAlarm(alarmData);
        if (error) {
            Alert.alert('Validation Error', error);
            return;
        }

        try {
            if (editingAlarm) {
                await updateAlarm({
                    ...editingAlarm,
                    ...alarmData,
                } as Alarm);
            } else {
                await createAlarm({
                    ...alarmData,
                    isActive: true,
                    createdAt: new Date().toISOString(),
                    updatedAt: new Date().toISOString(),
                } as Alarm);
            }
            setShowModal(false);
        } catch (error) {
            Alert.alert('Error', 'Failed to save alarm');
        }
    };

    const handleDeleteAlarm = (alarmId: string) => {
        Alert.alert(
            'Delete Alarm',
            'Are you sure you want to delete this alarm?',
            [
                { text: 'Cancel', style: 'cancel' },
                {
                    text: 'Delete',
                    style: 'destructive',
                    onPress: () => deleteAlarm(alarmId),
                },
            ]
        );
    };

    return (
        <View style={styles.container}>
            <ScrollView contentContainerStyle={styles.contentContainer}>
                {alarms.length === 0 ? (
                    <View style={styles.emptyContainer}>
                        <Text style={styles.emptyTitle}>No Alarms Set</Text>
                        <Text style={styles.emptyText}>
                            Tap the + button to create your first alarm
                        </Text>
                    </View>
                ) : (
                    alarms.map((alarm) => (
                        <AlarmCard
                            key={alarm.id}
                            alarm={alarm}
                            onToggle={(isActive) => toggleAlarm(alarm.id!, isActive)}
                            onEdit={() => handleEditAlarm(alarm)}
                            onDelete={() => handleDeleteAlarm(alarm.id!)}
                        />
                    ))
                )}
            </ScrollView>

            {/* Floating Action Button */}
            <TouchableOpacity style={styles.fab} onPress={handleAddAlarm}>
                <Text style={styles.fabText}>+</Text>
            </TouchableOpacity>

            {/* Alarm Creation Modal */}
            <Modal
                visible={showModal}
                animationType="slide"
                transparent={true}
                onRequestClose={() => setShowModal(false)}
            >
                <View style={styles.modalOverlay}>
                    <View style={styles.modalContent}>
                        <Text style={styles.modalTitle}>
                            {editingAlarm ? 'Edit Alarm' : 'New Alarm'}
                        </Text>

                        <ScrollView>
                            {/* Prayer Selection */}
                            <View style={styles.section}>
                                <Text style={styles.sectionLabel}>Prayer</Text>
                                <View style={styles.prayerButtons}>
                                    {getAllPrayers().map((prayer) => (
                                        <TouchableOpacity
                                            key={prayer}
                                            style={[
                                                styles.prayerButton,
                                                selectedPrayer === prayer && styles.prayerButtonActive,
                                            ]}
                                            onPress={() => setSelectedPrayer(prayer)}
                                        >
                                            <Text
                                                style={[
                                                    styles.prayerButtonText,
                                                    selectedPrayer === prayer && styles.prayerButtonTextActive,
                                                ]}
                                            >
                                                {getPrayerName(prayer)}
                                            </Text>
                                        </TouchableOpacity>
                                    ))}
                                </View>
                            </View>

                            {/* Offset */}
                            <View style={styles.section}>
                                <Text style={styles.sectionLabel}>
                                    Offset: {offsetMinutes} minutes {offsetMinutes < 0 ? 'before' : offsetMinutes > 0 ? 'after' : 'at prayer time'}
                                </Text>
                                <View style={styles.offsetButtons}>
                                    <TouchableOpacity
                                        style={styles.offsetButton}
                                        onPress={() => setOffsetMinutes(Math.max(OFFSET_MIN, offsetMinutes - 5))}
                                    >
                                        <Text style={styles.offsetButtonText}>-5</Text>
                                    </TouchableOpacity>
                                    <TouchableOpacity
                                        style={styles.offsetButton}
                                        onPress={() => setOffsetMinutes(0)}
                                    >
                                        <Text style={styles.offsetButtonText}>Reset</Text>
                                    </TouchableOpacity>
                                    <TouchableOpacity
                                        style={styles.offsetButton}
                                        onPress={() => setOffsetMinutes(Math.min(OFFSET_MAX, offsetMinutes + 5))}
                                    >
                                        <Text style={styles.offsetButtonText}>+5</Text>
                                    </TouchableOpacity>
                                </View>
                            </View>

                            {/* Label */}
                            <View style={styles.section}>
                                <Text style={styles.sectionLabel}>Label (Optional)</Text>
                                <TextInput
                                    style={styles.input}
                                    placeholder="e.g., Morning Prayer"
                                    value={label}
                                    onChangeText={setLabel}
                                />
                            </View>

                            {/* Repeat Days */}
                            <RepeatDaysSelector
                                selectedDays={repeatDays}
                                onDaysChange={setRepeatDays}
                            />
                        </ScrollView>

                        {/* Actions */}
                        <View style={styles.modalActions}>
                            <TouchableOpacity
                                style={[styles.modalButton, styles.cancelButton]}
                                onPress={() => setShowModal(false)}
                            >
                                <Text style={styles.cancelButtonText}>Cancel</Text>
                            </TouchableOpacity>
                            <TouchableOpacity
                                style={[styles.modalButton, styles.saveButton]}
                                onPress={handleSaveAlarm}
                            >
                                <Text style={styles.saveButtonText}>Save</Text>
                            </TouchableOpacity>
                        </View>
                    </View>
                </View>
            </Modal>
        </View>
    );
};

const styles = StyleSheet.create({
    container: {
        flex: 1,
        backgroundColor: AppColors.surface,
    },
    contentContainer: {
        padding: 16,
        paddingBottom: 80,
    },
    emptyContainer: {
        flex: 1,
        justifyContent: 'center',
        alignItems: 'center',
        paddingTop: 100,
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
    fab: {
        position: 'absolute',
        right: 20,
        bottom: 20,
        width: 56,
        height: 56,
        borderRadius: 28,
        backgroundColor: AppColors.primary,
        justifyContent: 'center',
        alignItems: 'center',
        shadowColor: '#000',
        shadowOffset: { width: 0, height: 4 },
        shadowOpacity: 0.3,
        shadowRadius: 8,
        elevation: 8,
    },
    fabText: {
        fontSize: 32,
        color: AppColors.onPrimary,
        fontWeight: '300',
    },
    modalOverlay: {
        flex: 1,
        backgroundColor: 'rgba(0, 0, 0, 0.5)',
        justifyContent: 'flex-end',
    },
    modalContent: {
        backgroundColor: AppColors.surface,
        borderTopLeftRadius: 20,
        borderTopRightRadius: 20,
        padding: 20,
        maxHeight: '90%',
    },
    modalTitle: {
        fontSize: 24,
        fontWeight: '700',
        color: AppColors.onSurface,
        marginBottom: 20,
    },
    section: {
        marginBottom: 20,
    },
    sectionLabel: {
        fontSize: 16,
        fontWeight: '600',
        color: AppColors.onSurface,
        marginBottom: 12,
    },
    prayerButtons: {
        flexDirection: 'row',
        flexWrap: 'wrap',
        gap: 8,
    },
    prayerButton: {
        paddingHorizontal: 16,
        paddingVertical: 10,
        borderRadius: 8,
        backgroundColor: AppColors.surfaceVariant,
    },
    prayerButtonActive: {
        backgroundColor: AppColors.primary,
    },
    prayerButtonText: {
        fontSize: 14,
        color: AppColors.onSurface,
        fontWeight: '500',
    },
    prayerButtonTextActive: {
        color: AppColors.onPrimary,
    },
    offsetButtons: {
        flexDirection: 'row',
        gap: 8,
    },
    offsetButton: {
        flex: 1,
        paddingVertical: 12,
        borderRadius: 8,
        backgroundColor: AppColors.primaryContainer,
        alignItems: 'center',
    },
    offsetButtonText: {
        fontSize: 16,
        color: AppColors.primary,
        fontWeight: '600',
    },
    input: {
        backgroundColor: AppColors.surfaceVariant,
        padding: 16,
        borderRadius: 12,
        fontSize: 16,
        color: AppColors.onSurface,
    },
    modalActions: {
        flexDirection: 'row',
        gap: 12,
        marginTop: 20,
    },
    modalButton: {
        flex: 1,
        paddingVertical: 16,
        borderRadius: 12,
        alignItems: 'center',
    },
    cancelButton: {
        backgroundColor: AppColors.surfaceVariant,
    },
    saveButton: {
        backgroundColor: AppColors.primary,
    },
    cancelButtonText: {
        fontSize: 16,
        color: AppColors.onSurface,
        fontWeight: '600',
    },
    saveButtonText: {
        fontSize: 16,
        color: AppColors.onPrimary,
        fontWeight: '600',
    },
});
