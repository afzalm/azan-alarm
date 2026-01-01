import { defineStore } from 'pinia'
import { ref } from 'vue'
import { usePrayerStore } from './prayerStore'
import { useAlarmStore } from './alarmStore'
import { useSettingsStore } from './settingsStore'


export const useAudioStore = defineStore('audio', () => {
    const isPlaying = ref(false)
    const checkInterval = ref<number | null>(null)
    const lastPlayedMinute = ref<string>('') // Prevent multiple triggers in same minute

    // Web Audio Context (Lazy initialized)
    let audioContext: AudioContext | null = null
    let oscillator: OscillatorNode | null = null
    let gainNode: GainNode | null = null

    function init() {
        // Initialize audio player
        // Note: User must provide the file. If missing, this might fail or be silent.
        // We use the imported URL which Vite handles.
        audioPlayer.value = new Audio(adhanSound)

        audioPlayer.value.addEventListener('ended', () => {
            isPlaying.value = false
        })

        startScheduler()
    }

    function startScheduler() {
        if (checkInterval.value) return

        // Check every second
        checkInterval.value = window.setInterval(() => {
            checkAlarms()
        }, 1000)
    }

    function checkAlarms() {
        const now = new Date()
        const currentTimeStr = now.toLocaleTimeString('en-US', { hour12: false, hour: '2-digit', minute: '2-digit' })

        // Prevent re-triggering in the same minute
        if (currentTimeStr === lastPlayedMinute.value) return

        const prayerStore = usePrayerStore()
        const alarmStore = useAlarmStore()
        const settingsStore = useSettingsStore()

        // 1. Check Prayer Times (if notifications enabled)
        if (settingsStore.settings.enableNotifications && prayerStore.todayTimes) {
            const prayers = [
                prayerStore.todayTimes.fajr,
                prayerStore.todayTimes.dhuhr,
                prayerStore.todayTimes.asr,
                prayerStore.todayTimes.maghrib,
                prayerStore.todayTimes.isha
            ]

            // Generate formatted times for comparison
            const currentFormatted = formatTimeForComparison(now)

            for (const pTime of prayers) {
                const pDate = new Date(pTime)
                const pFormatted = formatTimeForComparison(pDate)

                if (currentFormatted === pFormatted) {
                    playAudio()
                    lastPlayedMinute.value = currentTimeStr
                    return
                }
            }
        }

        // 2. Check Custom Alarms
        const currentDay = now.getDay() || 7 // Convert 0(Sun) to 7

        alarmStore.alarms.forEach(alarm => {
            if (!alarm.isActive) return
            // If repeatDays is empty -> runs daily. Else check if today is included.
            if (alarm.repeatDays.length > 0 && !alarm.repeatDays.includes(currentDay)) return

            // Find the base prayer time for this alarm
            const prayerTimeStr = (prayerStore.todayTimes as any)?.[alarm.prayer]
            if (!prayerTimeStr) return

            const alarmTime = new Date(prayerTimeStr)
            // Add offset
            alarmTime.setMinutes(alarmTime.getMinutes() + alarm.offsetMinutes)

            const alarmFormatted = formatTimeForComparison(alarmTime)
            const currentFormatted = formatTimeForComparison(now)

            if (currentFormatted === alarmFormatted) {
                playAudio()
                lastPlayedMinute.value = currentTimeStr
                return
            }
        })
    }

    function formatTimeForComparison(date: Date): string {
        return date.toLocaleTimeString('en-US', {
            hour12: false,
            hour: '2-digit',
            minute: '2-digit'
        })
    }

    async function triggerAlarm(title: string, body: string) {
        console.log("Triggering alarm:", title)

        // Ensure notification permission is requested on user gesture
        if ('Notification' in window && Notification.permission !== 'granted') {
            const permission = await Notification.requestPermission()
            console.log("Notification permission result:", permission)
        }

        try {
            await playBeep()
        } catch (e) {
            console.error("Error playing beep:", e)
        }

        sendNotification(title, body)
    }

    function sendNotification(title: string, body: string) {
        console.log("Sending notification:", title)
        if (!('Notification' in window)) {
            console.warn("Notifications not supported in this browser")
            return
        }

        if (Notification.permission === 'granted') {
            try {
                new Notification(title, {
                    body: body,
                    icon: '/appicon.png',
                    requireInteraction: true
                })
            } catch (e) {
                console.error("Error creating notification object:", e)
            }
        } else {
            console.warn("Notification permission not granted:", Notification.permission)
        }
    }

    async function playBeep() {
        console.log("Starting beep...")
        cancelAudio() // Stop any previous sound
        isPlaying.value = true

        try {
            if (!audioContext) {
                audioContext = new (window.AudioContext || (window as any).webkitAudioContext)()
            }

            // Always resume context on user interaction
            if (audioContext.state === 'suspended') {
                console.log("Resuming suspended audio context...")
                await audioContext.resume()
            }

            // Create Oscillator
            oscillator = audioContext.createOscillator()
            gainNode = audioContext.createGain()

            oscillator.connect(gainNode)
            gainNode.connect(audioContext.destination)

            // Configuration: Simple Beep
            oscillator.type = 'sine'
            oscillator.frequency.value = 880 // A5

            // Envelope
            const now = audioContext.currentTime
            gainNode.gain.setValueAtTime(0, now)
            gainNode.gain.linearRampToValueAtTime(0.5, now + 0.1)
            gainNode.gain.linearRampToValueAtTime(0, now + 0.5)

            // Play pattern (Beep... Beep... Beep)
            oscillator.start(now)

            // Pulse logic
            oscillator.frequency.setValueAtTime(880, now)
            oscillator.frequency.setValueAtTime(880, now + 0.5)
            oscillator.stop(now + 2.0)

            oscillator.onended = () => {
                console.log("Beep finished via onended")
                stopAudio()
            }
        } catch (e) {
            console.error("Audio Context Error:", e)
            isPlaying.value = false
        }
    }

    function cancelAudio() {
        if (oscillator) {
            try {
                oscillator.stop()
                oscillator.disconnect()
            } catch (e) { /* ignore if already stopped */ }
            oscillator = null
        }
        if (gainNode) {
            gainNode.disconnect()
            gainNode = null
        }
        isPlaying.value = false
    }

    function stopAudio() {
        if (!audioPlayer.value) return

        audioPlayer.value.pause()
        audioPlayer.value.currentTime = 0
        isPlaying.value = false
    }

    return {
        isPlaying,
        init,
        playBeep,
        triggerAlarm,
        stopAudio
    }
})
