import React from 'react';
import { NavigationContainer } from '@react-navigation/native';
import { createBottomTabNavigator } from '@react-navigation/bottom-tabs';
import { useTheme } from '../hooks/useTheme';
import { HomeScreen } from '../features/home/HomeScreen';
import { AlarmsScreen } from '../features/alarms/AlarmsScreen';
import { LocationScreen } from '../features/location/LocationScreen';
import { QiblaScreen } from '../features/qibla/QiblaScreen';
import { SettingsScreen } from '../features/settings/SettingsScreen';

const Tab = createBottomTabNavigator();

export const AppNavigator = () => {
    const { colors, isDark } = useTheme();

    return (
        <NavigationContainer
            theme={{
                dark: isDark,
                colors: {
                    primary: colors.primary,
                    background: colors.background,
                    card: colors.surface,
                    text: colors.onSurface,
                    border: colors.surfaceVariant,
                    notification: colors.primary,
                },
            }}
        >
            <Tab.Navigator
                screenOptions={{
                    headerShown: true,
                    tabBarActiveTintColor: colors.primary,
                    tabBarInactiveTintColor: colors.onSurface + '80',
                    tabBarStyle: {
                        backgroundColor: colors.surface,
                        borderTopColor: colors.surfaceVariant,
                    },
                    headerStyle: {
                        backgroundColor: colors.surface,
                    },
                    headerTintColor: colors.onSurface,
                }}
            >
                <Tab.Screen
                    name="Home"
                    component={HomeScreen}
                    options={{
                        tabBarLabel: 'Home',
                    }}
                />
                <Tab.Screen
                    name="Alarms"
                    component={AlarmsScreen}
                    options={{
                        tabBarLabel: 'Alarms',
                    }}
                />
                <Tab.Screen
                    name="Qibla"
                    component={QiblaScreen}
                    options={{
                        tabBarLabel: 'Qibla',
                    }}
                />
                <Tab.Screen
                    name="Location"
                    component={LocationScreen}
                    options={{
                        tabBarLabel: 'Location',
                    }}
                />
                <Tab.Screen
                    name="Settings"
                    component={SettingsScreen}
                    options={{
                        tabBarLabel: 'Settings',
                    }}
                />
            </Tab.Navigator>
        </NavigationContainer>
    );
};
