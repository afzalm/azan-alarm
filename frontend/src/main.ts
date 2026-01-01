import { createApp } from 'vue'
import { createPinia } from 'pinia'
import { createRouter, createWebHashHistory } from 'vue-router'
import App from './App.vue'
import './style.css'

// Import views
import HomeView from './views/HomeView.vue'
import AlarmsView from './views/AlarmsView.vue'
import LocationView from './views/LocationView.vue'
import SettingsView from './views/SettingsView.vue'
import QiblaView from './views/QiblaView.vue'

// Create router
const router = createRouter({
  history: createWebHashHistory(),
  routes: [
    { path: '/', name: 'home', component: HomeView },
    { path: '/alarms', name: 'alarms', component: AlarmsView },
    { path: '/location', name: 'location', component: LocationView },
    { path: '/settings', name: 'settings', component: SettingsView },
    { path: '/qibla', name: 'qibla', component: QiblaView },
  ]
})

// Create Pinia store
const pinia = createPinia()

// Create and mount app
const app = createApp(App)
app.use(pinia)
app.use(router)
app.mount('#app')
