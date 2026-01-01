// Package services contains business logic for the AzanAlarm application.
package services

import (
	"time"

	"AzanAlarm/internal/models"
)

// AlarmService handles alarm management.
type AlarmService struct {
	storage  *StorageService
	alarms   []models.Alarm
	nextID   int
}

// NewAlarmService creates a new AlarmService instance.
func NewAlarmService(storage *StorageService) *AlarmService {
	as := &AlarmService{
		storage: storage,
		alarms:  []models.Alarm{},
		nextID:  1,
	}

	// Load existing alarms
	var savedAlarms []models.Alarm
	if err := storage.Load("alarms", &savedAlarms); err == nil {
		as.alarms = savedAlarms
		// Find max ID
		for _, a := range as.alarms {
			if a.ID >= as.nextID {
				as.nextID = a.ID + 1
			}
		}
	}

	return as
}

// GetAlarms returns all alarms.
func (as *AlarmService) GetAlarms() []models.Alarm {
	return as.alarms
}

// GetAlarm returns a specific alarm by ID.
func (as *AlarmService) GetAlarm(id int) *models.Alarm {
	for i := range as.alarms {
		if as.alarms[i].ID == id {
			return &as.alarms[i]
		}
	}
	return nil
}

// CreateAlarm creates a new alarm.
func (as *AlarmService) CreateAlarm(alarm models.Alarm) (models.Alarm, error) {
	alarm.ID = as.nextID
	as.nextID++
	now := time.Now().UnixMilli()
	alarm.CreatedAt = now
	alarm.UpdatedAt = now

	as.alarms = append(as.alarms, alarm)
	if err := as.save(); err != nil {
		return models.Alarm{}, err
	}
	return alarm, nil
}

// UpdateAlarm updates an existing alarm.
func (as *AlarmService) UpdateAlarm(alarm models.Alarm) error {
	for i := range as.alarms {
		if as.alarms[i].ID == alarm.ID {
			alarm.UpdatedAt = time.Now().UnixMilli()
			as.alarms[i] = alarm
			return as.save()
		}
	}
	return nil
}

// DeleteAlarm removes an alarm.
func (as *AlarmService) DeleteAlarm(id int) error {
	newAlarms := make([]models.Alarm, 0, len(as.alarms))
	for _, a := range as.alarms {
		if a.ID != id {
			newAlarms = append(newAlarms, a)
		}
	}
	as.alarms = newAlarms
	return as.save()
}

// ToggleAlarm toggles the active state of an alarm.
func (as *AlarmService) ToggleAlarm(id int, active bool) error {
	for i := range as.alarms {
		if as.alarms[i].ID == id {
			as.alarms[i].IsActive = active
			as.alarms[i].UpdatedAt = time.Now().UnixMilli()
			return as.save()
		}
	}
	return nil
}

// GetActiveAlarms returns only active alarms.
func (as *AlarmService) GetActiveAlarms() []models.Alarm {
	active := make([]models.Alarm, 0)
	for _, a := range as.alarms {
		if a.IsActive {
			active = append(active, a)
		}
	}
	return active
}

// GetAlarmsForPrayer returns alarms for a specific prayer.
func (as *AlarmService) GetAlarmsForPrayer(prayer models.Prayer) []models.Alarm {
	result := make([]models.Alarm, 0)
	for _, a := range as.alarms {
		if a.Prayer == prayer && a.IsActive {
			result = append(result, a)
		}
	}
	return result
}

// save persists alarms to storage.
func (as *AlarmService) save() error {
	return as.storage.Save("alarms", as.alarms)
}
