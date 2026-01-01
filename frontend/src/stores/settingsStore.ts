import { defineStore } from 'pinia'
import { ref } from 'vue'
import { GetSettings, SaveSettings } from '../../wailsjs/go/main/App'

interface AppSettings {
    calculationMethod: string
    juristicMethod: string
    audioTheme: string
    is24HourFormat: boolean
    enableNotifications: boolean
    enableVibration: boolean
    theme: string
    language: string
}

export const useSettingsStore = defineStore('settings', () => {
    const settings = ref<AppSettings>({
        calculationMethod: 'muslim_world_league',
        juristicMethod: 'shafii',
        audioTheme: 'default',
        is24HourFormat: false,
        enableNotifications: true,
        enableVibration: true,
        theme: 'system',
        language: 'en',
    })

    const loading = ref(false)

    const theme = ref<string>('light')

    async function loadSettings() {
        loading.value = true
        try {
            const data = await GetSettings()
            if (data) {
                settings.value = data as unknown as AppSettings
                updateTheme()
            }
        } catch (error) {
            console.error('Failed to load settings:', error)
        } finally {
            loading.value = false
        }
    }

    async function saveSettings(newSettings: Partial<AppSettings>) {
        const updated = { ...settings.value, ...newSettings }
        try {
            await SaveSettings(updated as any)
            settings.value = updated
            updateTheme()
        } catch (error) {
            console.error('Failed to save settings:', error)
        }
    }

    function updateTheme() {
        const prefersDark = window.matchMedia('(prefers-color-scheme: dark)').matches
        let activeTheme = 'light'

        if (settings.value.theme === 'system') {
            activeTheme = prefersDark ? 'dark' : 'light'
        } else {
            activeTheme = settings.value.theme
        }

        theme.value = activeTheme
        document.documentElement.setAttribute('data-theme', activeTheme)
    }

    return {
        settings,
        loading,
        theme,
        loadSettings,
        saveSettings,
    }
})
