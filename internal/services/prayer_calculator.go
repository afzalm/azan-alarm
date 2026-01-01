// Package services contains business logic for the AzanAlarm application.
// Prayer time calculation using astronomical formulas
// Based on the methodology from praytimes.org and the working Flutter implementation.
package services

import (
	"math"
	"time"

	"AzanAlarm/internal/models"
)

// PrayerCalculator calculates prayer times using astronomical algorithms.
type PrayerCalculator struct{}

// NewPrayerCalculator creates a new PrayerCalculator instance.
func NewPrayerCalculator() *PrayerCalculator {
	return &PrayerCalculator{}
}

// CalculationParams holds the parameters for a specific calculation method.
type CalculationParams struct {
	FajrAngle       float64
	IshaAngle       float64
	IshaInterval    int
	MaghribAngle    float64
	MaghribInterval int
}

// Calculate computes prayer times for a given location and date.
func (pc *PrayerCalculator) Calculate(
	latitude, longitude float64,
	date time.Time,
	method models.PrayerCalculationMethod,
	juristicMethod models.JuristicMethod,
	timezoneOffset float64,
) models.PrayerTimes {
	params := pc.getCalculationParams(method)

	// Calculate Julian date
	jd := pc.calculateJulianDate(date)

	// Days since J2000.0
	d := jd - 2451545.0

	// Calculate equation of time and solar declination
	eqTime := pc.calculateEquationOfTime(d)
	declination := pc.calculateSolarDeclination(d)

	// Calculate Dhuhr first (solar noon) - calculate in UTC then we'll convert
	// Dhuhr in UTC = 12:00 - longitude/15 - eqTime/60
	dhuhrUTC := 12.0 - longitude/15.0 - eqTime/60.0

	// Calculate other prayer times relative to Dhuhr (all in UTC)
	fajrUTC := dhuhrUTC - pc.hourAngleForAngle(latitude, declination, params.FajrAngle)/15.0
	asrUTC := dhuhrUTC + pc.calculateAsrHourAngle(latitude, declination, juristicMethod)/15.0
	maghribUTC := pc.calculateMaghrib(latitude, declination, params, dhuhrUTC)
	ishaUTC := pc.calculateIsha(latitude, declination, params, maghribUTC, dhuhrUTC)

	// Convert to time strings (will add timezone offset)
	return models.PrayerTimes{
		Fajr:    pc.toTimeString(date, fajrUTC, timezoneOffset),
		Dhuhr:   pc.toTimeString(date, dhuhrUTC, timezoneOffset),
		Asr:     pc.toTimeString(date, asrUTC, timezoneOffset),
		Maghrib: pc.toTimeString(date, maghribUTC, timezoneOffset),
		Isha:    pc.toTimeString(date, ishaUTC, timezoneOffset),
	}
}

// getCalculationParams returns the calculation parameters for a given method.
func (pc *PrayerCalculator) getCalculationParams(method models.PrayerCalculationMethod) CalculationParams {
	switch method {
	case models.MuslimWorldLeague:
		return CalculationParams{FajrAngle: 18.0, IshaAngle: 17.0}
	case models.ISNA, models.NorthAmerica:
		return CalculationParams{FajrAngle: 15.0, IshaAngle: 15.0}
	case models.Egyptian:
		return CalculationParams{FajrAngle: 19.5, IshaAngle: 17.5}
	case models.UmmAlQura:
		return CalculationParams{FajrAngle: 18.5, IshaInterval: 90}
	case models.Karachi:
		return CalculationParams{FajrAngle: 18.0, IshaAngle: 18.0}
	case models.Tehran:
		return CalculationParams{FajrAngle: 17.7, IshaAngle: 14.0, MaghribAngle: 4.5}
	case models.Jafari:
		return CalculationParams{FajrAngle: 16.0, IshaAngle: 14.0, MaghribAngle: 4.0}
	case models.Gulf:
		return CalculationParams{FajrAngle: 19.5, IshaInterval: 90}
	case models.MoonsightingCommittee:
		return CalculationParams{FajrAngle: 18.0, IshaAngle: 18.0}
	default:
		return CalculationParams{FajrAngle: 18.0, IshaAngle: 17.0}
	}
}

// calculateJulianDate converts a Gregorian date to Julian date.
func (pc *PrayerCalculator) calculateJulianDate(date time.Time) float64 {
	year := date.Year()
	month := int(date.Month())
	day := date.Day()

	if month <= 2 {
		year--
		month += 12
	}

	a := (14 - month) / 12
	y := year + 4800 - a
	m := month + 12*a - 3

	return float64(day + (153*m+2)/5 + 365*y + y/4 - y/100 + y/400 - 32045)
}

// calculateEquationOfTime calculates the equation of time in minutes.
func (pc *PrayerCalculator) calculateEquationOfTime(d float64) float64 {
	// Normalize angles first
	g := pc.fixAngle(357.529 + 0.98560028*d)
	gRad := pc.deg2rad(g)

	q := pc.fixAngle(280.459 + 0.98564736*d)
	l := pc.fixAngle(q + 1.915*math.Sin(gRad) + 0.020*math.Sin(2*gRad))
	lRad := pc.deg2rad(l)

	e := 23.439 - 0.00000036*d
	eRad := pc.deg2rad(e)

	// Right ascension in degrees
	ra := pc.rad2deg(math.Atan2(math.Cos(eRad)*math.Sin(lRad), math.Cos(lRad)))
	ra = pc.fixAngle(ra)

	// Equation of time: difference between mean sun and true sun position
	// Both q and ra should now be in 0-360 range
	eqTime := q - ra

	// Handle wrap-around (e.g., q=350, ra=10 should give -20, not 340)
	if eqTime > 180 {
		eqTime -= 360
	} else if eqTime < -180 {
		eqTime += 360
	}

	return eqTime * 4 // Convert degrees to minutes (1 degree = 4 minutes)
}

// calculateSolarDeclination calculates the solar declination in degrees.
func (pc *PrayerCalculator) calculateSolarDeclination(d float64) float64 {
	g := pc.fixAngle(357.529 + 0.98560028*d)
	gRad := pc.deg2rad(g)

	q := pc.fixAngle(280.459 + 0.98564736*d)
	l := pc.fixAngle(q + 1.915*math.Sin(gRad) + 0.020*math.Sin(2*gRad))
	lRad := pc.deg2rad(l)

	e := 23.439 - 0.00000036*d
	eRad := pc.deg2rad(e)

	return pc.rad2deg(math.Asin(math.Sin(eRad) * math.Sin(lRad)))
}

// calculateDhuhr calculates Dhuhr time (solar noon).
func (pc *PrayerCalculator) calculateDhuhr(longitude, timezoneOffset, eqTime float64) float64 {
	return 12 + timezoneOffset - longitude/15.0 - eqTime/60.0
}

// hourAngleForAngle calculates the hour angle for a given sun depression angle below horizon.
// The formula is from PrayTimes.org: cos(H) = (-sin(angle) - sin(lat)*sin(dec)) / (cos(lat)*cos(dec))
func (pc *PrayerCalculator) hourAngleForAngle(latitude, declination, angle float64) float64 {
	latRad := pc.deg2rad(latitude)
	decRad := pc.deg2rad(declination)

	// For a sun depression angle (below horizon), use -sin(angle)
	cosH := (-math.Sin(pc.deg2rad(angle)) - math.Sin(latRad)*math.Sin(decRad)) /
		(math.Cos(latRad) * math.Cos(decRad))

	if cosH > 1 || cosH < -1 {
		return 0
	}

	return pc.rad2deg(math.Acos(cosH))
}

// calculateAsrHourAngle calculates the hour angle for Asr prayer.
func (pc *PrayerCalculator) calculateAsrHourAngle(latitude, declination float64, method models.JuristicMethod) float64 {
	shadowFactor := 1.0
	if method == models.Hanafi {
		shadowFactor = 2.0
	}

	latRad := pc.deg2rad(latitude)
	decRad := pc.deg2rad(declination)

	// Formula: Altitude A = arccot(shadowFactor + tan(|lat - dec|))
	// arccot(x) = arctan(1/x)
	altitudeRad := math.Atan(1.0 / (shadowFactor + math.Tan(math.Abs(latRad-decRad))))

	// Calculate hour angle H using: cos(H) = (sin(Alt) - sin(Lat)sin(Dec)) / (cos(Lat)cos(Dec))
	sinAlt := math.Sin(altitudeRad)
	cosH := (sinAlt - math.Sin(latRad)*math.Sin(decRad)) / (math.Cos(latRad) * math.Cos(decRad))

	if cosH > 1 || cosH < -1 {
		return 4 * 15.0 // Fallback if sun doesn't reach this altitude (unlikely for Asr)
	}

	return pc.rad2deg(math.Acos(cosH))
}

// calculateMaghrib calculates Maghrib time (sunset).
func (pc *PrayerCalculator) calculateMaghrib(latitude, declination float64, params CalculationParams, dhuhr float64) float64 {
	if params.MaghribAngle > 0 {
		return dhuhr + pc.hourAngleForAngle(latitude, declination, params.MaghribAngle)/15.0
	} else if params.MaghribInterval > 0 {
		sunset := dhuhr + pc.hourAngleForAngle(latitude, declination, 0.833)/15.0
		return sunset + float64(params.MaghribInterval)/60.0
	}
	// Standard: 0.833 degrees (atmospheric refraction + sun's radius)
	return dhuhr + pc.hourAngleForAngle(latitude, declination, 0.833)/15.0
}

// calculateIsha calculates Isha time (night).
func (pc *PrayerCalculator) calculateIsha(latitude, declination float64, params CalculationParams, maghrib, dhuhr float64) float64 {
	if params.IshaInterval > 0 {
		return maghrib + float64(params.IshaInterval)/60.0
	}
	return dhuhr + pc.hourAngleForAngle(latitude, declination, params.IshaAngle)/15.0
}

// toTimeString converts UTC decimal hours to an RFC3339 time string in local timezone.
func (pc *PrayerCalculator) toTimeString(date time.Time, hoursUTC float64, timezoneOffset float64) string {
	if math.IsNaN(hoursUTC) {
		return ""
	}

	// Add timezone offset to convert from UTC to local time
	hoursLocal := hoursUTC + timezoneOffset
	hoursLocal = pc.fixHour24(hoursLocal)

	h := int(hoursLocal)
	m := int((hoursLocal - float64(h)) * 60)

	// Create a fixed timezone based on the offset
	offsetSeconds := int(timezoneOffset * 3600)
	loc := time.FixedZone("Local", offsetSeconds)

	t := time.Date(date.Year(), date.Month(), date.Day(), h, m, 0, 0, loc)
	return t.Format(time.RFC3339)
}

// Utility functions
func (pc *PrayerCalculator) deg2rad(d float64) float64 {
	return d * math.Pi / 180.0
}

func (pc *PrayerCalculator) rad2deg(r float64) float64 {
	return r * 180.0 / math.Pi
}

func (pc *PrayerCalculator) fixAngle(a float64) float64 {
	a = math.Mod(a, 360)
	if a < 0 {
		a += 360
	}
	return a
}

func (pc *PrayerCalculator) fixHour24(h float64) float64 {
	h = math.Mod(h, 24)
	if h < 0 {
		h += 24
	}
	return h
}
