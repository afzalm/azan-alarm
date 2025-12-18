import { Alarm, Prayer } from '../types';
import { checkNotificationPermission, requestNotificationPermission, PermissionStatus } from '../utils/PermissionUtils';
import { NOTIFICATION_CHANNEL } from '../constants/alarms';

export interface NotificationService {
    initialize(): Promise<void>;
    showAlarmNotification(alarm: Alarm): Promise<void>;
    showPrayerReminder(prayer: Prayer, time: string): Promise<void>;
    requestPermissions(): Promise<void>;
    arePermissionsGranted(): Promise<boolean>;
}

class NotificationServiceImpl implements NotificationService {
    private initialized = false;

    async initialize(): Promise<void> {
        if (this.initialized) {
            return;
        }

        try {
            // Request permissions on initialization
            await this.requestPermissions();

            // TODO: Initialize react-native-notifications
            // TODO: Create notification channel for Android
            // TODO: Register notification handlers

            this.initialized = true;
            console.log('Notification service initialized');
        } catch (error) {
            console.error('Failed to initialize notifications:', error);
            throw error;
        }
    }

    async showAlarmNotification(alarm: Alarm): Promise<void> {
        try {
            // TODO: Implement using react-native-notifications
            // For now, just log
            console.log('Showing alarm notification:', {
                title: 'Prayer Time Alarm',
                body: alarm.label || `Time for ${alarm.prayer}`,
                sound: alarm.soundId || 'default',
                vibrate: alarm.vibrationEnabled,
            });

            // Notification should include:
            // - Title: "Prayer Time Alarm"
            // - Body: alarm label or prayer name
            // - Sound: alarm.soundId
            // - Vibration: alarm.vibrationEnabled
            // - Actions: Dismiss, Snooze (optional)
        } catch (error) {
            console.error('Failed to show alarm notification:', error);
        }
    }

    async showPrayerReminder(prayer: Prayer, time: string): Promise<void> {
        try {
            // TODO: Implement prayer reminder notification
            console.log('Showing prayer reminder:', {
                title: `${prayer} Prayer Time`,
                body: `It's time for ${prayer} prayer at ${time}`,
            });
        } catch (error) {
            console.error('Failed to show prayer reminder:', error);
        }
    }

    async requestPermissions(): Promise<void> {
        try {
            const status = await requestNotificationPermission();

            if (status !== PermissionStatus.GRANTED) {
                console.warn('Notification permission not granted');
            }
        } catch (error) {
            console.error('Failed to request notification permissions:', error);
            throw error;
        }
    }

    async arePermissionsGranted(): Promise<boolean> {
        try {
            const status = await checkNotificationPermission();
            return status === PermissionStatus.GRANTED;
        } catch (error) {
            console.error('Failed to check notification permissions:', error);
            return false;
        }
    }
}

export const notificationService = new NotificationServiceImpl();
