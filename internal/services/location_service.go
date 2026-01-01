// Package services contains business logic for the AzanAlarm application.
package services

import (
	"encoding/json"
	"fmt"
	"net/http"
	"net/url"
	"time"

	"AzanAlarm/internal/models"
)

// LocationService handles location-related operations.
type LocationService struct {
	storage    *StorageService
	httpClient *http.Client
}

// NominatimResult represents a result from the Nominatim API.
type NominatimResult struct {
	PlaceID     int    `json:"place_id"`
	Lat         string `json:"lat"`
	Lon         string `json:"lon"`
	DisplayName string `json:"display_name"`
	Address     struct {
		Country string `json:"country"`
		City    string `json:"city"`
		Town    string `json:"town"`
		Village string `json:"village"`
	} `json:"address"`
}

// NewLocationService creates a new LocationService instance.
func NewLocationService(storage *StorageService) *LocationService {
	return &LocationService{
		storage: storage,
		httpClient: &http.Client{
			Timeout: 15 * time.Second,
		},
	}
}

// SearchLocations searches for locations using the Nominatim API.
func (ls *LocationService) SearchLocations(query string) ([]models.Location, error) {
	if len(query) < 2 {
		return []models.Location{}, nil
	}

	baseURL := "https://nominatim.openstreetmap.org/search"
	params := url.Values{}
	params.Add("q", query)
	params.Add("format", "json")
	params.Add("limit", "10")
	params.Add("addressdetails", "1")

	req, err := http.NewRequest("GET", baseURL+"?"+params.Encode(), nil)
	if err != nil {
		return nil, err
	}
	req.Header.Set("User-Agent", "AzanAlarm/1.0")

	resp, err := ls.httpClient.Do(req)
	if err != nil {
		return nil, err
	}
	defer resp.Body.Close()

	var results []NominatimResult
	if err := json.NewDecoder(resp.Body).Decode(&results); err != nil {
		return nil, err
	}

	locations := make([]models.Location, 0, len(results))
	for _, r := range results {
		lat, _ := parseFloat(r.Lat)
		lon, _ := parseFloat(r.Lon)

		name := r.Address.City
		if name == "" {
			name = r.Address.Town
		}
		if name == "" {
			name = r.Address.Village
		}
		if name == "" && r.DisplayName != "" {
			// Use first part of display name
			name = r.DisplayName
			if len(name) > 30 {
				name = name[:30]
			}
		}

		locations = append(locations, models.Location{
			Name:      name,
			Country:   r.Address.Country,
			Latitude:  lat,
			Longitude: lon,
			Timezone:  time.Local.String(), // Approximate
			CreatedAt: time.Now().UnixMilli(),
		})
	}

	return locations, nil
}

// ReverseGeocode gets location name from coordinates.
func (ls *LocationService) ReverseGeocode(lat, lon float64) (*models.Location, error) {
	baseURL := "https://nominatim.openstreetmap.org/reverse"
	params := url.Values{}
	params.Add("lat", formatFloat(lat))
	params.Add("lon", formatFloat(lon))
	params.Add("format", "json")

	req, err := http.NewRequest("GET", baseURL+"?"+params.Encode(), nil)
	if err != nil {
		return nil, err
	}
	req.Header.Set("User-Agent", "AzanAlarm/1.0")

	resp, err := ls.httpClient.Do(req)
	if err != nil {
		return nil, err
	}
	defer resp.Body.Close()

	var result NominatimResult
	if err := json.NewDecoder(resp.Body).Decode(&result); err != nil {
		return nil, err
	}

	name := result.Address.City
	if name == "" {
		name = result.Address.Town
	}
	if name == "" {
		name = result.Address.Village
	}
	if name == "" {
		name = "Unknown"
	}

	return &models.Location{
		Name:      name,
		Country:   result.Address.Country,
		Latitude:  lat,
		Longitude: lon,
		Timezone:  time.Local.String(),
		IsCurrent: true,
		CreatedAt: time.Now().UnixMilli(),
	}, nil
}

// GetCurrentLocation returns the currently active location.
func (ls *LocationService) GetCurrentLocation() *models.Location {
	var location models.Location
	if err := ls.storage.Load("current_location", &location); err != nil {
		return nil
	}
	return &location
}

// SetCurrentLocation sets the current active location.
func (ls *LocationService) SetCurrentLocation(location models.Location) error {
	location.IsCurrent = true
	return ls.storage.Save("current_location", location)
}

// GetSavedLocations returns all saved locations.
func (ls *LocationService) GetSavedLocations() []models.Location {
	var locations []models.Location
	if err := ls.storage.Load("saved_locations", &locations); err != nil {
		return []models.Location{}
	}
	return locations
}

// SaveLocation adds a location to saved locations.
func (ls *LocationService) SaveLocation(location models.Location) error {
	locations := ls.GetSavedLocations()

	// Check if location already exists
	for _, loc := range locations {
		if loc.IsSameLocation(location) {
			return nil // Already saved
		}
	}

	location.ID = len(locations) + 1
	locations = append(locations, location)
	return ls.storage.Save("saved_locations", locations)
}

// DeleteLocation removes a location from saved locations.
func (ls *LocationService) DeleteLocation(id int) error {
	locations := ls.GetSavedLocations()
	newLocations := make([]models.Location, 0, len(locations))

	for _, loc := range locations {
		if loc.ID != id {
			newLocations = append(newLocations, loc)
		}
	}

	return ls.storage.Save("saved_locations", newLocations)
}

// formatFloat formats a float64 for URL parameters.
func formatFloat(f float64) string {
	return fmt.Sprintf("%f", f)
}

// parseFloat parses a string to float64.
func parseFloat(s string) (float64, error) {
	var f float64
	_, err := fmt.Sscanf(s, "%f", &f)
	return f, err
}
