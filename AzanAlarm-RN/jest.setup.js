jest.mock('react-native-mmkv', () => ({
    MMKV: jest.fn().mockImplementation(() => ({
        set: jest.fn(),
        getString: jest.fn(),
        delete: jest.fn(),
        clearAll: jest.fn(),
        contains: jest.fn(),
        getAllKeys: jest.fn(() => []),
    })),
}));

jest.mock('@react-native-community/geolocation', () => ({
    getCurrentPosition: jest.fn(),
    watchPosition: jest.fn(),
    clearWatch: jest.fn(),
    stopObserving: jest.fn(),
}));

jest.mock('react-native-permissions', () => ({
    PERMISSIONS: {
        IOS: {
            LOCATION_WHEN_IN_USE: 'ios.permission.LOCATION_WHEN_IN_USE',
            NOTIFICATIONS: 'ios.permission.NOTIFICATIONS',
        },
        ANDROID: {
            ACCESS_FINE_LOCATION: 'android.permission.ACCESS_FINE_LOCATION',
            POST_NOTIFICATIONS: 'android.permission.POST_NOTIFICATIONS',
        },
    },
    RESULTS: {
        GRANTED: 'granted',
        DENIED: 'denied',
        BLOCKED: 'blocked',
        UNAVAILABLE: 'unavailable',
    },
    request: jest.fn(() => Promise.resolve('granted')),
    check: jest.fn(() => Promise.resolve('granted')),
}));
