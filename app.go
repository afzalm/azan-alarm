package main

import (
	"context"
	"fmt"
	"strconv"
	"time"

	"AzanAlarm/internal/models"
	"AzanAlarm/internal/services"
)

// App struct
type App struct {
	ctx context.Context

	// Services
	storage          *services.StorageService
	prayerCalculator *services.PrayerCalculator
	locationService  *services.LocationService
	alarmService     *services.AlarmService
	settingsService  *services.SettingsService
	qiblaService     *services.QiblaService
}

// NewApp creates a new App application struct
func NewApp() *App {
	return &App{}
}

// startup is called when the app starts. The context is saved
// so we can call the runtime methods
func (a *App) startup(ctx context.Context) {
	a.ctx = ctx

	// Initialize services
	var err error
	a.storage, err = services.NewStorageService()
	if err != nil {
		fmt.Println("Error initializing storage:", err)
	}

	a.prayerCalculator = services.NewPrayerCalculator()
	a.locationService = services.NewLocationService(a.storage)
	a.alarmService = services.NewAlarmService(a.storage)
	a.settingsService = services.NewSettingsService(a.storage)
	a.qiblaService = services.NewQiblaService()
}

// ============================================================
// Prayer Times Methods
// ============================================================

// GetPrayerTimes returns prayer times for a specific date
func (a *App) GetPrayerTimes(dateStr string) models.PrayerTimes {
	location := a.locationService.GetCurrentLocation()
	if location == nil {
		return models.PrayerTimes{}
	}

	settings := a.settingsService.GetSettings()

	// Parse date in local timezone
	date, err := time.ParseInLocation("2006-01-02", dateStr, time.Local)
	if err != nil {
		date = time.Now()
	}

	// Get timezone offset
	_, offset := time.Now().Zone()
	timezoneOffset := float64(offset) / 3600.0

	return a.prayerCalculator.Calculate(
		location.Latitude,
		location.Longitude,
		date,
		settings.CalculationMethod,
		settings.JuristicMethod,
		timezoneOffset,
	)
}

// GetTodayPrayerTimes returns prayer times for today
func (a *App) GetTodayPrayerTimes() models.PrayerTimes {
	return a.GetPrayerTimes(time.Now().Format("2006-01-02"))
}

// GetNextPrayer returns the next prayer and time until it
func (a *App) GetNextPrayer() map[string]interface{} {
	times := a.GetTodayPrayerTimes()
	now := time.Now()

	prayers := []struct {
		name string
		time string
	}{
		{"fajr", times.Fajr},
		{"dhuhr", times.Dhuhr},
		{"asr", times.Asr},
		{"maghrib", times.Maghrib},
		{"isha", times.Isha},
	}

	for _, p := range prayers {
		if p.time == "" {
			continue
		}
		prayerTime, err := time.Parse(time.RFC3339, p.time)
		if err != nil {
			continue
		}
		if prayerTime.After(now) {
			remaining := prayerTime.Sub(now)
			return map[string]interface{}{
				"prayer":           p.name,
				"time":             p.time,
				"remainingSeconds": int(remaining.Seconds()),
			}
		}
	}

	// All prayers passed, get tomorrow's Fajr
	tomorrow := time.Now().AddDate(0, 0, 1).Format("2006-01-02")
	tomorrowTimes := a.GetPrayerTimes(tomorrow)
	if tomorrowTimes.Fajr != "" {
		fajrTime, _ := time.Parse(time.RFC3339, tomorrowTimes.Fajr)
		remaining := fajrTime.Sub(now)
		return map[string]interface{}{
			"prayer":           "fajr",
			"time":             tomorrowTimes.Fajr,
			"remainingSeconds": int(remaining.Seconds()),
		}
	}

	return nil
}

// ============================================================
// Location Methods
// ============================================================

// GetCurrentLocation returns the current location
func (a *App) GetCurrentLocation() *models.Location {
	return a.locationService.GetCurrentLocation()
}

// SetCurrentLocation sets the current location
func (a *App) SetCurrentLocation(location models.Location) error {
	return a.locationService.SetCurrentLocation(location)
}

// SearchLocations searches for locations by query
func (a *App) SearchLocations(query string) ([]models.Location, error) {
	return a.locationService.SearchLocations(query)
}

// GetSavedLocations returns all saved locations
func (a *App) GetSavedLocations() []models.Location {
	return a.locationService.GetSavedLocations()
}

// SaveLocation saves a location to favorites
func (a *App) SaveLocation(location models.Location) error {
	return a.locationService.SaveLocation(location)
}

// DeleteLocation removes a saved location
func (a *App) DeleteLocation(id int) error {
	return a.locationService.DeleteLocation(id)
}

// ============================================================
// Alarm Methods
// ============================================================

// GetAlarms returns all alarms
func (a *App) GetAlarms() []models.Alarm {
	return a.alarmService.GetAlarms()
}

// CreateAlarm creates a new alarm
func (a *App) CreateAlarm(alarm models.Alarm) (models.Alarm, error) {
	return a.alarmService.CreateAlarm(alarm)
}

// UpdateAlarm updates an existing alarm
func (a *App) UpdateAlarm(alarm models.Alarm) error {
	return a.alarmService.UpdateAlarm(alarm)
}

// DeleteAlarm removes an alarm
func (a *App) DeleteAlarm(id int) error {
	return a.alarmService.DeleteAlarm(id)
}

// ToggleAlarm toggles the active state of an alarm
func (a *App) ToggleAlarm(id int, active bool) error {
	return a.alarmService.ToggleAlarm(id, active)
}

// ============================================================
// Settings Methods
// ============================================================

// GetSettings returns the current settings
func (a *App) GetSettings() models.AppSettings {
	return a.settingsService.GetSettings()
}

// SaveSettings saves the application settings
func (a *App) SaveSettings(settings models.AppSettings) error {
	return a.settingsService.SaveSettings(settings)
}

// ResetSettingsToDefaults resets settings to defaults
func (a *App) ResetSettingsToDefaults() error {
	return a.settingsService.ResetToDefaults()
}

// ============================================================
// Qibla Methods
// ============================================================

// GetQiblaDirection returns the Qibla direction from current location
func (a *App) GetQiblaDirection() float64 {
	location := a.locationService.GetCurrentLocation()
	if location == nil {
		return 0
	}
	return a.qiblaService.GetQiblaDirection(location.Latitude, location.Longitude)
}

// GetDistanceToMakkah returns distance to Makkah in kilometers
func (a *App) GetDistanceToMakkah() float64 {
	location := a.locationService.GetCurrentLocation()
	if location == nil {
		return 0
	}
	return a.qiblaService.GetDistanceToMakkah(location.Latitude, location.Longitude)
}

// ============================================================
// Utility Methods
// ============================================================

// GetCalculationMethods returns all available calculation methods
func (a *App) GetCalculationMethods() []map[string]string {
	methods := models.AllCalculationMethods()
	result := make([]map[string]string, len(methods))
	for i, m := range methods {
		result[i] = map[string]string{
			"value": string(m),
			"label": m.DisplayName(),
		}
	}
	return result
}

// GetCurrentDate returns the current date formatted
func (a *App) GetCurrentDate() string {
	return time.Now().Format("2006-01-02")
}

// GetCurrentTime returns the current time formatted
func (a *App) GetCurrentTime() string {
	return time.Now().Format("15:04:05")
}

// FormatTime formats a time string according to settings
func (a *App) FormatTime(timeStr string, is24Hour bool) string {
	t, err := time.Parse(time.RFC3339, timeStr)
	if err != nil {
		return timeStr
	}
	if is24Hour {
		return t.Format("15:04")
	}
	return t.Format("3:04 PM")
}

// ParseFloat parses a string to float64
func (a *App) ParseFloat(s string) float64 {
	f, _ := strconv.ParseFloat(s, 64)
	return f
}
