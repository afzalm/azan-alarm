import { Alarm, Prayer } from '../types';
import { storageService } from './StorageService';
import { STORAGE_KEYS } from '../constants/storage';
import { calculateNextAlarmTime } from '../utils/alarmUtils';

export interface AlarmService {
    scheduleAlarm(alarm: Alarm): Promise<void>;
    cancelAlarm(alarmId: string): Promise<void>;
    updateAlarm(alarm: Alarm): Promise<void>;
    getAllAlarms(): Promise<Alarm[]>;
    toggleAlarm(alarmId: string, isActive: boolean): Promise<void>;
}

class AlarmServiceImpl implements AlarmService {
    /**
     * Schedule a new alarm
     */
    async scheduleAlarm(alarm: Alarm): Promise<void> {
        try {
            const alarms = await this.getAllAlarms();

            const newAlarm: Alarm = {
                ...alarm,
                id: alarm.id || `alarm_${Date.now()}`,
                createdAt: alarm.createdAt || new Date().toISOString(),
                updatedAt: new Date().toISOString(),
                isActive: true,
            };

            alarms.push(newAlarm);
            storageService.set(STORAGE_KEYS.ALARMS, alarms);

            // TODO: Schedule background task for alarm
            console.log('Alarm scheduled:', newAlarm);
        } catch (error) {
            console.error('Failed to schedule alarm:', error);
            throw error;
        }
    }

    /**
     * Cancel an alarm
     */
    async cancelAlarm(alarmId: string): Promise<void> {
        try {
            const alarms = await this.getAllAlarms();
            const filteredAlarms = alarms.filter(alarm => alarm.id !== alarmId);

            storageService.set(STORAGE_KEYS.ALARMS, filteredAlarms);

            // TODO: Cancel background task
            console.log('Alarm cancelled:', alarmId);
        } catch (error) {
            console.error('Failed to cancel alarm:', error);
            throw error;
        }
    }

    /**
     * Update an existing alarm
     */
    async updateAlarm(alarm: Alarm): Promise<void> {
        try {
            const alarms = await this.getAllAlarms();
            const index = alarms.findIndex(a => a.id === alarm.id);

            if (index === -1) {
                throw new Error('Alarm not found');
            }

            alarms[index] = {
                ...alarm,
                updatedAt: new Date().toISOString(),
            };

            storageService.set(STORAGE_KEYS.ALARMS, alarms);

            // TODO: Reschedule background task
            console.log('Alarm updated:', alarm);
        } catch (error) {
            console.error('Failed to update alarm:', error);
            throw error;
        }
    }

    /**
     * Get all alarms
     */
    async getAllAlarms(): Promise<Alarm[]> {
        try {
            const alarms = storageService.get<Alarm[]>(STORAGE_KEYS.ALARMS);
            return alarms || [];
        } catch (error) {
            console.error('Failed to get alarms:', error);
            return [];
        }
    }

    /**
     * Toggle alarm active state
     */
    async toggleAlarm(alarmId: string, isActive: boolean): Promise<void> {
        try {
            const alarms = await this.getAllAlarms();
            const alarm = alarms.find(a => a.id === alarmId);

            if (!alarm) {
                throw new Error('Alarm not found');
            }

            alarm.isActive = isActive;
            alarm.updatedAt = new Date().toISOString();

            storageService.set(STORAGE_KEYS.ALARMS, alarms);

            // TODO: Enable/disable background task
            console.log('Alarm toggled:', alarmId, isActive);
        } catch (error) {
            console.error('Failed to toggle alarm:', error);
            throw error;
        }
    }
}

export const alarmService = new AlarmServiceImpl();
