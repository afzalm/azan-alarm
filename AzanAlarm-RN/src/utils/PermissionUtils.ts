import { Platform } from 'react-native';
import { PERMISSIONS, request, check, RESULTS, Permission } from 'react-native-permissions';
import { PermissionError } from './ErrorHandler';

export enum PermissionStatus {
    GRANTED = 'granted',
    DENIED = 'denied',
    BLOCKED = 'blocked',
    UNAVAILABLE = 'unavailable',
}

/**
 * Request location permission
 */
export const requestLocationPermission = async (): Promise<PermissionStatus> => {
    try {
        const permission: Permission = Platform.select({
            ios: PERMISSIONS.IOS.LOCATION_WHEN_IN_USE,
            android: PERMISSIONS.ANDROID.ACCESS_FINE_LOCATION,
        }) as Permission;

        const result = await request(permission);

        switch (result) {
            case RESULTS.GRANTED:
                return PermissionStatus.GRANTED;
            case RESULTS.DENIED:
                return PermissionStatus.DENIED;
            case RESULTS.BLOCKED:
                return PermissionStatus.BLOCKED;
            case RESULTS.UNAVAILABLE:
                return PermissionStatus.UNAVAILABLE;
            default:
                return PermissionStatus.DENIED;
        }
    } catch (error) {
        throw new PermissionError(
            'Failed to request location permission',
            'LOCATION_PERMISSION_ERROR',
            error as Error
        );
    }
};

/**
 * Check location permission status
 */
export const checkLocationPermission = async (): Promise<PermissionStatus> => {
    try {
        const permission: Permission = Platform.select({
            ios: PERMISSIONS.IOS.LOCATION_WHEN_IN_USE,
            android: PERMISSIONS.ANDROID.ACCESS_FINE_LOCATION,
        }) as Permission;

        const result = await check(permission);

        switch (result) {
            case RESULTS.GRANTED:
                return PermissionStatus.GRANTED;
            case RESULTS.DENIED:
                return PermissionStatus.DENIED;
            case RESULTS.BLOCKED:
                return PermissionStatus.BLOCKED;
            case RESULTS.UNAVAILABLE:
                return PermissionStatus.UNAVAILABLE;
            default:
                return PermissionStatus.DENIED;
        }
    } catch (error) {
        throw new PermissionError(
            'Failed to check location permission',
            'LOCATION_PERMISSION_CHECK_ERROR',
            error as Error
        );
    }
};

/**
 * Request notification permission
 */
export const requestNotificationPermission = async (): Promise<PermissionStatus> => {
    try {
        const permission: Permission = Platform.select({
            ios: PERMISSIONS.IOS.NOTIFICATIONS,
            android: PERMISSIONS.ANDROID.POST_NOTIFICATIONS,
        }) as Permission;

        const result = await request(permission);

        switch (result) {
            case RESULTS.GRANTED:
                return PermissionStatus.GRANTED;
            case RESULTS.DENIED:
                return PermissionStatus.DENIED;
            case RESULTS.BLOCKED:
                return PermissionStatus.BLOCKED;
            case RESULTS.UNAVAILABLE:
                return PermissionStatus.UNAVAILABLE;
            default:
                return PermissionStatus.DENIED;
        }
    } catch (error) {
        throw new PermissionError(
            'Failed to request notification permission',
            'NOTIFICATION_PERMISSION_ERROR',
            error as Error
        );
    }
};

/**
 * Check notification permission status
 */
export const checkNotificationPermission = async (): Promise<PermissionStatus> => {
    try {
        const permission: Permission = Platform.select({
            ios: PERMISSIONS.IOS.NOTIFICATIONS,
            android: PERMISSIONS.ANDROID.POST_NOTIFICATIONS,
        }) as Permission;

        const result = await check(permission);

        switch (result) {
            case RESULTS.GRANTED:
                return PermissionStatus.GRANTED;
            case RESULTS.DENIED:
                return PermissionStatus.DENIED;
            case RESULTS.BLOCKED:
                return PermissionStatus.BLOCKED;
            case RESULTS.UNAVAILABLE:
                return PermissionStatus.UNAVAILABLE;
            default:
                return PermissionStatus.DENIED;
        }
    } catch (error) {
        throw new PermissionError(
            'Failed to check notification permission',
            'NOTIFICATION_PERMISSION_CHECK_ERROR',
            error as Error
        );
    }
};
