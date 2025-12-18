// Light Theme Colors
export const LightColors = {
    primary: '#1E88E5',
    primaryContainer: '#E3F2FD',
    onPrimary: '#FFFFFF',
    secondary: '#8E24AA',
    secondaryContainer: '#F3E5F5',
    onSecondary: '#FFFFFF',
    fajrColor: '#4A148C',
    dhuhrColor: '#F57C00',
    asrColor: '#2E7D32',
    maghribColor: '#D84315',
    ishaColor: '#1565C0',
    surface: '#FAFAFA',
    surfaceVariant: '#F5F5F5',
    onSurface: '#212121',
    background: '#FFFFFF',
    onBackground: '#212121',
    success: '#4CAF50',
    warning: '#FF9800',
    error: '#F44336',
};

// Dark Theme Colors
export const DarkColors = {
    primary: '#64B5F6',
    primaryContainer: '#1565C0',
    onPrimary: '#000000',
    secondary: '#CE93D8',
    secondaryContainer: '#6A1B9A',
    onSecondary: '#000000',
    fajrColor: '#9C27B0',
    dhuhrColor: '#FF9800',
    asrColor: '#66BB6A',
    maghribColor: '#FF5722',
    ishaColor: '#42A5F5',
    surface: '#1E1E1E',
    surfaceVariant: '#2C2C2C',
    onSurface: '#E0E0E0',
    background: '#121212',
    onBackground: '#E0E0E0',
    success: '#66BB6A',
    warning: '#FFA726',
    error: '#EF5350',
};

// Legacy export for backward compatibility
export const AppColors = LightColors;

export const AppTextStyles = {
    h1: { fontSize: 32, fontWeight: '700' as const, letterSpacing: -0.5 },
    h2: { fontSize: 24, fontWeight: '600' as const, letterSpacing: -0.25 },
    bodyLarge: { fontSize: 16, fontWeight: '400' as const, letterSpacing: 0.5 },
    prayerTime: { fontSize: 20, fontWeight: '600' as const, letterSpacing: 1.0 },
};
