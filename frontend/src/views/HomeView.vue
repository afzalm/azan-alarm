<script setup lang="ts">
import { onMounted, onUnmounted, computed } from 'vue'
import { usePrayerStore } from '../stores/prayerStore'
import { useLocationStore } from '../stores/locationStore'
import { useRouter } from 'vue-router'

const router = useRouter()
const prayerStore = usePrayerStore()
const locationStore = useLocationStore()

const currentDate = computed(() => {
  return new Date().toLocaleDateString('en-US', {
    weekday: 'long',
    year: 'numeric',
    month: 'long',
    day: 'numeric',
  })
})

onMounted(async () => {
  await locationStore.loadCurrentLocation()
  await prayerStore.loadTodayPrayerTimes()
  await prayerStore.loadNextPrayer()
  prayerStore.startCountdown()
})

onUnmounted(() => {
  prayerStore.stopCountdown()
})

function getPrayerColorClass(key: string): string {
  return `prayer-${key}`
}
</script>

<template>
  <div class="home-view">
    <!-- Header -->
    <header class="header">
      <div class="location-badge glass-panel" v-if="locationStore.currentLocation" @click="router.push('/location')">
        <span class="location-icon">📍</span>
        <span class="location-name">{{ locationStore.currentLocation.name }}</span>
      </div>
      <div class="location-badge glass-panel" v-else @click="router.push('/location')">
        <span class="location-icon">📍</span>
        <span class="location-name">Set Location</span>
      </div>
      <div class="date-badge glass-panel">{{ currentDate }}</div>
    </header>

    <!-- Hero Countdown -->
    <section class="hero-section" v-if="prayerStore.nextPrayer">
      <div class="countdown-circle">
        <div class="glow-ring" :style="{ borderColor: `var(--${prayerStore.nextPrayer.prayer}-neon)` }"></div>
        <div class="countdown-content">
          <div class="next-label">UP NEXT</div>
          <div class="next-prayer-name text-gradient">{{ prayerStore.nextPrayer.prayer }}</div>
          <div class="countdown-timer">{{ prayerStore.countdown }}</div>
          <div class="remaining-label">REMAINING</div>
        </div>
      </div>
    </section>

    <!-- Visual Timeline -->
    <section class="timeline-section glass-panel">
      <div class="timeline-container">
        <div class="timeline-line"></div>
        <div 
          v-for="prayer in prayerStore.prayerList" 
          :key="prayer.key"
          class="timeline-item"
          :class="{ 'active': prayer.isNext, 'passed': prayer.hasPassed && !prayer.isNext }"
        >
          <div class="timeline-node" :style="{ 
            backgroundColor: prayer.isNext ? `var(--${prayer.key}-neon)` : (prayer.hasPassed ? 'rgba(255,255,255,0.2)' : 'rgba(255,255,255,0.1)'),
            boxShadow: prayer.isNext ? `0 0 15px var(--${prayer.key}-neon)` : 'none'
          }">
            <span class="node-icon">{{ prayer.icon }}</span>
          </div>
          <div class="timeline-content">
            <span class="timeline-time">{{ prayer.formattedTime }}</span>
            <span class="timeline-name" :class="{ 'highlight': prayer.isNext }">{{ prayer.name }}</span>
          </div>
        </div>
      </div>
    </section>

    <!-- Quick Actions -->
    <section class="quick-actions">
      <button class="action-card glass-card" @click="router.push('/alarms')">
        <span class="action-icon">⏰</span>
        <span class="action-label">Alarms</span>
      </button>
      <button class="action-card glass-card" @click="router.push('/qibla')">
        <span class="action-icon">🧭</span>
        <span class="action-label">Qibla</span>
      </button>
      <button class="action-card glass-card" @click="router.push('/settings')">
        <span class="action-icon">⚙️</span>
        <span class="action-label">Settings</span>
      </button>
    </section>
  </div>
</template>

<style scoped>
.home-view {
  max-width: 800px;
  margin: 0 auto;
  display: flex;
  flex-direction: column;
  gap: 24px; /* Reduced from var(--spacing-xl) */
  height: 100%;
}

.header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.location-badge, .date-badge {
  padding: 6px 12px; /* Reduced padding */
  border-radius: 16px;
  display: flex;
  align-items: center;
  gap: 6px;
  font-size: 0.85rem;
  color: var(--text-secondary);
  cursor: pointer;
  transition: all 0.3s ease;
}

.location-badge:hover {
  background: rgba(255, 255, 255, 0.1);
  color: white;
}

.location-name {
  font-weight: 500;
}

/* Hero Section */
.hero-section {
  display: flex;
  justify-content: center;
  padding: 10px 0; /* Reduced padding */
}

.countdown-circle {
  position: relative;
  width: 260px; /* Reduced from 320px */
  height: 260px; /* Reduced from 320px */
  display: flex;
  align-items: center;
  justify-content: center;
}

.glow-ring {
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  border-radius: 50%;
  border: 3px solid transparent;
  box-shadow: 0 0 30px rgba(0,0,0,0.5);
  animation: pulse-glow 3s infinite ease-in-out;
}

@keyframes pulse-glow {
  0% { box-shadow: 0 0 15px currentColor, inset 0 0 15px currentColor; opacity: 0.5; }
  50% { box-shadow: 0 0 30px currentColor, inset 0 0 30px currentColor; opacity: 0.8; }
  100% { box-shadow: 0 0 15px currentColor, inset 0 0 15px currentColor; opacity: 0.5; }
}

.countdown-content {
  text-align: center;
  z-index: 2;
  display: flex;
  flex-direction: column;
  align-items: center;
}

.next-label, .remaining-label {
  font-size: 0.75rem;
  letter-spacing: 2px;
  color: var(--text-muted);
  font-weight: 600;
}

.next-prayer-name {
  font-size: 2.5rem; /* Reduced from 3.5rem */
  font-weight: 200;
  font-family: var(--font-display);
  margin: 4px 0;
  text-transform: capitalize;
}

.countdown-timer {
  font-size: 3rem; /* Reduced from 4rem */
  font-weight: 700;
  font-family: 'Courier New', monospace;
  letter-spacing: -2px;
  background: linear-gradient(to bottom, white, #94a3b8);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  line-height: 1;
  margin-bottom: 8px;
}

/* Timeline */
.timeline-section {
  padding: 20px; /* Reduced padding */
  border-radius: 20px;
}

.timeline-container {
  display: flex;
  justify-content: space-between;
  align-items: center;
  position: relative;
  padding: 0 10px;
}

.timeline-line {
  position: absolute;
  top: 50%;
  left: 30px;
  right: 30px;
  height: 2px;
  background: rgba(255, 255, 255, 0.1);
  z-index: 1;
}

.timeline-item {
  position: relative;
  z-index: 2;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 8px; /* Reduced gap */
  cursor: default;
}

.timeline-node {
  width: 32px; /* Reduced size */
  height: 32px;
  border-radius: 50%;
  border: 2px solid rgba(255, 255, 255, 0.1);
  display: flex;
  align-items: center;
  justify-content: center;
  background: var(--bg-deep);
  transition: all 0.3s cubic-bezier(0.34, 1.56, 0.64, 1);
}

.timeline-item.active .timeline-node {
  transform: scale(1.2);
  border-color: white;
}

.node-icon {
  font-size: 1rem;
}

.timeline-content {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 2px;
}

.timeline-name {
  font-size: 0.75rem;
  color: var(--text-muted);
  font-weight: 500;
}

.timeline-name.highlight {
  color: white;
  font-weight: 600;
}

.timeline-time {
  font-size: 0.95rem;
  font-weight: 600;
  color: var(--text-secondary);
}

.timeline-item.active .timeline-time {
  color: white;
}

/* Quick Actions */
.quick-actions {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 16px; /* Reduced gap */
}

.action-card {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 8px;
  padding: 16px; /* Reduced padding */
  border-radius: 16px;
  color: white;
  cursor: pointer;
  border: 1px solid rgba(255,255,255,0.1);
}

.action-icon {
  font-size: 1.5rem; /* Reduced size */
  filter: drop-shadow(0 0 10px rgba(255,255,255,0.2));
}

.action-label {
  font-size: 0.85rem;
  font-weight: 500;
  letter-spacing: 0.5px;
}
</style>
