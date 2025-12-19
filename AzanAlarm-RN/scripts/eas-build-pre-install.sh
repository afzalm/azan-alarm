#!/bin/bash

# EAS Build Pre-Install Hook
# This script runs before the build starts on EAS Build servers
# It decodes the base64-encoded google-services.json from EAS Secrets

set -e

echo "🔥 Setting up Firebase configuration..."

# Check if we're on EAS Build (EAS sets this environment variable)
if [ "$EAS_BUILD" = "true" ]; then
    echo "📦 Running on EAS Build environment"
    
    # Android: google-services.json
    if [ -n "$GOOGLE_SERVICES_JSON_BASE64" ]; then
        echo "📄 Decoding google-services.json for Android..."
        echo "$GOOGLE_SERVICES_JSON_BASE64" | base64 --decode > ./android/app/google-services.json
        echo "✅ google-services.json placed successfully"
    else
        echo "⚠️  GOOGLE_SERVICES_JSON_BASE64 secret not found"
        echo "   Please add it using: eas secret:create --scope project --name GOOGLE_SERVICES_JSON_BASE64 --value \"\$(base64 -i ./google-services.json)\""
    fi
    
    # iOS: GoogleService-Info.plist (optional - for future iOS builds)
    if [ -n "$GOOGLE_SERVICE_INFO_PLIST_BASE64" ]; then
        echo "📄 Decoding GoogleService-Info.plist for iOS..."
        echo "$GOOGLE_SERVICE_INFO_PLIST_BASE64" | base64 --decode > ./ios/AzanAlarm/GoogleService-Info.plist
        echo "✅ GoogleService-Info.plist placed successfully"
    fi
else
    echo "🏠 Running locally - skipping Firebase config (should already exist)"
fi

echo "🔥 Firebase configuration complete!"
