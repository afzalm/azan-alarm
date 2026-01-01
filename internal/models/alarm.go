// Package models contains data model definitions for the AzanAlarm application.
package models

import (
	"fmt"
	"time"
)

// Alarm represents a prayer time alarm.
type Alarm struct {
	ID               int    `json:"id"`
	Prayer           Prayer `json:"prayer"`
	OffsetMinutes    int    `json:"offsetMinutes"` // Negative for before, positive for after
	Label            string `json:"label"`
	SoundPath        string `json:"soundPath"`
	IsActive         bool   `json:"isActive"`
	RepeatDays       []int  `json:"repeatDays"` // 1=Monday, 7=Sunday
	VibrationEnabled bool   `json:"vibrationEnabled"`
	CreatedAt        int64  `json:"createdAt"` // Unix timestamp in milliseconds
	UpdatedAt        int64  `json:"updatedAt"` // Unix timestamp in milliseconds
}

// NewAlarm creates a new alarm with default values.
func NewAlarm(prayer Prayer, offsetMinutes int) Alarm {
	now := time.Now().UnixMilli()
	return Alarm{
		Prayer:           prayer,
		OffsetMinutes:    offsetMinutes,
		IsActive:         true,
		RepeatDays:       []int{}, // Empty means every day
		VibrationEnabled: true,
		CreatedAt:        now,
		UpdatedAt:        now,
	}
}

// GetActualAlarmTime calculates the actual alarm time by applying offset to prayer time.
func (a *Alarm) GetActualAlarmTime(prayerTime time.Time) time.Time {
	return prayerTime.Add(time.Duration(a.OffsetMinutes) * time.Minute)
}

// ShouldTriggerOnDay checks if the alarm should trigger on a specific day.
func (a *Alarm) ShouldTriggerOnDay(date time.Time) bool {
	if len(a.RepeatDays) == 0 {
		return true // Empty means every day
	}
	dayOfWeek := int(date.Weekday())
	if dayOfWeek == 0 {
		dayOfWeek = 7 // Convert Sunday from 0 to 7
	}
	for _, day := range a.RepeatDays {
		if day == dayOfWeek {
			return true
		}
	}
	return false
}

// DisplayLabel returns a human-readable label for the alarm.
func (a *Alarm) DisplayLabel() string {
	if a.Label != "" {
		return a.Label
	}

	if a.OffsetMinutes == 0 {
		return fmt.Sprintf("At %s time", a.Prayer.DisplayName())
	}

	direction := "after"
	offset := a.OffsetMinutes
	if offset < 0 {
		direction = "before"
		offset = -offset
	}

	return fmt.Sprintf("%d min %s %s", offset, direction, a.Prayer.DisplayName())
}

// MarkUpdated updates the UpdatedAt timestamp.
func (a *Alarm) MarkUpdated() {
	a.UpdatedAt = time.Now().UnixMilli()
}

// DayName returns the name of a day given its number (1-7).
func DayName(day int) string {
	switch day {
	case 1:
		return "Monday"
	case 2:
		return "Tuesday"
	case 3:
		return "Wednesday"
	case 4:
		return "Thursday"
	case 5:
		return "Friday"
	case 6:
		return "Saturday"
	case 7:
		return "Sunday"
	default:
		return ""
	}
}
