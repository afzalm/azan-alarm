import { MMKV } from 'react-native-mmkv';
import { StorageError } from '../utils/ErrorHandler';

class StorageService {
    private storage: MMKV;

    constructor() {
        this.storage = new MMKV();
    }

    /**
     * Set a value in storage
     */
    set<T>(key: string, value: T): void {
        try {
            const serialized = JSON.stringify(value);
            this.storage.set(key, serialized);
        } catch (error) {
            throw new StorageError(
                `Failed to save data for key: ${key}`,
                'STORAGE_SET_ERROR',
                error as Error
            );
        }
    }

    /**
     * Get a value from storage
     */
    get<T>(key: string): T | null {
        try {
            const value = this.storage.getString(key);
            if (!value) {
                return null;
            }
            return JSON.parse(value) as T;
        } catch (error) {
            throw new StorageError(
                `Failed to retrieve data for key: ${key}`,
                'STORAGE_GET_ERROR',
                error as Error
            );
        }
    }

    /**
     * Delete a value from storage
     */
    delete(key: string): void {
        try {
            this.storage.delete(key);
        } catch (error) {
            throw new StorageError(
                `Failed to delete data for key: ${key}`,
                'STORAGE_DELETE_ERROR',
                error as Error
            );
        }
    }

    /**
     * Clear all storage
     */
    clear(): void {
        try {
            this.storage.clearAll();
        } catch (error) {
            throw new StorageError(
                'Failed to clear storage',
                'STORAGE_CLEAR_ERROR',
                error as Error
            );
        }
    }

    /**
     * Check if a key exists
     */
    has(key: string): boolean {
        return this.storage.contains(key);
    }

    /**
     * Get all keys
     */
    getAllKeys(): string[] {
        return this.storage.getAllKeys();
    }
}

export const storageService = new StorageService();
