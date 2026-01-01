<script setup lang="ts">
import { onMounted, ref, computed } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { useSettingsStore } from './stores/settingsStore'
import { useAudioStore } from './stores/audioStore'

const router = useRouter()
const route = useRoute()
const settingsStore = useSettingsStore()
const audioStore = useAudioStore()

// Navigation items
const navItems = [
  { path: '/', icon: '🏠', label: 'Home' },
  { path: '/alarms', icon: '⏰', label: 'Alarms' },
  { path: '/location', icon: '📍', label: 'Location' },
  { path: '/qibla', icon: '🧭', label: 'Qibla' },
  { path: '/settings', icon: '⚙️', label: 'Settings' },
]

const currentPath = computed(() => route.path)

onMounted(async () => {
  await settingsStore.loadSettings()
  audioStore.init()
})
</script>

<template>
  <div class="app-container">
    <!-- Sidebar Navigation (Floating Glass) -->
    <nav class="sidebar glass-panel">
      <div class="sidebar-header">
        <h1 class="app-title">
          <span class="icon">🕌</span>
          <span class="text">Azan</span><span class="text-highlight">Alarm</span>
        </h1>
      </div>
      
      <div class="nav-items">
        <router-link
          v-for="item in navItems"
          :key="item.path"
          :to="item.path"
          class="nav-item"
          :class="{ active: currentPath === item.path }"
        >
          <span class="nav-icon">{{ item.icon }}</span>
          <span class="nav-label">{{ item.label }}</span>
          <div class="active-indicator" v-if="currentPath === item.path"></div>
        </router-link>
      </div>
      
      <div class="sidebar-footer">
        <span class="version">v1.0.0</span>
      </div>
    </nav>
    
    <!-- Main Content -->
    <main class="main-content">
      <router-view v-slot="{ Component }">
        <transition name="fade" mode="out-in">
          <component :is="Component" />
        </transition>
      </router-view>
    </main>

    <!-- Global Audio Stop Button (Floating) -->
    <transition name="fade">
      <div v-if="audioStore.isPlaying" class="audio-overlay">
        <div class="audio-controls glass-panel">
          <div class="audio-info">
            <span class="audio-icon">🔊</span>
            <span class="audio-label">Adhan Playing</span>
          </div>
          <button class="btn btn-accent" @click="audioStore.stopAudio()">
            Stop Audio
          </button>
        </div>
      </div>
    </transition>
  </div>
</template>

<style scoped>
.app-container {
  display: flex;
  width: 100%;
  height: 100vh;
  padding: var(--spacing-md);
  gap: var(--spacing-md);
}

.sidebar {
  width: 260px;
  min-width: 260px;
  border-radius: 24px;
  display: flex;
  flex-direction: column;
  padding: var(--spacing-lg);
  gap: var(--spacing-xl);
}

.sidebar-header {
  padding-bottom: var(--spacing-md);
  border-bottom: 1px solid rgba(255, 255, 255, 0.05);
}

.app-title {
  display: flex;
  align-items: center;
  gap: 12px;
  font-size: 1.5rem;
  letter-spacing: -0.5px;
}

.app-title .icon {
  font-size: 1.8rem;
  filter: drop-shadow(0 0 10px rgba(245, 158, 11, 0.3));
}

.text-highlight {
  color: var(--accent);
  font-weight: 600;
}

.nav-items {
  display: flex;
  flex-direction: column;
  gap: 8px;
  flex: 1;
}

.nav-item {
  position: relative;
  display: flex;
  align-items: center;
  gap: 16px;
  padding: 12px 16px;
  border-radius: 12px;
  color: var(--text-secondary);
  text-decoration: none;
  transition: all 0.3s ease;
  overflow: hidden;
}

.nav-item:hover {
  background: rgba(255, 255, 255, 0.05);
  color: white;
}

.nav-item.active {
  background: linear-gradient(90deg, rgba(139, 92, 246, 0.2), transparent);
  color: white;
  font-weight: 500;
}

.active-indicator {
  position: absolute;
  left: 0;
  top: 50%;
  transform: translateY(-50%);
  width: 3px;
  height: 60%;
  background: var(--accent);
  border-radius: 0 4px 4px 0;
  box-shadow: 0 0 10px var(--accent);
}

.nav-icon {
  font-size: 1.25rem;
  min-width: 24px;
  text-align: center;
}

.nav-label {
  font-size: 0.95rem;
  font-weight: 400;
  font-family: var(--font-display);
}

.sidebar-footer {
  text-align: center;
  opacity: 0.3;
  font-size: 0.75rem;
  font-family: monospace;
}

.main-content {
  flex: 1;
  overflow-y: auto;
  /* Transparent background to show global gradient */
  border-radius: 24px;
}

/* Custom Scrollbar for Main Content */
.main-content::-webkit-scrollbar {
  width: 6px;
}
.main-content::-webkit-scrollbar-thumb {
  background: rgba(255, 255, 255, 0.1);
  border-radius: 3px;
}

/* Audio Overlay */
.audio-overlay {
  position: absolute;
  top: 20px;
  right: 20px;
  z-index: 1000;
}

.audio-controls {
  display: flex;
  align-items: center;
  gap: 16px;
  padding: 12px 16px;
  border-radius: 16px;
  border: 1px solid rgba(245, 158, 11, 0.3); /* Gold border for attention */
  box-shadow: 0 4px 20px rgba(0,0,0,0.4);
}

.audio-info {
  display: flex;
  align-items: center;
  gap: 8px;
}

.audio-icon {
  font-size: 1.2rem;
  animation: pulse 1s infinite;
}

.audio-label {
  font-weight: 600;
  font-size: 0.9rem;
}

@keyframes pulse {
  0% { transform: scale(1); }
  50% { transform: scale(1.2); }
  100% { transform: scale(1); }
}
</style>
