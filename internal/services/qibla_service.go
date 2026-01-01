// Package services contains business logic for the AzanAlarm application.
package services

import (
	"math"
)

// QiblaService calculates the Qibla direction.
type QiblaService struct{}

// Makkah coordinates (Kaaba)
const (
	MakkahLatitude  = 21.4225
	MakkahLongitude = 39.8262
)

// NewQiblaService creates a new QiblaService instance.
func NewQiblaService() *QiblaService {
	return &QiblaService{}
}

// GetQiblaDirection calculates the Qibla direction from a given location.
// Returns the bearing in degrees from North (0-360).
func (qs *QiblaService) GetQiblaDirection(latitude, longitude float64) float64 {
	// Convert to radians
	lat1 := qs.degreesToRadians(latitude)
	lon1 := qs.degreesToRadians(longitude)
	lat2 := qs.degreesToRadians(MakkahLatitude)
	lon2 := qs.degreesToRadians(MakkahLongitude)

	// Calculate bearing using great circle formula
	dLon := lon2 - lon1

	x := math.Sin(dLon) * math.Cos(lat2)
	y := math.Cos(lat1)*math.Sin(lat2) - math.Sin(lat1)*math.Cos(lat2)*math.Cos(dLon)

	bearing := math.Atan2(x, y)
	bearingDegrees := qs.radiansToDegrees(bearing)

	// Normalize to 0-360
	if bearingDegrees < 0 {
		bearingDegrees += 360
	}

	return bearingDegrees
}

// GetDistanceToMakkah calculates the distance to Makkah in kilometers.
func (qs *QiblaService) GetDistanceToMakkah(latitude, longitude float64) float64 {
	// Earth radius in kilometers
	const R = 6371.0

	lat1 := qs.degreesToRadians(latitude)
	lon1 := qs.degreesToRadians(longitude)
	lat2 := qs.degreesToRadians(MakkahLatitude)
	lon2 := qs.degreesToRadians(MakkahLongitude)

	dLat := lat2 - lat1
	dLon := lon2 - lon1

	// Haversine formula
	a := math.Sin(dLat/2)*math.Sin(dLat/2) +
		math.Cos(lat1)*math.Cos(lat2)*math.Sin(dLon/2)*math.Sin(dLon/2)
	c := 2 * math.Atan2(math.Sqrt(a), math.Sqrt(1-a))

	return R * c
}

// degreesToRadians converts degrees to radians.
func (qs *QiblaService) degreesToRadians(degrees float64) float64 {
	return degrees * math.Pi / 180.0
}

// radiansToDegrees converts radians to degrees.
func (qs *QiblaService) radiansToDegrees(radians float64) float64 {
	return radians * 180.0 / math.Pi
}
