import React from 'react';
import { View, Text, StyleSheet, ScrollView, TouchableOpacity, Switch } from 'react-native';
import { useTheme } from '../../hooks/useTheme';
import { settingsService } from '../../services/SettingsService';
import { AppTheme, PrayerCalculationMethod, JuristicMethod } from '../../types';

export const SettingsScreen = () => {
    const { theme, colors, isDark, setTheme } = useTheme();
    const [settings, setSettings] = React.useState({
        calculationMethod: PrayerCalculationMethod.MuslimWorldLeague,
        juristicMethod: JuristicMethod.Shafii,
        is24HourFormat: false,
        enableNotifications: true,
        enableVibration: true,
    });

    React.useEffect(() => {
        loadSettings();
    }, []);

    const loadSettings = async () => {
        const appSettings = await settingsService.getSettings();
        setSettings({
            calculationMethod: appSettings.calculationMethod,
            juristicMethod: appSettings.juristicMethod,
            is24HourFormat: appSettings.is24HourFormat,
            enableNotifications: appSettings.enableNotifications,
            enableVibration: appSettings.enableVibration,
        });
    };

    const updateSetting = async (key: string, value: any) => {
        const newSettings = { ...settings, [key]: value };
        setSettings(newSettings);

        const appSettings = await settingsService.getSettings();
        await settingsService.updateSettings({
            ...appSettings,
            [key]: value,
        });
    };

    const styles = createStyles(colors);

    return (
        <ScrollView style={styles.container}>
            {/* Theme Section */}
            <View style={styles.section}>
                <Text style={styles.sectionTitle}>Appearance</Text>

                <View style={styles.settingRow}>
                    <Text style={styles.settingLabel}>Theme</Text>
                    <View style={styles.themeButtons}>
                        <TouchableOpacity
                            style={[styles.themeButton, theme === AppTheme.Light && styles.themeButtonActive]}
                            onPress={() => setTheme(AppTheme.Light)}
                        >
                            <Text style={[styles.themeButtonText, theme === AppTheme.Light && styles.themeButtonTextActive]}>
                                Light
                            </Text>
                        </TouchableOpacity>
                        <TouchableOpacity
                            style={[styles.themeButton, theme === AppTheme.Dark && styles.themeButtonActive]}
                            onPress={() => setTheme(AppTheme.Dark)}
                        >
                            <Text style={[styles.themeButtonText, theme === AppTheme.Dark && styles.themeButtonTextActive]}>
                                Dark
                            </Text>
                        </TouchableOpacity>
                        <TouchableOpacity
                            style={[styles.themeButton, theme === AppTheme.System && styles.themeButtonActive]}
                            onPress={() => setTheme(AppTheme.System)}
                        >
                            <Text style={[styles.themeButtonText, theme === AppTheme.System && styles.themeButtonTextActive]}>
                                System
                            </Text>
                        </TouchableOpacity>
                    </View>
                </View>
            </View>

            {/* Prayer Settings */}
            <View style={styles.section}>
                <Text style={styles.sectionTitle}>Prayer Settings</Text>

                <View style={styles.settingRow}>
                    <Text style={styles.settingLabel}>Calculation Method</Text>
                    <Text style={styles.settingValue}>
                        {settings.calculationMethod.replace(/_/g, ' ')}
                    </Text>
                </View>

                <View style={styles.settingRow}>
                    <Text style={styles.settingLabel}>Juristic Method</Text>
                    <Text style={styles.settingValue}>
                        {settings.juristicMethod}
                    </Text>
                </View>

                <View style={styles.settingRow}>
                    <Text style={styles.settingLabel}>24-Hour Format</Text>
                    <Switch
                        value={settings.is24HourFormat}
                        onValueChange={(value) => updateSetting('is24HourFormat', value)}
                        trackColor={{ false: colors.surfaceVariant, true: colors.primary }}
                        thumbColor={colors.onPrimary}
                    />
                </View>
            </View>

            {/* Notifications */}
            <View style={styles.section}>
                <Text style={styles.sectionTitle}>Notifications</Text>

                <View style={styles.settingRow}>
                    <Text style={styles.settingLabel}>Enable Notifications</Text>
                    <Switch
                        value={settings.enableNotifications}
                        onValueChange={(value) => updateSetting('enableNotifications', value)}
                        trackColor={{ false: colors.surfaceVariant, true: colors.primary }}
                        thumbColor={colors.onPrimary}
                    />
                </View>

                <View style={styles.settingRow}>
                    <Text style={styles.settingLabel}>Vibration</Text>
                    <Switch
                        value={settings.enableVibration}
                        onValueChange={(value) => updateSetting('enableVibration', value)}
                        trackColor={{ false: colors.surfaceVariant, true: colors.primary }}
                        thumbColor={colors.onPrimary}
                    />
                </View>
            </View>

            {/* About */}
            <View style={styles.section}>
                <Text style={styles.sectionTitle}>About</Text>
                <Text style={styles.aboutText}>AzanAlarm v1.0.0</Text>
                <Text style={styles.aboutText}>Islamic Prayer Times & Alarms</Text>
            </View>
        </ScrollView>
    );
};

const createStyles = (colors: any) => StyleSheet.create({
    container: {
        flex: 1,
        backgroundColor: colors.background,
    },
    section: {
        padding: 16,
        borderBottomWidth: 1,
        borderBottomColor: colors.surfaceVariant,
    },
    sectionTitle: {
        fontSize: 18,
        fontWeight: '700',
        color: colors.onSurface,
        marginBottom: 16,
    },
    settingRow: {
        flexDirection: 'row',
        justifyContent: 'space-between',
        alignItems: 'center',
        paddingVertical: 12,
    },
    settingLabel: {
        fontSize: 16,
        color: colors.onSurface,
    },
    settingValue: {
        fontSize: 14,
        color: colors.onSurface,
        opacity: 0.7,
        textTransform: 'capitalize',
    },
    themeButtons: {
        flexDirection: 'row',
        gap: 8,
    },
    themeButton: {
        paddingHorizontal: 16,
        paddingVertical: 8,
        borderRadius: 8,
        backgroundColor: colors.surfaceVariant,
    },
    themeButtonActive: {
        backgroundColor: colors.primary,
    },
    themeButtonText: {
        fontSize: 14,
        color: colors.onSurface,
        fontWeight: '500',
    },
    themeButtonTextActive: {
        color: colors.onPrimary,
    },
    aboutText: {
        fontSize: 14,
        color: colors.onSurface,
        opacity: 0.7,
        marginBottom: 4,
    },
});
