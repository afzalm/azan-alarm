// Package models contains data model definitions for the AzanAlarm application.
package models

// Prayer represents the five daily prayers.
type Prayer string

const (
	Fajr    Prayer = "fajr"
	Dhuhr   Prayer = "dhuhr"
	Asr     Prayer = "asr"
	Maghrib Prayer = "maghrib"
	Isha    Prayer = "isha"
)

// AllPrayers returns a slice of all prayer types in order.
func AllPrayers() []Prayer {
	return []Prayer{Fajr, Dhuhr, Asr, Maghrib, Isha}
}

// DisplayName returns the human-readable name for the prayer.
func (p Prayer) DisplayName() string {
	switch p {
	case Fajr:
		return "Fajr"
	case Dhuhr:
		return "Dhuhr"
	case Asr:
		return "Asr"
	case Maghrib:
		return "Maghrib"
	case Isha:
		return "Isha"
	default:
		return string(p)
	}
}

// PrayerCalculationMethod represents different calculation methods for prayer times.
type PrayerCalculationMethod string

const (
	MuslimWorldLeague     PrayerCalculationMethod = "muslim_world_league"
	ISNA                  PrayerCalculationMethod = "isna"
	Egyptian              PrayerCalculationMethod = "egyptian"
	UmmAlQura             PrayerCalculationMethod = "umm_al_qura"
	Karachi               PrayerCalculationMethod = "karachi"
	Tehran                PrayerCalculationMethod = "tehran"
	Jafari                PrayerCalculationMethod = "jafari"
	Gulf                  PrayerCalculationMethod = "gulf"
	MoonsightingCommittee PrayerCalculationMethod = "moonsighting_committee"
	NorthAmerica          PrayerCalculationMethod = "north_america"
	Other                 PrayerCalculationMethod = "other"
)

// AllCalculationMethods returns all available calculation methods.
func AllCalculationMethods() []PrayerCalculationMethod {
	return []PrayerCalculationMethod{
		MuslimWorldLeague,
		ISNA,
		Egyptian,
		UmmAlQura,
		Karachi,
		Tehran,
		Jafari,
		Gulf,
		MoonsightingCommittee,
		NorthAmerica,
	}
}

// DisplayName returns a human-readable name for the calculation method.
func (m PrayerCalculationMethod) DisplayName() string {
	switch m {
	case MuslimWorldLeague:
		return "Muslim World League"
	case ISNA:
		return "Islamic Society of North America (ISNA)"
	case Egyptian:
		return "Egyptian General Authority"
	case UmmAlQura:
		return "Umm Al-Qura (Makkah)"
	case Karachi:
		return "University of Karachi"
	case Tehran:
		return "Institute of Geophysics, Tehran"
	case Jafari:
		return "Shia Ithna-Ashari (Jafari)"
	case Gulf:
		return "Gulf Region"
	case MoonsightingCommittee:
		return "Moonsighting Committee"
	case NorthAmerica:
		return "North America (ISNA)"
	default:
		return string(m)
	}
}

// JuristicMethod represents the method for calculating Asr prayer time.
type JuristicMethod string

const (
	Shafii JuristicMethod = "shafii" // Standard: shadow = object length
	Hanafi JuristicMethod = "hanafi" // Shadow = 2x object length
)

// DisplayName returns a human-readable name for the juristic method.
func (m JuristicMethod) DisplayName() string {
	switch m {
	case Shafii:
		return "Shafi'i, Maliki, Hanbali"
	case Hanafi:
		return "Hanafi"
	default:
		return string(m)
	}
}

// CalculationParams holds the parameters for a specific calculation method.
type CalculationParams struct {
	FajrAngle       float64 // Sun angle for Fajr
	IshaAngle       float64 // Sun angle for Isha
	IshaInterval    int     // Minutes after Maghrib for Isha (0 if using angle)
	MaghribAngle    float64 // Sun angle for Maghrib (0 for standard sunset)
	MaghribInterval int     // Minutes after sunset for Maghrib (0 if using angle)
}

// GetCalculationParams returns the calculation parameters for a given method.
func GetCalculationParams(method PrayerCalculationMethod) CalculationParams {
	switch method {
	case MuslimWorldLeague:
		return CalculationParams{FajrAngle: 18.0, IshaAngle: 17.0}
	case ISNA, NorthAmerica:
		return CalculationParams{FajrAngle: 15.0, IshaAngle: 15.0}
	case Egyptian:
		return CalculationParams{FajrAngle: 19.5, IshaAngle: 17.5}
	case UmmAlQura:
		return CalculationParams{FajrAngle: 18.5, IshaInterval: 90}
	case Karachi:
		return CalculationParams{FajrAngle: 18.0, IshaAngle: 18.0}
	case Tehran:
		return CalculationParams{FajrAngle: 17.7, IshaAngle: 14.0, MaghribAngle: 4.5}
	case Jafari:
		return CalculationParams{FajrAngle: 16.0, IshaAngle: 14.0, MaghribAngle: 4.0}
	case Gulf:
		return CalculationParams{FajrAngle: 19.5, IshaInterval: 90}
	case MoonsightingCommittee:
		return CalculationParams{FajrAngle: 18.0, IshaAngle: 18.0}
	default:
		return CalculationParams{FajrAngle: 18.0, IshaAngle: 17.0}
	}
}

// PrayerTimes represents the prayer times for a specific day.
type PrayerTimes struct {
	Fajr    string `json:"fajr"`    // ISO 8601 time string
	Dhuhr   string `json:"dhuhr"`   // ISO 8601 time string
	Asr     string `json:"asr"`     // ISO 8601 time string
	Maghrib string `json:"maghrib"` // ISO 8601 time string
	Isha    string `json:"isha"`    // ISO 8601 time string
}

// GetTime returns the prayer time for a specific prayer.
func (pt *PrayerTimes) GetTime(prayer Prayer) string {
	switch prayer {
	case Fajr:
		return pt.Fajr
	case Dhuhr:
		return pt.Dhuhr
	case Asr:
		return pt.Asr
	case Maghrib:
		return pt.Maghrib
	case Isha:
		return pt.Isha
	default:
		return ""
	}
}
