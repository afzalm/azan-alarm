import React, { createContext, useState, useEffect, ReactNode } from 'react';
import { useColorScheme } from 'react-native';
import { LightColors, DarkColors } from '../constants/theme';
import { storageService } from '../services/StorageService';
import { AppTheme } from '../types';

interface ThemeContextType {
    theme: AppTheme;
    colors: typeof LightColors;
    isDark: boolean;
    toggleTheme: () => void;
    setTheme: (theme: AppTheme) => void;
}

const THEME_STORAGE_KEY = 'app_theme';

export const ThemeContext = createContext<ThemeContextType>({
    theme: AppTheme.System,
    colors: LightColors,
    isDark: false,
    toggleTheme: () => { },
    setTheme: () => { },
});

interface ThemeProviderProps {
    children: ReactNode;
}

export const ThemeProvider: React.FC<ThemeProviderProps> = ({ children }) => {
    const systemColorScheme = useColorScheme();
    const [theme, setThemeState] = useState<AppTheme>(AppTheme.System);

    // Load saved theme on mount
    useEffect(() => {
        const savedTheme = storageService.get<AppTheme>(THEME_STORAGE_KEY);
        if (savedTheme) {
            setThemeState(savedTheme);
        }
    }, []);

    // Determine if dark mode should be active
    const isDark =
        theme === AppTheme.Dark ||
        (theme === AppTheme.System && systemColorScheme === 'dark');

    // Get current colors based on theme
    const colors = isDark ? DarkColors : LightColors;

    const setTheme = (newTheme: AppTheme) => {
        setThemeState(newTheme);
        storageService.set(THEME_STORAGE_KEY, newTheme);
    };

    const toggleTheme = () => {
        const newTheme = isDark ? AppTheme.Light : AppTheme.Dark;
        setTheme(newTheme);
    };

    return (
        <ThemeContext.Provider value={{ theme, colors, isDark, toggleTheme, setTheme }}>
            {children}
        </ThemeContext.Provider>
    );
};
