import { calculateQiblaDirection, calculateDistanceToMecca } from '../../src/services/QiblaService';

describe('QiblaService', () => {
    describe('calculateQiblaDirection', () => {
        it('should calculate correct direction from New York to Mecca', () => {
            const direction = calculateQiblaDirection(40.7128, -74.0060); // New York
            expect(direction).toBeGreaterThan(0);
            expect(direction).toBeLessThan(360);
            expect(Math.round(direction)).toBe(58); // Approximate northeast
        });

        it('should calculate correct direction from London to Mecca', () => {
            const direction = calculateQiblaDirection(51.5074, -0.1278); // London
            expect(direction).toBeGreaterThan(0);
            expect(direction).toBeLessThan(360);
            expect(Math.round(direction)).toBe(119); // Approximate southeast
        });

        it('should return 0-360 range', () => {
            const direction = calculateQiblaDirection(0, 0);
            expect(direction).toBeGreaterThanOrEqual(0);
            expect(direction).toBeLessThan(360);
        });
    });

    describe('calculateDistanceToMecca', () => {
        it('should calculate correct distance from New York to Mecca', () => {
            const distance = calculateDistanceToMecca(40.7128, -74.0060);
            expect(distance).toBeGreaterThan(9000);
            expect(distance).toBeLessThan(11000);
        });

        it('should calculate correct distance from London to Mecca', () => {
            const distance = calculateDistanceToMecca(51.5074, -0.1278);
            expect(distance).toBeGreaterThan(4000);
            expect(distance).toBeLessThan(5000);
        });

        it('should return 0 for Mecca coordinates', () => {
            const distance = calculateDistanceToMecca(21.4225, 39.8262);
            expect(distance).toBeLessThan(1); // Very close to 0
        });
    });
});
