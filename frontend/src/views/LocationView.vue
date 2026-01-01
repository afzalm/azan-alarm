<script setup lang="ts">
import { onMounted, ref } from 'vue'
import { useLocationStore } from '../stores/locationStore'

const locationStore = useLocationStore()
const searchQuery = ref('')
const searchTimeout = ref<number | null>(null)

onMounted(async () => {
  await locationStore.loadCurrentLocation()
  await locationStore.loadSavedLocations()
})

function debounceSearch(query: string) {
  if (searchTimeout.value) {
    clearTimeout(searchTimeout.value)
  }
  searchTimeout.value = window.setTimeout(() => {
    locationStore.searchLocation(query)
  }, 300)
}

function handleSearchInput() {
  debounceSearch(searchQuery.value)
}

async function selectLocation(location: any) {
  await locationStore.setCurrentLocation(location)
  await locationStore.saveLocationToFavorites(location)
  searchQuery.value = ''
  locationStore.clearSearchResults()
}
</script>

<template>
  <div class="location-view">
    <h1 class="view-title">Location</h1>

    <!-- Current Location -->
    <section class="current-location" v-if="locationStore.currentLocation">
      <h2 class="section-title">Current Location</h2>
      <div class="location-card current">
        <span class="location-icon">📍</span>
        <div class="location-info">
          <span class="location-name">{{ locationStore.currentLocation.name }}</span>
          <span class="location-country">{{ locationStore.currentLocation.country }}</span>
        </div>
        <span class="current-badge">Active</span>
      </div>
    </section>

    <!-- Search -->
    <section class="search-section">
      <h2 class="section-title">Search Location</h2>
      <input
        type="text"
        v-model="searchQuery"
        @input="handleSearchInput"
        class="glass-input"
        placeholder="Search for a city..."
      />

      <div class="search-results" v-if="locationStore.searchResults.length > 0">
        <div
          v-for="(location, index) in locationStore.searchResults"
          :key="index"
          class="location-card clickable"
          @click="selectLocation(location)"
        >
          <span class="location-icon">🌍</span>
          <div class="location-info">
            <span class="location-name">{{ location.name }}</span>
            <span class="location-country">{{ location.country }}</span>
          </div>
        </div>
      </div>

      <div class="search-loading" v-if="locationStore.searchLoading">
        <span class="animate-pulse">Searching...</span>
      </div>
    </section>

    <!-- Saved Locations -->
    <section class="saved-locations" v-if="locationStore.savedLocations.length > 0">
      <h2 class="section-title">Saved Locations</h2>
      <div class="locations-list">
        <div
          v-for="location in locationStore.savedLocations"
          :key="location.id"
          class="location-card"
          :class="{ current: location.isCurrent }"
        >
          <span class="location-icon">⭐</span>
          <div class="location-info">
            <span class="location-name">{{ location.name }}</span>
            <span class="location-country">{{ location.country }}</span>
          </div>
          <div class="location-actions">
            <button
              class="btn btn-glass"
              @click="locationStore.setCurrentLocation(location)"
              v-if="!location.isCurrent"
            >
              Use
            </button>
            <button
              class="delete-btn"
              @click="locationStore.removeLocation(location.id)"
            >🗑️</button>
          </div>
        </div>
      </div>
    </section>
  </div>
</template>

<style scoped>
.location-view {
  max-width: 700px;
  margin: 0 auto;
}

.view-title {
  font-size: 1.75rem;
  font-weight: 300;
  margin-bottom: 24px;
  letter-spacing: -1px;
}

.section-title {
  font-size: 1rem;
  font-weight: 600;
  margin-bottom: 16px;
  padding-bottom: 8px;
  border-bottom: 1px solid var(--outline-variant);
  color: var(--text-primary);
}

section {
  margin-bottom: 32px;
}

.location-card {
  display: flex;
  align-items: center;
  gap: 16px;
  padding: 16px 20px;
  background-color: rgba(255, 255, 255, 0.03);
  border: 1px solid rgba(255, 255, 255, 0.1);
  border-radius: 16px;
  transition: all 0.3s ease;
}

.location-card.clickable {
  cursor: pointer;
}

.location-card.clickable:hover {
  background: rgba(255, 255, 255, 0.08);
  border-color: rgba(255, 255, 255, 0.2);
  transform: translateY(-2px);
}

.location-card.current {
  background: rgba(139, 92, 246, 0.1); /* Primary glow */
  border-color: rgba(139, 92, 246, 0.3);
}

.location-icon {
  font-size: 1.5rem;
  filter: drop-shadow(0 0 5px rgba(255, 255, 255, 0.2));
}

.location-info {
  flex: 1;
  display: flex;
  flex-direction: column;
  gap: 2px;
}

.location-name {
  font-weight: 600;
  font-size: 1.05rem;
}

.location-country {
  font-size: 0.85rem;
  color: var(--text-muted);
}

.current-badge {
  background-color: var(--primary);
  color: white;
  padding: 4px 10px;
  border-radius: 20px;
  font-size: 0.75rem;
  font-weight: 600;
  box-shadow: 0 0 10px rgba(139, 92, 246, 0.4);
}

/* Search Input Styling */
.glass-input {
  width: 100%;
  background: rgba(255, 255, 255, 0.05);
  border: 1px solid rgba(255, 255, 255, 0.1);
  padding: 14px 20px;
  border-radius: 16px;
  color: white;
  font-size: 1.1rem;
  font-family: var(--font-body);
  transition: all 0.3s ease;
}

.glass-input:focus {
  outline: none;
  border-color: var(--primary);
  background: rgba(255, 255, 255, 0.1);
  box-shadow: 0 0 20px rgba(139, 92, 246, 0.15);
}

.search-results {
  margin-top: 16px;
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.search-loading {
  margin-top: 16px;
  color: var(--text-muted);
  text-align: center;
  font-size: 0.9rem;
}

.locations-list {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.location-actions {
  display: flex;
  align-items: center;
  gap: 8px;
}

.delete-btn {
  background: rgba(255, 255, 255, 0.05);
  border: none;
  width: 32px;
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
</style>
