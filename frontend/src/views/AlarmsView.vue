<script setup lang="ts">
import { onMounted, ref } from 'vue'
import { useAlarmStore } from '../stores/alarmStore'

const alarmStore = useAlarmStore()

const showCreateDialog = ref(false)
const newAlarm = ref({
  prayer: 'fajr',
  offsetMinutes: 0,
  label: '',
  isActive: true,
  repeatDays: [] as number[],
})

const prayers = [
  { value: 'fajr', label: 'Fajr' },
  { value: 'dhuhr', label: 'Dhuhr' },
  { value: 'asr', label: 'Asr' },
  { value: 'maghrib', label: 'Maghrib' },
  { value: 'isha', label: 'Isha' },
]

const days = [
  { value: 1, label: 'Mon' },
  { value: 2, label: 'Tue' },
  { value: 3, label: 'Wed' },
  { value: 4, label: 'Thu' },
  { value: 5, label: 'Fri' },
  { value: 6, label: 'Sat' },
  { value: 7, label: 'Sun' },
]

onMounted(() => {
  alarmStore.loadAlarms()
})

function openCreateDialog() {
  newAlarm.value = {
    prayer: 'fajr',
    offsetMinutes: 0,
    label: '',
    isActive: true,
    repeatDays: [],
  }
  showCreateDialog.value = true
}

async function createAlarm() {
  await alarmStore.createAlarm(newAlarm.value)
  showCreateDialog.value = false
}

function toggleDay(day: number) {
  const index = newAlarm.value.repeatDays.indexOf(day)
  if (index === -1) {
    newAlarm.value.repeatDays.push(day)
  } else {
    newAlarm.value.repeatDays.splice(index, 1)
  }
}

function getPrayerIcon(prayer: string): string {
  const icons: Record<string, string> = {
    fajr: '🌅',
    dhuhr: '☀️',
    asr: '🌤️',
    maghrib: '🌅',
    isha: '🌙',
  }
  return icons[prayer] || '🕌'
}
</script>

<template>
  <div class="alarms-view">
    <header class="view-header">
      <h1 class="view-title">Alarms</h1>
      <button class="btn btn-accent" @click="openCreateDialog">
        <span class="btn-icon">+</span>
        <span>New Alarm</span>
      </button>
    </header>

    <div class="alarms-list" v-if="alarmStore.alarms.length > 0">
      <div
        v-for="alarm in alarmStore.alarms"
        :key="alarm.id"
        class="alarm-card glass-card"
        :class="{ inactive: !alarm.isActive }"
      >
        <div class="alarm-content">
          <div class="alarm-header">
             <span class="alarm-prayer-name" :style="{ color: `var(--${alarm.prayer}-neon)` }">
               {{ alarm.prayer.charAt(0).toUpperCase() + alarm.prayer.slice(1) }}
             </span>
             <div 
               class="switch"
               :class="{ active: alarm.isActive }"
               @click="alarmStore.toggleAlarm(alarm.id, !alarm.isActive)"
             >
               <div class="switch-handle"></div>
             </div>
          </div>
          
          <div class="alarm-details">
            <span class="alarm-label">{{ alarmStore.getDisplayLabel(alarm) }}</span>
            <span class="alarm-days" v-if="alarm.repeatDays.length > 0">
              Repeats: {{ alarm.repeatDays.length === 7 ? 'Every day' : alarm.repeatDays.length + ' days' }}
            </span>
          </div>
        </div>

        <button 
          class="delete-btn"
          @click="alarmStore.deleteAlarm(alarm.id)"
          title="Delete Alarm"
        >
          🗑️
        </button>
      </div>
    </div>

    <div class="empty-state" v-else>
      <div class="empty-icon-wrapper">⏰</div>
      <p class="empty-text">No active alarms</p>
      <p class="empty-hint">Set notifications for specific prayers</p>
    </div>

    <!-- Create Dialog (Glass Modal) -->
    <div class="dialog-overlay" v-if="showCreateDialog" @click.self="showCreateDialog = false">
      <div class="dialog glass-panel">
        <h2 class="dialog-title">Create Alarm</h2>
        
        <div class="form-group">
          <label class="form-label">Prayer</label>
          <div class="prayer-select-grid">
            <div 
              v-for="p in prayers" 
              :key="p.value"
              class="prayer-option"
              :class="{ selected: newAlarm.prayer === p.value }"
              :style="{ borderColor: newAlarm.prayer === p.value ? `var(--${p.value}-neon)` : 'transparent' }"
              @click="newAlarm.prayer = p.value"
            >
              {{ p.label }}
            </div>
          </div>
        </div>

        <div class="form-group">
          <label class="form-label">Offset (minutes)</label>
          <div class="offset-input-wrapper">
             <input 
              type="number" 
              v-model.number="newAlarm.offsetMinutes"
              class="glass-input"
              placeholder="0"
            />
            <span class="offset-helper">Negative = Before, Positive = After</span>
          </div>
        </div>

        <div class="form-group">
          <label class="form-label">Label</label>
          <input 
            type="text" 
            v-model="newAlarm.label"
            class="glass-input"
            placeholder="e.g., Wake up"
          />
        </div>

        <div class="form-group">
          <label class="form-label">Repeat Days</label>
          <div class="days-grid">
            <button
              v-for="day in days"
              :key="day.value"
              class="day-btn"
              :class="{ active: newAlarm.repeatDays.includes(day.value) }"
              @click="toggleDay(day.value)"
            >
              {{ day.label.charAt(0) }}
            </button>
          </div>
        </div>

        <div class="dialog-actions">
          <button class="btn btn-glass" @click="showCreateDialog = false">Cancel</button>
          <button class="btn btn-accent" @click="createAlarm">Save Alarm</button>
        </div>
      </div>
    </div>
  </div>
</template>

<style scoped>
.alarms-view {
  max-width: 700px;
  margin: 0 auto;
}

.view-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 24px; /* Reduced from var(--spacing-xl) */
}

.view-title {
  font-size: 1.75rem; /* Reduced from 2rem */
  font-weight: 300;
  letter-spacing: -1px;
}

.alarms-list {
  display: flex;
  flex-direction: column;
  gap: 12px; /* Reduced from 16px */
}

.alarm-card {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 16px 20px; /* Reduced from 20px 24px */
  border-radius: 16px; /* Reduced radius */
}

.alarm-content {
  flex: 1;
  display: flex;
  flex-direction: column;
  gap: 4px; /* Reduced from 8px */
}

.alarm-header {
  display: flex;
  align-items: center;
  gap: 12px; /* Reduced gap */
}

.alarm-prayer-name {
  font-size: 1.1rem; /* Reduced size */
  font-weight: 600;
  font-family: var(--font-display);
}

.alarm-label {
  font-size: 0.9rem;
  color: var(--text-primary);
}

.alarm-days {
  font-size: 0.75rem;
  color: var(--text-muted);
  margin-left: 8px;
}

.delete-btn {
  background: rgba(255, 255, 255, 0.05);
  border: none;
  width: 32px; /* Reduced size */
  height: 32px;
  border-radius: 50%;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: all 0.2s;
  font-size: 1rem;
}

.delete-btn:hover {
  background: rgba(239, 68, 68, 0.2);
  color: #EF4444;
}

/* Switch */
.switch {
  width: 36px; /* Reduced size */
  height: 20px;
  background: rgba(255, 255, 255, 0.1);
  border-radius: 10px;
  position: relative;
  cursor: pointer;
  transition: all 0.3s ease;
}

.switch.active {
  background: var(--accent);
}

.switch-handle {
  width: 16px;
  height: 16px;
  background: white;
  border-radius: 50%;
  position: absolute;
  top: 2px;
  left: 2px;
  transition: all 0.3s cubic-bezier(0.4, 0.0, 0.2, 1);
  box-shadow: 0 1px 3px rgba(0,0,0,0.2);
}

.switch.active .switch-handle {
  transform: translateX(16px);
}

/* Empty State */
.empty-state {
  text-align: center;
  padding: 40px 0; /* Reduced padding */
  opacity: 0.6;
}

.empty-icon-wrapper {
  font-size: 3rem; /* Reduced size */
  margin-bottom: 16px;
  opacity: 0.5;
}

.empty-text {
  font-size: 1.1rem;
  font-weight: 500;
}

/* Dialog */
.dialog-overlay {
  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background: rgba(0, 0, 0, 0.8);
  backdrop-filter: blur(4px);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 1000;
}

.dialog {
  width: 90%;
  max-width: 400px; /* Reduced width */
  padding: 24px; /* Reduced padding */
  border-radius: 20px;
  background: #0f172a;
}

.dialog-title {
  font-size: 1.25rem;
  margin-bottom: 20px;
}

.form-group {
  margin-bottom: 16px; /* Reduced margin */
}

.form-label {
  display: block;
  font-size: 0.9rem;
  color: var(--text-secondary);
  margin-bottom: 8px;
}

.prayer-select-grid {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 10px;
}

.prayer-option {
  padding: 10px;
  background: rgba(255, 255, 255, 0.05);
  border: 1px solid transparent;
  border-radius: 12px;
  text-align: center;
  font-size: 0.9rem;
  cursor: pointer;
  transition: all 0.2s;
}

.prayer-option:hover {
  background: rgba(255, 255, 255, 0.1);
}

.prayer-option.selected {
  background: rgba(255, 255, 255, 0.15);
  font-weight: 600;
}

.glass-input {
  width: 100%;
  background: rgba(255, 255, 255, 0.05);
  border: 1px solid rgba(255, 255, 255, 0.1);
  padding: 12px 16px;
  border-radius: 12px;
  color: white;
  font-size: 1rem;
  font-family: var(--font-body);
}

.glass-input:focus {
  outline: none;
  border-color: var(--primary);
  background: rgba(255, 255, 255, 0.1);
}

.offset-helper {
  display: block;
  font-size: 0.75rem;
  color: var(--text-muted);
  margin-top: 6px;
}

.days-grid {
  display: flex;
  justify-content: space-between;
  gap: 4px;
}

.day-btn {
  width: 40px;
  height: 40px;
  border-radius: 50%;
  border: 1px solid rgba(255, 255, 255, 0.1);
  background: transparent;
  color: var(--text-secondary);
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: all 0.2s;
}

.day-btn.active {
  background: var(--primary);
  color: white;
  border-color: var(--primary);
}

.dialog-actions {
  display: flex;
  justify-content: flex-end;
  gap: 12px;
  margin-top: 30px;
}
</style>
