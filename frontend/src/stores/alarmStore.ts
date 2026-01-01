import { defineStore } from 'pinia'
import { ref } from 'vue'
import { GetAlarms, CreateAlarm, UpdateAlarm, DeleteAlarm, ToggleAlarm } from '../../wailsjs/go/main/App'

interface Alarm {
    id: number
    prayer: string
    offsetMinutes: number
    label: string
    soundPath: string
    isActive: boolean
    repeatDays: number[]
    vibrationEnabled: boolean
    createdAt: number
    updatedAt: number
}

export const useAlarmStore = defineStore('alarms', () => {
    const alarms = ref<Alarm[]>([])
    const loading = ref(false)

    async function loadAlarms() {
        loading.value = true
        try {
            const data = await GetAlarms()
            alarms.value = data as unknown as Alarm[]
        } catch (error) {
            console.error('Failed to load alarms:', error)
        } finally {
            loading.value = false
        }
    }

    async function createAlarm(alarm: Partial<Alarm>) {
        try {
            const created = await CreateAlarm(alarm as any)
            alarms.value.push(created as unknown as Alarm)
        } catch (error) {
            console.error('Failed to create alarm:', error)
        }
    }

    async function updateAlarm(alarm: Alarm) {
        try {
            await UpdateAlarm(alarm as any)
            const index = alarms.value.findIndex(a => a.id === alarm.id)
            if (index !== -1) {
                alarms.value[index] = alarm
            }
        } catch (error) {
            console.error('Failed to update alarm:', error)
        }
    }

    async function deleteAlarm(id: number) {
        try {
            await DeleteAlarm(id)
            alarms.value = alarms.value.filter(a => a.id !== id)
        } catch (error) {
            console.error('Failed to delete alarm:', error)
        }
    }

    async function toggleAlarm(id: number, active: boolean) {
        try {
            await ToggleAlarm(id, active)
            const alarm = alarms.value.find(a => a.id === id)
            if (alarm) {
                alarm.isActive = active
            }
        } catch (error) {
            console.error('Failed to toggle alarm:', error)
        }
    }

    function getDisplayLabel(alarm: Alarm): string {
        if (alarm.label) return alarm.label

        const direction = alarm.offsetMinutes < 0 ? 'before' : 'after'
        const offset = Math.abs(alarm.offsetMinutes)
        const prayerName = alarm.prayer.charAt(0).toUpperCase() + alarm.prayer.slice(1)

        if (offset === 0) {
            return `At ${prayerName} time`
        }
        return `${offset} min ${direction} ${prayerName}`
    }

    return {
        alarms,
        loading,
        loadAlarms,
        createAlarm,
        updateAlarm,
        deleteAlarm,
        toggleAlarm,
        getDisplayLabel,
    }
})
