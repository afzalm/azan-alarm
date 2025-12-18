import React from 'react';
import { View, Text, StyleSheet, TouchableOpacity } from 'react-native';
import { Location } from '../types';
import { AppColors } from '../constants/theme';

interface LocationCardProps {
    location: Location;
    onSelect?: () => void;
    onDelete?: () => void;
    showActions?: boolean;
}

export const LocationCard: React.FC<LocationCardProps> = ({
    location,
    onSelect,
    onDelete,
    showActions = true,
}) => {
    return (
        <TouchableOpacity
            style={[styles.container, location.isCurrent && styles.currentContainer]}
            onPress={onSelect}
            activeOpacity={0.7}
        >
            <View style={styles.content}>
                <View style={styles.info}>
                    <Text style={styles.name}>{location.name}</Text>
                    <Text style={styles.country}>{location.country}</Text>
                    <Text style={styles.coordinates}>
                        {location.latitude.toFixed(4)}, {location.longitude.toFixed(4)}
                    </Text>
                </View>
                {location.isCurrent && (
                    <View style={styles.currentBadge}>
                        <Text style={styles.currentBadgeText}>Current</Text>
                    </View>
                )}
            </View>
            {showActions && onDelete && !location.isCurrent && (
                <TouchableOpacity
                    style={styles.deleteButton}
                    onPress={onDelete}
                    hitSlop={{ top: 10, bottom: 10, left: 10, right: 10 }}
                >
                    <Text style={styles.deleteText}>Delete</Text>
                </TouchableOpacity>
            )}
        </TouchableOpacity>
    );
};

const styles = StyleSheet.create({
    container: {
        backgroundColor: AppColors.surface,
        borderRadius: 12,
        padding: 16,
        marginVertical: 6,
        shadowColor: '#000',
        shadowOffset: { width: 0, height: 2 },
        shadowOpacity: 0.1,
        shadowRadius: 4,
        elevation: 3,
    },
    currentContainer: {
        borderWidth: 2,
        borderColor: AppColors.primary,
    },
    content: {
        flexDirection: 'row',
        justifyContent: 'space-between',
        alignItems: 'flex-start',
    },
    info: {
        flex: 1,
    },
    name: {
        fontSize: 18,
        fontWeight: '600',
        color: AppColors.onSurface,
        marginBottom: 4,
    },
    country: {
        fontSize: 14,
        color: AppColors.onSurface,
        opacity: 0.7,
        marginBottom: 4,
    },
    coordinates: {
        fontSize: 12,
        color: AppColors.onSurface,
        opacity: 0.5,
    },
    currentBadge: {
        backgroundColor: AppColors.primary,
        paddingHorizontal: 12,
        paddingVertical: 6,
        borderRadius: 12,
    },
    currentBadgeText: {
        fontSize: 12,
        color: AppColors.onPrimary,
        fontWeight: '600',
    },
    deleteButton: {
        marginTop: 12,
        alignSelf: 'flex-end',
    },
    deleteText: {
        fontSize: 14,
        color: AppColors.error,
        fontWeight: '500',
    },
});
