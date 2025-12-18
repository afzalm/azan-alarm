export class AppError extends Error {
    constructor(
        message: string,
        public code?: string,
        public originalError?: Error
    ) {
        super(message);
        this.name = 'AppError';
    }
}

export class LocationError extends AppError {
    constructor(message: string, code?: string, originalError?: Error) {
        super(message, code, originalError);
        this.name = 'LocationError';
    }
}

export class StorageError extends AppError {
    constructor(message: string, code?: string, originalError?: Error) {
        super(message, code, originalError);
        this.name = 'StorageError';
    }
}

export class PermissionError extends AppError {
    constructor(message: string, code?: string, originalError?: Error) {
        super(message, code, originalError);
        this.name = 'PermissionError';
    }
}

export class NetworkError extends AppError {
    constructor(message: string, code?: string, originalError?: Error) {
        super(message, code, originalError);
        this.name = 'NetworkError';
    }
}

// Error handler utility
export const handleError = (error: unknown): AppError => {
    if (error instanceof AppError) {
        return error;
    }

    if (error instanceof Error) {
        return new AppError(error.message, undefined, error);
    }

    return new AppError('An unknown error occurred');
};

// User-friendly error messages
export const getErrorMessage = (error: AppError): string => {
    switch (error.name) {
        case 'LocationError':
            return 'Unable to get your location. Please check your location permissions.';
        case 'StorageError':
            return 'Failed to save data. Please try again.';
        case 'PermissionError':
            return 'Permission denied. Please enable permissions in settings.';
        case 'NetworkError':
            return 'Network error. Please check your internet connection.';
        default:
            return error.message || 'An error occurred. Please try again.';
    }
};
