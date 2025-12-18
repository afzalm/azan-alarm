// Mecca coordinates
const MECCA_LAT = 21.4225;
const MECCA_LNG = 39.8262;

/**
 * Calculate Qibla direction (bearing to Mecca) from given coordinates
 * Returns bearing in degrees (0-360)
 */
export const calculateQiblaDirection = (latitude: number, longitude: number): number => {
    const lat1 = toRadians(latitude);
    const lng1 = toRadians(longitude);
    const lat2 = toRadians(MECCA_LAT);
    const lng2 = toRadians(MECCA_LNG);

    const dLng = lng2 - lng1;

    const y = Math.sin(dLng) * Math.cos(lat2);
    const x = Math.cos(lat1) * Math.sin(lat2) - Math.sin(lat1) * Math.cos(lat2) * Math.cos(dLng);

    let bearing = toDegrees(Math.atan2(y, x));
    bearing = (bearing + 360) % 360; // Normalize to 0-360

    return bearing;
};

/**
 * Calculate distance to Mecca in kilometers
 */
export const calculateDistanceToMecca = (latitude: number, longitude: number): number => {
    const R = 6371; // Earth's radius in km

    const lat1 = toRadians(latitude);
    const lng1 = toRadians(longitude);
    const lat2 = toRadians(MECCA_LAT);
    const lng2 = toRadians(MECCA_LNG);

    const dLat = lat2 - lat1;
    const dLng = lng2 - lng1;

    const a =
        Math.sin(dLat / 2) * Math.sin(dLat / 2) +
        Math.cos(lat1) * Math.cos(lat2) * Math.sin(dLng / 2) * Math.sin(dLng / 2);

    const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));

    return R * c;
};

const toRadians = (degrees: number): number => {
    return degrees * (Math.PI / 180);
};

const toDegrees = (radians: number): number => {
    return radians * (180 / Math.PI);
};
