// Package services contains business logic for the AzanAlarm application.
package services

import (
	"encoding/json"
	"os"
	"path/filepath"
	"sync"
)

// StorageService handles persistent storage of application data.
type StorageService struct {
	dataDir string
	mu      sync.RWMutex
}

// NewStorageService creates a new StorageService instance.
func NewStorageService() (*StorageService, error) {
	// Get user config directory
	configDir, err := os.UserConfigDir()
	if err != nil {
		return nil, err
	}

	dataDir := filepath.Join(configDir, "AzanAlarm")
	if err := os.MkdirAll(dataDir, 0755); err != nil {
		return nil, err
	}

	return &StorageService{
		dataDir: dataDir,
	}, nil
}

// Save saves data to a file.
func (s *StorageService) Save(key string, data interface{}) error {
	s.mu.Lock()
	defer s.mu.Unlock()

	filePath := filepath.Join(s.dataDir, key+".json")

	jsonData, err := json.MarshalIndent(data, "", "  ")
	if err != nil {
		return err
	}

	return os.WriteFile(filePath, jsonData, 0644)
}

// Load loads data from a file.
func (s *StorageService) Load(key string, data interface{}) error {
	s.mu.RLock()
	defer s.mu.RUnlock()

	filePath := filepath.Join(s.dataDir, key+".json")

	jsonData, err := os.ReadFile(filePath)
	if err != nil {
		return err
	}

	return json.Unmarshal(jsonData, data)
}

// Delete removes a storage file.
func (s *StorageService) Delete(key string) error {
	s.mu.Lock()
	defer s.mu.Unlock()

	filePath := filepath.Join(s.dataDir, key+".json")
	return os.Remove(filePath)
}

// Exists checks if a storage key exists.
func (s *StorageService) Exists(key string) bool {
	s.mu.RLock()
	defer s.mu.RUnlock()

	filePath := filepath.Join(s.dataDir, key+".json")
	_, err := os.Stat(filePath)
	return err == nil
}

// GetDataDir returns the data directory path.
func (s *StorageService) GetDataDir() string {
	return s.dataDir
}
