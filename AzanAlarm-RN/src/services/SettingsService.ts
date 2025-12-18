import { AppSettings, PrayerCalculationMethod, JuristicMethod, AppTheme } from '../types';
import { storageService } from './StorageService';
import { STORAGE_KEYS } from '../constants/storage';

export interface SettingsService {
    getSettings(): Promise<AppSettings>;
    updateSettings(settings: AppSettings): Promise<void>;
    resetToDefaults(): Promise<void>;
}

const DEFAULT_SETTINGS: AppSettings = {
    calculationMethod: PrayerCalculationMethod.MuslimWorldLeague,
    juristicMethod: JuristicMethod.Shafii,
    audioTheme: 'default',
    is24HourFormat: false,
    enableNotifications: true,
    enableVibration: true,
    theme: AppTheme.System,
    language: 'en',
};

class SettingsServiceImpl implements SettingsService {
    /**
     * Get app settings from storage or return defaults
     */
    async getSettings(): Promise<AppSettings> {
        try {
            const settings = storageService.get<AppSettings>(STORAGE_KEYS.SETTINGS);

            if (!settings) {
                // First time - save defaults
                await this.updateSettings(DEFAULT_SETTINGS);
                return DEFAULT_SETTINGS;
            }

            // Merge with defaults to handle new settings added in updates
            return {
                ...DEFAULT_SETTINGS,
                ...settings,
            };
        } catch (error) {
            console.error('Failed to get settings:', error);
            return DEFAULT_SETTINGS;
        }
    }

    /**
     * Update app settings
     */
    async updateSettings(settings: AppSettings): Promise<void> {
        try {
            // Validate settings
            this.validateSettings(settings);

            // Save to storage
            storageService.set(STORAGE_KEYS.SETTINGS, settings);
        } catch (error) {
            console.error('Failed to update settings:', error);
            throw error;
        }
    }

    /**
     * Reset settings to defaults
     */
    async resetToDefaults(): Promise<void> {
        try {
            storageService.set(STORAGE_KEYS.SETTINGS, DEFAULT_SETTINGS);
        } catch (error) {
            console.error('Failed to reset settings:', error);
            throw error;
        }
    }

    /**
     * Validate settings object
     */
    private validateSettings(settings: AppSettings): void {
        if (!settings) {
            throw new Error('Settings object is required');
        }

        // Validate calculation method
        if (!Object.values(PrayerCalculationMethod).includes(settings.calculationMethod)) {
            throw new Error('Invalid calculation method');
        }

        // Validate juristic method
        if (!Object.values(JuristicMethod).includes(settings.juristicMethod)) {
            throw new Error('Invalid juristic method');
        }

        // Validate theme
        if (!Object.values(AppTheme).includes(settings.theme)) {
            throw new Error('Invalid theme');
        }
    }
}

export const settingsService = new SettingsServiceImpl();
