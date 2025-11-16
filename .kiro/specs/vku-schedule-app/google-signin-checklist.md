# Google Sign-In Configuration Checklist

## Quick Setup Guide

This checklist helps you configure Google Sign-In for the VKU Schedule app.

### ✅ Already Configured

- [x] Android Google Services plugin added to `android/build.gradle`
- [x] Android Google Services plugin applied in `android/app/build.gradle`
- [x] iOS URL scheme placeholder added to `ios/Runner/Info.plist`
- [x] Placeholder configuration files in place
- [x] Internet permission added to Android manifest

### ⚠️ Required Actions

#### 1. Firebase Project Setup

- [ ] Create Firebase project at https://console.firebase.google.com/
- [ ] Note your project ID: `________________`

#### 2. Android Configuration

- [ ] Add Android app to Firebase (package: `com.vku.schedule`)
- [ ] Download `google-services.json` from Firebase Console
- [ ] Replace `android/app/google-services.json` with downloaded file
- [ ] Get SHA-1 fingerprint: `cd android && ./gradlew signingReport`
- [ ] Add SHA-1 to Firebase Console (Project Settings > Your apps > Android)

#### 3. iOS Configuration

- [ ] Add iOS app to Firebase (bundle ID: `com.vku.schedule`)
- [ ] Download `GoogleService-Info.plist` from Firebase Console
- [ ] Replace `ios/Runner/GoogleService-Info.plist` with downloaded file
- [ ] Copy `REVERSED_CLIENT_ID` value from `GoogleService-Info.plist`
- [ ] Update URL scheme in `ios/Runner/Info.plist`:
  - Find: `com.googleusercontent.apps.YOUR_REVERSED_CLIENT_ID`
  - Replace with your actual reversed client ID

#### 4. OAuth Client IDs

- [ ] Verify Android OAuth client ID created (automatic)
- [ ] Verify iOS OAuth client ID created (automatic)
- [ ] Create Web OAuth client ID in GCP Console
- [ ] Update `google-services.json` with Web client ID in `other_platform_oauth_client`

#### 5. Enable APIs

Go to GCP Console > APIs & Services > Library and enable:
- [ ] Google Sign-In API (or Google Identity Toolkit API)
- [ ] Google Calendar API
- [ ] Google People API

#### 6. Test Configuration

- [ ] Run `flutter clean && flutter pub get`
- [ ] Test on Android: `flutter run -d android`
- [ ] Test on iOS: `flutter run -d ios`
- [ ] Verify Google Sign-In button appears
- [ ] Test sign-in flow with a Google account

## Configuration Files Summary

### android/app/google-services.json
Replace these placeholder values:
- `YOUR_PROJECT_NUMBER` → Your Firebase project number (e.g., `123456789012`)
- `YOUR_APP_ID` → Your Android app ID from Firebase
- `YOUR_CLIENT_ID` → Your Android OAuth client ID
- `YOUR_API_KEY` → Your Android API key
- `YOUR_WEB_CLIENT_ID` → Your Web OAuth client ID

### ios/Runner/GoogleService-Info.plist
Replace these placeholder values:
- `YOUR_IOS_CLIENT_ID` → Your iOS OAuth client ID
- `YOUR_REVERSED_CLIENT_ID` → Your reversed client ID (for URL scheme)
- `YOUR_API_KEY` → Your iOS API key
- `YOUR_PROJECT_NUMBER` → Your Firebase project number
- `YOUR_APP_ID` → Your iOS app ID from Firebase

### ios/Runner/Info.plist
Update the URL scheme:
```xml
<string>com.googleusercontent.apps.YOUR_REVERSED_CLIENT_ID</string>
```
Replace `YOUR_REVERSED_CLIENT_ID` with the actual value from `GoogleService-Info.plist`

## Troubleshooting

### Android: PlatformException(sign_in_failed)
- Verify SHA-1 fingerprint is added to Firebase Console
- Check package name matches: `com.vku.schedule`
- Ensure `google-services.json` is in `android/app/` directory

### iOS: Error 1000
- Verify URL scheme in `Info.plist` matches `REVERSED_CLIENT_ID`
- Check bundle ID matches: `com.vku.schedule`
- Ensure `GoogleService-Info.plist` is added to Xcode project

### Common: Network Error
- Check internet connection
- Verify APIs are enabled in GCP Console
- Check API keys are valid

## Security Notes

⚠️ **Important**: 
- Never commit real OAuth credentials to public repositories
- Consider adding `google-services.json` and `GoogleService-Info.plist` to `.gitignore`
- Use different Firebase projects for dev/staging/production environments

## References

- [Firebase Console](https://console.firebase.google.com/)
- [GCP Console](https://console.cloud.google.com/)
- [Google Sign-In Flutter Package](https://pub.dev/packages/google_sign_in)
- [Full Setup Guide](../../../GOOGLE_SIGNIN_SETUP.md)
