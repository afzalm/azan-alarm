// Package models contains data model definitions for the AzanAlarm application.
package models

// AppTheme represents the application theme options.
type AppTheme string

const (
	ThemeLight  AppTheme = "light"
	ThemeDark   AppTheme = "dark"
	ThemeSystem AppTheme = "system"
)

// AppSettings represents the application settings.
type AppSettings struct {
	CalculationMethod   PrayerCalculationMethod `json:"calculationMethod"`
	JuristicMethod      JuristicMethod          `json:"juristicMethod"`
	AudioTheme          string                  `json:"audioTheme"`
	Is24HourFormat      bool                    `json:"is24HourFormat"`
	EnableNotifications bool                    `json:"enableNotifications"`
	EnableVibration     bool                    `json:"enableVibration"`
	Theme               AppTheme                `json:"theme"`
	Language            string                  `json:"language"`
}

// DefaultSettings returns the default application settings.
func DefaultSettings() AppSettings {
	return AppSettings{
		CalculationMethod:   MuslimWorldLeague,
		JuristicMethod:      Shafii,
		AudioTheme:          "default",
		Is24HourFormat:      false,
		EnableNotifications: true,
		EnableVibration:     true,
		Theme:               ThemeSystem,
		Language:            "en",
	}
}
