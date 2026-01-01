<script setup lang="ts">
import { onMounted, ref, computed } from 'vue'
import { GetQiblaDirection, GetDistanceToMakkah } from '../../wailsjs/go/main/App'
import { useLocationStore } from '../stores/locationStore'

const locationStore = useLocationStore()
const qiblaDirection = ref(0)
const distanceToMakkah = ref(0)
const loading = ref(false)

onMounted(async () => {
  loading.value = true
  await locationStore.loadCurrentLocation()
  
  try {
    qiblaDirection.value = await GetQiblaDirection()
    distanceToMakkah.value = await GetDistanceToMakkah()
  } catch (error) {
    console.error('Failed to get Qibla direction:', error)
  } finally {
    loading.value = false
  }
})

const formattedDistance = computed(() => {
  if (distanceToMakkah.value > 1000) {
    return `${(distanceToMakkah.value / 1000).toFixed(0)} km`
  }
  return `${distanceToMakkah.value.toFixed(0)} km`
})

const formattedDirection = computed(() => {
  return `${qiblaDirection.value.toFixed(1)}°`
})

const compassStyle = computed(() => {
  return {
    transform: `rotate(${qiblaDirection.value}deg)`
  }
})
</script>

<template>
  <div class="qibla-view">
    <h1 class="view-title">Qibla Direction</h1>

    <div class="qibla-container" v-if="locationStore.currentLocation">
      <!-- Compass -->
      <div class="compass-container">
        <div class="compass">
          <div class="compass-ring">
            <span class="direction north">N</span>
            <span class="direction east">E</span>
            <span class="direction south">S</span>
            <span class="direction west">W</span>
          </div>
          <div class="compass-needle" :style="compassStyle">
            <div class="needle-tip">🕋</div>
          </div>
          <div class="compass-center"></div>
        </div>
      </div>

      <!-- Info -->
      <div class="qibla-info">
        <div class="info-card">
          <span class="info-label">Direction</span>
          <span class="info-value">{{ formattedDirection }}</span>
        </div>
        <div class="info-card">
          <span class="info-label">Distance to Makkah</span>
          <span class="info-value">{{ formattedDistance }}</span>
        </div>
      </div>

      <div class="location-display">
        <span class="location-icon">📍</span>
        <span>{{ locationStore.currentLocation.name }}, {{ locationStore.currentLocation.country }}</span>
      </div>

      <p class="qibla-hint">
        The arrow points to the direction of the Kaaba in Makkah from your current location.
      </p>
    </div>

    <div class="no-location" v-else>
      <span class="no-location-icon">📍</span>
      <p>Please set your location first to see the Qibla direction.</p>
      <router-link to="/location" class="btn btn-primary">Set Location</router-link>
    </div>
  </div>
</template>

<style scoped>
.qibla-view {
  max-width: 600px;
  margin: 0 auto;
  text-align: center;
}

.view-title {
  font-size: 1.75rem;
  font-weight: 300;
  margin-bottom: 32px;
  letter-spacing: -1px;
}

.qibla-container {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 32px;
}

/* Compass */
.compass-container {
  padding: 20px;
  position: relative;
}

.compass {
  position: relative;
  width: 300px;
  height: 300px;
  border-radius: 50%;
  background: radial-gradient(circle at center, rgba(15, 23, 42, 0.8), rgba(2, 6, 23, 0.9));
  border: 1px solid rgba(255, 255, 255, 0.1);
  box-shadow: 
    0 0 50px rgba(139, 92, 246, 0.1),
    inset 0 0 20px rgba(0, 0, 0, 0.5);
  display: flex;
  align-items: center;
  justify-content: center;
}

.compass-ring {
  position: absolute;
  width: 100%;
  height: 100%;
  border-radius: 50%;
  border: 1px solid rgba(255, 255, 255, 0.05);
}

.direction {
  position: absolute;
  font-family: var(--font-display);
  font-weight: 600;
  font-size: 1.1rem;
  color: var(--text-muted);
}

.direction.north {
  top: 15px;
  left: 50%;
  transform: translateX(-50%);
  color: #EF4444; /* Red for North */
  text-shadow: 0 0 10px rgba(239, 68, 68, 0.4);
}

.direction.south {
  bottom: 15px;
  left: 50%;
  transform: translateX(-50%);
}

.direction.east {
  right: 15px;
  top: 50%;
  transform: translateY(-50%);
}

.direction.west {
  left: 15px;
  top: 50%;
  transform: translateY(-50%);
}

.compass-needle {
  position: absolute;
  width: 80px;
  height: 220px; /* Reduced to fit better */
  display: flex;
  justify-content: center;
  transition: transform 0.8s cubic-bezier(0.4, 0, 0.2, 1);
  /* Pivot from center */
  transform-origin: center center;
  align-items: flex-start; /* Tip at top */
  padding-top: 10px;
}

.needle-tip {
  font-size: 2.5rem;
  filter: drop-shadow(0 0 15px rgba(245, 158, 11, 0.5));
  animation: float 3s ease-in-out infinite;
}

@keyframes float {
  0%, 100% { transform: translateY(0); }
  50% { transform: translateY(-5px); }
}

.compass-center {
  width: 16px;
  height: 16px;
  background: var(--accent);
  border-radius: 50%;
  box-shadow: 0 0 15px var(--accent);
  z-index: 10;
}

/* Info Cards */
.qibla-info {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 16px;
  width: 100%;
}

.info-card {
  background: rgba(255, 255, 255, 0.03);
  padding: 20px;
  border-radius: 20px;
  border: 1px solid rgba(255, 255, 255, 0.05);
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 8px;
  transition: margin 0.3s ease;
}

.info-card:hover {
  background: rgba(255, 255, 255, 0.05);
  border-color: rgba(255, 255, 255, 0.1);
}

.info-label {
  font-size: 0.85rem;
  color: var(--text-muted);
  text-transform: uppercase;
  letter-spacing: 1px;
}

.info-value {
  font-size: 1.5rem;
  font-weight: 700;
  color: var(--text-primary);
  font-variant-numeric: tabular-nums;
}

.location-display {
  display: flex;
  align-items: center;
  gap: 8px;
  color: var(--text-secondary);
  font-size: 0.9rem;
  background: rgba(255, 255, 255, 0.03);
  padding: 8px 16px;
  border-radius: 50px;
}

.qibla-hint {
  font-size: 0.85rem;
  color: var(--text-muted);
  max-width: 320px;
  line-height: 1.5;
}

/* No Location */
.no-location {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 24px;
  padding: 48px;
  background: rgba(255, 255, 255, 0.02);
  border-radius: 24px;
  border: 1px dashed rgba(255, 255, 255, 0.1);
}

.no-location-icon {
  font-size: 4rem;
  opacity: 0.5;
}
</style>
