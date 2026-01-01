<script setup lang="ts">
import { computed } from 'vue'
import { useSettingsStore } from '../stores/settingsStore'
import { useAudioStore } from '../stores/audioStore'

const settingsStore = useSettingsStore()
const audioStore = useAudioStore()

const calculationMethods = [
  { value: 'muslim_world_league', label: 'Muslim World League' },
  { value: 'isna', label: 'Islamic Society of North America (ISNA)' },
  { value: 'egyptian', label: 'Egyptian General Authority' },
  { value: 'umm_al_qura', label: 'Umm Al-Qura (Makkah)' },
  { value: 'karachi', label: 'University of Karachi' },
  { value: 'tehran', label: 'Institute of Geophysics, Tehran' },
  { value: 'jafari', label: 'Shia Ithna-Ashari (Jafari)' },
  { value: 'gulf', label: 'Gulf Region' },
  { value: 'moonsighting_committee', label: 'Moonsighting Committee' },
  { value: 'north_america', label: 'North America' },
]

const juristicMethods = [
  { value: 'shafii', label: "Shafi'i, Maliki, Hanbali" },
  { value: 'hanafi', label: 'Hanafi' },
]

const themes = [
  { value: 'light', label: 'Light' },
  { value: 'dark', label: 'Dark' },
  { value: 'system', label: 'System' },
]

function updateSetting(key: string, value: any) {
  settingsStore.saveSettings({ [key]: value })
}
</script>

<template>
  <div class="settings-view">
    <h1 class="view-title">Settings</h1>

    <!-- Prayer Calculation -->
    <section class="settings-section">
      <h2 class="section-title">Prayer Calculation</h2>
      
      <div class="setting-item">
        <div class="setting-info">
          <span class="setting-label">Calculation Method</span>
          <span class="setting-hint">Method used to calculate prayer times</span>
        </div>
        <select
          :value="settingsStore.settings.calculationMethod"
          @change="updateSetting('calculationMethod', ($event.target as HTMLSelectElement).value)"
          class="input select-input"
        >
          <option v-for="m in calculationMethods" :key="m.value" :value="m.value">
            {{ m.label }}
          </option>
        </select>
      </div>

      <div class="setting-item">
        <div class="setting-info">
          <span class="setting-label">Juristic Method (Asr)</span>
          <span class="setting-hint">Method for calculating Asr prayer</span>
        </div>
        <select
          :value="settingsStore.settings.juristicMethod"
          @change="updateSetting('juristicMethod', ($event.target as HTMLSelectElement).value)"
          class="input select-input"
        >
          <option v-for="m in juristicMethods" :key="m.value" :value="m.value">
            {{ m.label }}
          </option>
        </select>
      </div>
    </section>

    <!-- Display -->
    <section class="settings-section">
      <h2 class="section-title">Display</h2>

      <div class="setting-item">
        <div class="setting-info">
          <span class="setting-label">24-Hour Time Format</span>
          <span class="setting-hint">Display time in 24-hour format</span>
        </div>
        <div
          class="switch"
          :class="{ active: settingsStore.settings.is24HourFormat }"
          @click="updateSetting('is24HourFormat', !settingsStore.settings.is24HourFormat)"
        >
          <div class="switch-handle"></div>
        </div>
      </div>
    </section>

    <!-- Notifications -->
    <section class="settings-section">
      <h2 class="section-title">Notifications</h2>

      <div class="setting-item">
        <div class="setting-info">
          <span class="setting-label">Enable Notifications</span>
          <span class="setting-hint">Receive prayer time notifications</span>
        </div>
        <div
          class="switch"
          :class="{ active: settingsStore.settings.enableNotifications }"
          @click="updateSetting('enableNotifications', !settingsStore.settings.enableNotifications)"
        >
          <div class="switch-handle"></div>
        </div>
      </div>

      <div class="setting-item">
        <div class="setting-info">
          <span class="setting-label">Test Notification</span>
          <span class="setting-hint">Play a beep and show a test notification</span>
        </div>
        <button class="btn btn-glass" @click="audioStore.triggerAlarm('Test Alarm', 'This is a test notification')">
          Test
        </button>
      </div>
    </section>

    <!-- About -->
    <section class="settings-section">
      <h2 class="section-title">About</h2>
      
      <div class="about-info">
        <p class="app-name">🕌 AzanAlarm</p>
        <p class="app-version">Version 1.0.0</p>
        <p class="app-description">
          Accurate Islamic prayer times and customizable Adhan alarms.
        </p>
      </div>
    </section>
  </div>
</template>

<style scoped>
.settings-view {
  max-width: 600px;
  margin: 0 auto;
}

.view-title {
  font-size: 1.75rem;
  font-weight: 300;
  margin-bottom: var(--spacing-lg);
  letter-spacing: -1px;
}

.settings-section {
  margin-bottom: 24px;
  padding: 24px;
  background-color: var(--surface);
  border: 1px solid var(--outline-variant);
  border-radius: 20px;
}

.section-title {
  font-size: 1rem;
  font-weight: 600;
  margin-bottom: 16px;
  padding-bottom: 8px;
  border-bottom: 1px solid var(--outline-variant);
  color: var(--text-primary);
}

.setting-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 12px 0;
}

.setting-info {
  display: flex;
  flex-direction: column;
  gap: 4px;
}

.setting-label {
  font-weight: 500;
  font-size: 0.95rem;
}

.setting-hint {
  font-size: 0.8rem;
  color: var(--text-muted);
}

.select-input {
  background: var(--bg-deep);
  color: var(--text-primary);
  border: 1px solid var(--outline-variant);
  padding: 8px 12px;
  border-radius: 8px;
  min-width: 220px;
}

/* Switch Styles (Replicated from local/component scope as they are not global yet, or to ensure consistency) */
.switch {
  width: 44px;
  height: 24px;
  background: rgba(255, 255, 255, 0.1);
  border-radius: 12px;
  position: relative;
  cursor: pointer;
  transition: all 0.3s ease;
}

.switch.active {
  background: var(--accent);
}

.switch-handle {
  width: 20px;
  height: 20px;
  background: white;
  border-radius: 50%;
  position: absolute;
  top: 2px;
  left: 2px;
  transition: all 0.3s cubic-bezier(0.4, 0.0, 0.2, 1);
  box-shadow: 0 2px 4px rgba(0,0,0,0.2);
}

.switch.active .switch-handle {
  transform: translateX(20px);
}

.about-info {
  text-align: center;
  padding: 12px;
}

.app-name {
  font-size: 1.25rem;
  font-weight: 700;
  margin-bottom: 8px;
}

.app-version {
  font-size: 0.9rem;
  color: var(--text-muted);
  margin-bottom: 8px;
}

.app-description {
  font-size: 0.9rem;
  color: var(--text-muted);
}
</style>
