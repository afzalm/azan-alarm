# Implementation Plan - Landing Page Design & Real Prayer Times

This plan outlines the steps to enhance the landing page (Home Screen) of the AzanAlarm app to show real prayer times with a premium design.

## 1. Data Layer Enhancements
- [ ] **Default Location**: Modify `currentLocationProvider` to return a default location (e.g., Mecca) if no saved location is found. This ensures "real" times are always visible.
- [ ] **Calculation Verification**: Ensure the `PrayerTimeCalculator` is correctly used and returns accurate results for the current/default location.

## 2. UI/UX Refinement (Landing Page)
- [ ] **Vibrant Background**: Replace the basic app bar with a dynamic gradient background that covers the top section.
- [ ] **Focus Countdown**: Redesign the "Next Prayer" countdown as a prominent, elegant card with glassmorphism effects.
- [ ] **Sleek Prayer List**: Update the list of today's prayer times to use modern, clean cards with micro-animations or subtle transitions.
- [ ] **Islamic Aesthetics**: Incorporate subtle Islamic patterns (vector graphics/icons) in the background.

## 3. Interaction Improvements
- [ ] **Smooth Transitions**: Ensure smooth navigation between screens.
- [ ] **Dynamic Theming**: (Optional) Adjust UI colors based on the current/next prayer.

## 4. Implementation Details
- **File**: `lib/presentation/screens/home_screen.dart`
- **File**: `lib/core/providers/providers.dart`
- **File**: `lib/core/theme/app_theme.dart` (for extra design tokens)

## 5. Verification
- [ ] Build and run on web to confirm aesthetics and real data display.
