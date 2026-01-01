import { defineStore } from 'pinia'
import { ref, computed } from 'vue'
import {
    GetCurrentLocation,
    SetCurrentLocation,
    SearchLocations,
    GetSavedLocations,
    SaveLocation,
    DeleteLocation,
} from '../../wailsjs/go/main/App'

interface Location {
    id: number
    name: string
    country: string
    latitude: number
    longitude: number
    timezone: string
    isCurrent: boolean
    createdAt: number
}

export const useLocationStore = defineStore('location', () => {
    const currentLocation = ref<Location | null>(null)
    const savedLocations = ref<Location[]>([])
    const searchResults = ref<Location[]>([])
    const loading = ref(false)
    const searchLoading = ref(false)

    const hasCurrentLocation = computed(() => currentLocation.value !== null)

    async function loadCurrentLocation() {
        loading.value = true
        try {
            const location = await GetCurrentLocation()
            currentLocation.value = location as unknown as Location | null
        } catch (error) {
            console.error('Failed to load current location:', error)
        } finally {
            loading.value = false
        }
    }

    async function setCurrentLocation(location: Location) {
        try {
            await SetCurrentLocation(location as any)
            currentLocation.value = { ...location, isCurrent: true }
        } catch (error) {
            console.error('Failed to set current location:', error)
        }
    }

    async function searchLocation(query: string) {
        if (query.length < 2) {
            searchResults.value = []
            return
        }

        searchLoading.value = true
        try {
            const results = await SearchLocations(query)
            searchResults.value = results as unknown as Location[]
        } catch (error) {
            console.error('Failed to search locations:', error)
            searchResults.value = []
        } finally {
            searchLoading.value = false
        }
    }

    async function loadSavedLocations() {
        try {
            const locations = await GetSavedLocations()
            savedLocations.value = locations as unknown as Location[]
        } catch (error) {
            console.error('Failed to load saved locations:', error)
        }
    }

    async function saveLocationToFavorites(location: Location) {
        try {
            await SaveLocation(location as any)
            await loadSavedLocations()
        } catch (error) {
            console.error('Failed to save location:', error)
        }
    }

    async function removeLocation(id: number) {
        try {
            await DeleteLocation(id)
            await loadSavedLocations()
        } catch (error) {
            console.error('Failed to delete location:', error)
        }
    }

    function clearSearchResults() {
        searchResults.value = []
    }

    return {
        currentLocation,
        savedLocations,
        searchResults,
        loading,
        searchLoading,
        hasCurrentLocation,
        loadCurrentLocation,
        setCurrentLocation,
        searchLocation,
        loadSavedLocations,
        saveLocationToFavorites,
        removeLocation,
        clearSearchResults,
    }
})
