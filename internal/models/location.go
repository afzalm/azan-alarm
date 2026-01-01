// Package models contains data model definitions for the AzanAlarm application.
package models

import "time"

// Location represents a geographic location for prayer time calculations.
type Location struct {
	ID        int     `json:"id"`
	Name      string  `json:"name"`
	Country   string  `json:"country"`
	Latitude  float64 `json:"latitude"`
	Longitude float64 `json:"longitude"`
	Timezone  string  `json:"timezone"`
	IsCurrent bool    `json:"isCurrent"`
	CreatedAt int64   `json:"createdAt"` // Unix timestamp in milliseconds
}

// NewLocation creates a new Location with the current timestamp.
func NewLocation(name, country string, lat, lon float64, timezone string) Location {
	return Location{
		Name:      name,
		Country:   country,
		Latitude:  lat,
		Longitude: lon,
		Timezone:  timezone,
		IsCurrent: false,
		CreatedAt: time.Now().UnixMilli(),
	}
}

// DisplayName returns a formatted display name for the location.
func (l *Location) DisplayName() string {
	return l.Name + ", " + l.Country
}

// IsSameLocation checks if two locations are at the same coordinates.
func (l *Location) IsSameLocation(other Location) bool {
	return l.Latitude == other.Latitude && l.Longitude == other.Longitude
}
