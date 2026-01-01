// Package services contains business logic for the AzanAlarm application.
package services

import (
	"AzanAlarm/internal/models"
)

// SettingsService handles application settings.
type SettingsService struct {
	storage  *StorageService
	settings models.AppSettings
}

// NewSettingsService creates a new SettingsService instance.
func NewSettingsService(storage *StorageService) *SettingsService {
	ss := &SettingsService{
		storage:  storage,
		settings: models.DefaultSettings(),
	}

	// Load existing settings
	var savedSettings models.AppSettings
	if err := storage.Load("settings", &savedSettings); err == nil {
		ss.settings = savedSettings
	}

	return ss
}

// GetSettings returns the current application settings.
func (ss *SettingsService) GetSettings() models.AppSettings {
	return ss.settings
}

// SaveSettings saves the application settings.
func (ss *SettingsService) SaveSettings(settings models.AppSettings) error {
	ss.settings = settings
	return ss.storage.Save("settings", settings)
}

// ResetToDefaults resets settings to default values.
func (ss *SettingsService) ResetToDefaults() error {
	ss.settings = models.DefaultSettings()
	return ss.storage.Save("settings", ss.settings)
}

// UpdateCalculationMethod updates only the calculation method.
func (ss *SettingsService) UpdateCalculationMethod(method models.PrayerCalculationMethod) error {
	ss.settings.CalculationMethod = method
	return ss.storage.Save("settings", ss.settings)
}

// UpdateJuristicMethod updates only the juristic method.
func (ss *SettingsService) UpdateJuristicMethod(method models.JuristicMethod) error {
	ss.settings.JuristicMethod = method
	return ss.storage.Save("settings", ss.settings)
}

// UpdateTheme updates the application theme.
func (ss *SettingsService) UpdateTheme(theme models.AppTheme) error {
	ss.settings.Theme = theme
	return ss.storage.Save("settings", ss.settings)
}

// ToggleNotifications toggles notification enabling.
func (ss *SettingsService) ToggleNotifications(enable bool) error {
	ss.settings.EnableNotifications = enable
	return ss.storage.Save("settings", ss.settings)
}

// Toggle24HourFormat toggles between 12h and 24h time format.
func (ss *SettingsService) Toggle24HourFormat(enable bool) error {
	ss.settings.Is24HourFormat = enable
	return ss.storage.Save("settings", ss.settings)
}
