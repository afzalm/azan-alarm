import { defineStore } from 'pinia'
import { ref, computed } from 'vue'
import { GetTodayPrayerTimes, GetNextPrayer, GetPrayerTimes } from '../../wailsjs/go/main/App'
import { useSettingsStore } from './settingsStore'

interface PrayerTimes {
    fajr: string
    dhuhr: string
    asr: string
    maghrib: string
    isha: string
}

interface NextPrayer {
    prayer: string
    time: string
    remainingSeconds: number
}

export const usePrayerStore = defineStore('prayer', () => {
    const todayTimes = ref<PrayerTimes | null>(null)
    const nextPrayer = ref<NextPrayer | null>(null)
    const loading = ref(false)
    const countdown = ref<string>('')
    let countdownInterval: number | null = null

    const prayerList = computed(() => {
        if (!todayTimes.value) return []

        const settingsStore = useSettingsStore()
        const now = new Date()

        return [
            { key: 'fajr', name: 'Fajr', time: todayTimes.value.fajr, icon: '🌅', color: 'var(--fajr-color)' },
            { key: 'dhuhr', name: 'Dhuhr', time: todayTimes.value.dhuhr, icon: '☀️', color: 'var(--dhuhr-color)' },
            { key: 'asr', name: 'Asr', time: todayTimes.value.asr, icon: '🌤️', color: 'var(--asr-color)' },
            { key: 'maghrib', name: 'Maghrib', time: todayTimes.value.maghrib, icon: '🌅', color: 'var(--maghrib-color)' },
            { key: 'isha', name: 'Isha', time: todayTimes.value.isha, icon: '🌙', color: 'var(--isha-color)' },
        ].map(p => ({
            ...p,
            formattedTime: formatTime(p.time, settingsStore.settings.is24HourFormat),
            hasPassed: new Date(p.time) < now,
            isNext: nextPrayer.value?.prayer === p.key,
        }))
    })

    function formatTime(isoString: string, is24Hour: boolean): string {
        if (!isoString) return '--:--'
        try {
            const date = new Date(isoString)
            if (is24Hour) {
                return date.toLocaleTimeString('en-US', { hour: '2-digit', minute: '2-digit', hour12: false })
            }
            return date.toLocaleTimeString('en-US', { hour: 'numeric', minute: '2-digit', hour12: true })
        } catch {
            return '--:--'
        }
    }

    async function loadTodayPrayerTimes() {
        loading.value = true
        try {
            const times = await GetTodayPrayerTimes()
            todayTimes.value = times as unknown as PrayerTimes
        } catch (error) {
            console.error('Failed to load prayer times:', error)
        } finally {
            loading.value = false
        }
    }

    async function loadNextPrayer() {
        try {
            const next = await GetNextPrayer()
            nextPrayer.value = next as unknown as NextPrayer
            updateCountdown()
        } catch (error) {
            console.error('Failed to load next prayer:', error)
        }
    }

    function startCountdown() {
        if (countdownInterval) return

        countdownInterval = window.setInterval(() => {
            updateCountdown()
        }, 1000)
    }

    function stopCountdown() {
        if (countdownInterval) {
            clearInterval(countdownInterval)
            countdownInterval = null
        }
    }

    function updateCountdown() {
        if (!nextPrayer.value) {
            countdown.value = '--:--:--'
            return
        }

        const targetTime = new Date(nextPrayer.value.time)
        const now = new Date()
        const diff = targetTime.getTime() - now.getTime()

        if (diff <= 0) {
            countdown.value = '00:00:00'
            // Refresh prayer data
            loadTodayPrayerTimes()
            loadNextPrayer()
            return
        }

        const hours = Math.floor(diff / (1000 * 60 * 60))
        const minutes = Math.floor((diff % (1000 * 60 * 60)) / (1000 * 60))
        const seconds = Math.floor((diff % (1000 * 60)) / 1000)

        countdown.value = [
            hours.toString().padStart(2, '0'),
            minutes.toString().padStart(2, '0'),
            seconds.toString().padStart(2, '0'),
        ].join(':')
    }

    return {
        todayTimes,
        nextPrayer,
        loading,
        countdown,
        prayerList,
        loadTodayPrayerTimes,
        loadNextPrayer,
        startCountdown,
        stopCountdown,
        formatTime,
    }
})
