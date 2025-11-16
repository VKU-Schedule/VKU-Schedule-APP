# Google Sign-In Configuration Guide

This guide explains how to configure Google Sign-In for the VKU Schedule app.

## Current Configuration Status

✅ **Android build.gradle** - Google Services plugin configured
✅ **iOS Info.plist** - URL scheme placeholder added
✅ **Placeholder files** - Template configuration files in place

⚠️ **Action Required**: Replace placeholder OAuth credentials with real values from Firebase Console

## Prerequisites

1. A Google Cloud Platform (GCP) project
2. Firebase project (recommended for easier setup)
3. Flutter development environment set up

## Setup Steps

### 1. Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Add project" or select existing project
3. Enter project name: `vku-schedule` (or your preferred name)
4. Follow the setup wizard to create the project

### 2. Configure Android App

#### 2.1 Add Android App to Firebase

1. In Firebase Console, click "Add app" and select Android
2. Enter package name: `com.vku.schedule`
3. Enter app nickname: `VKU Schedule Android` (optional)
4. Download `google-services.json`

#### 2.2 Replace Configuration File

Replace the placeholder file at `android/app/google-services.json` with your downloaded file.

The file should contain real values like:
```json
{
  "project_info": {
    "project_number": "123456789012",
    "project_id": "vku-schedule-xxxxx",
    "storage_bucket": "vku-schedule-xxxxx.appspot.com"
  },
  "client": [
    {
      "client_info": {
        "mobilesdk_app_id": "1:123456789012:android:abcdef123456",
        "android_client_info": {
          "package_name": "com.vku.schedule"
        }
      },
      "oauth_client": [
        {
          "client_id": "123456789012-xxxxxxxxxxxxxxxxxxxxxxxx.apps.googleusercontent.com",
          "client_type": 3
        }
      ],
      ...
    }
  ]
}
```

#### 2.3 Get SHA-1 Fingerprint

For debug builds:
```bash
cd android
./gradlew signingReport
```

Look for the SHA-1 under "Variant: debug" and "Config: debug". It looks like:
```
SHA1: A1:B2:C3:D4:E5:F6:G7:H8:I9:J0:K1:L2:M3:N4:O5:P6:Q7:R8:S9:T0
```

#### 2.4 Add SHA-1 to Firebase

1. In Firebase Console, go to Project Settings
2. Scroll to "Your apps" section
3. Click on your Android app
4. Click "Add fingerprint"
5. Paste the SHA-1 fingerprint
6. Click "Save"

**Note**: The Google Services plugin is already configured in:
- `android/build.gradle` - classpath added
- `android/app/build.gradle` - plugin applied

### 3. Configure iOS App

#### 3.1 Add iOS App to Firebase

1. In Firebase Console, click "Add app" and select iOS
2. Enter bundle ID: `com.vku.schedule`
3. Enter app nickname: `VKU Schedule iOS` (optional)
4. Download `GoogleService-Info.plist`

#### 3.2 Replace Configuration File

Replace the placeholder file at `ios/Runner/GoogleService-Info.plist` with your downloaded file.

The file should contain real values like:
```xml
<key>CLIENT_ID</key>
<string>123456789012-xxxxxxxxxxxxxxxxxxxxxxxx.apps.googleusercontent.com</string>
<key>REVERSED_CLIENT_ID</key>
<string>com.googleusercontent.apps.123456789012-xxxxxxxxxxxxxxxxxxxxxxxx</string>
<key>API_KEY</key>
<string>AIzaSyXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX</string>
```

#### 3.3 Update URL Scheme

The URL scheme is already configured in `ios/Runner/Info.plist`. You need to update it with your actual `REVERSED_CLIENT_ID`:

1. Open `ios/Runner/GoogleService-Info.plist`
2. Find the value for `REVERSED_CLIENT_ID` (e.g., `com.googleusercontent.apps.123456789012-xxxxx`)
3. Open `ios/Runner/Info.plist`
4. Find the `CFBundleURLSchemes` section
5. Replace `com.googleusercontent.apps.YOUR_REVERSED_CLIENT_ID` with your actual reversed client ID

The URL scheme section should look like:
```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleTypeRole</key>
        <string>Editor</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>com.googleusercontent.apps.123456789012-xxxxx</string>
        </array>
    </dict>
</array>
```

### 4. Configure OAuth Client IDs

#### 4.1 Automatic Client IDs

Firebase automatically creates OAuth 2.0 client IDs when you add apps:
- **Android Client ID**: Created when you add Android app
- **iOS Client ID**: Created when you add iOS app

You can view these in:
- Firebase Console: Project Settings > Your apps
- GCP Console: APIs & Services > Credentials

#### 4.2 Web Client ID (Required for Backend)

The backend server needs a Web Client ID for token validation:

1. Go to [GCP Console](https://console.cloud.google.com/)
2. Select your Firebase project
3. Navigate to APIs & Services > Credentials
4. Click "Create Credentials" > "OAuth 2.0 Client ID"
5. Select "Web application"
6. Enter name: `VKU Schedule Web Client`
7. Add authorized redirect URIs (if needed for backend)
8. Click "Create"
9. Copy the Client ID - this will be used in `google-services.json` under `other_platform_oauth_client`

#### 4.3 Update Configuration Files

After creating the Web Client ID, update `android/app/google-services.json`:
```json
"appinvite_service": {
  "other_platform_oauth_client": [
    {
      "client_id": "YOUR_WEB_CLIENT_ID.apps.googleusercontent.com",
      "client_type": 3
    }
  ]
}
```

### 5. Enable Required APIs

1. Go to [GCP Console](https://console.cloud.google.com/)
2. Select your project
3. Navigate to APIs & Services > Library
4. Enable the following APIs:
   - **Google Sign-In API** (or Google Identity Toolkit API)
   - **Google Calendar API** (for calendar sync feature)
   - **Google People API** (for profile information)

### 6. Verify Configuration

#### 6.1 Check Files

Ensure these files have real values (not placeholders):
- ✅ `android/app/google-services.json`
- ✅ `ios/Runner/GoogleService-Info.plist`
- ✅ `ios/Runner/Info.plist` (URL scheme updated)

#### 6.2 Test the App

```bash
# Clean build
flutter clean
flutter pub get

# Run on Android
flutter run -d android

# Run on iOS
flutter run -d ios
```

#### 6.3 Test Sign-In Flow

1. Launch the app
2. Tap "Sign in with Google"
3. Select a Google account
4. Grant permissions
5. Verify successful authentication

## Troubleshooting

### Android Issues

- **PlatformException(sign_in_failed)**: Check SHA-1 fingerprint is added to Firebase
- **ApiException: 10**: OAuth client ID mismatch, verify package name

### iOS Issues

- **Error 1000**: URL scheme not configured correctly in Info.plist
- **No client ID found**: GoogleService-Info.plist not added to Xcode project

### Common Issues

- **Network error**: Check internet connection and API is enabled
- **Invalid client**: Verify OAuth client IDs match in Firebase Console

## Security Notes

- Never commit real `google-services.json` or `GoogleService-Info.plist` to public repositories
- Add these files to `.gitignore` if needed
- Use environment-specific configurations for dev/staging/prod

## References

- [Google Sign-In for Flutter](https://pub.dev/packages/google_sign_in)
- [Firebase Console](https://console.firebase.google.com/)
- [GCP Console](https://console.cloud.google.com/)
