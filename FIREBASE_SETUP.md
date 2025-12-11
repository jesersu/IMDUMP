# Firebase Integration Setup Guide

This guide will help you set up Firebase Remote Config for the IMDUMB iOS app.

## Prerequisites

- A Google account
- Xcode with the IMDUMB project open
- The Firebase iOS SDK is already integrated via Swift Package Manager

## Step 1: Create a Firebase Project

1. Go to the [Firebase Console](https://console.firebase.google.com/)
2. Click **Add project** or select an existing project
3. Enter a project name (e.g., "IMDUMB")
4. Follow the prompts to create your project

## Step 2: Add iOS App to Firebase Project

1. In the Firebase Console, click the iOS icon to add an iOS app
2. Register your app with the following details:
   - **iOS bundle ID**: `com.yourcompany.IMDUMB` (match this with your Xcode project's bundle ID)
   - **App nickname** (optional): IMDUMB
   - **App Store ID** (optional): Leave blank for now

3. Click **Register app**

## Step 3: Download GoogleService-Info.plist

1. Download the `GoogleService-Info.plist` file from Firebase Console
2. **IMPORTANT**: Do NOT rename this file
3. Add the file to your Xcode project:
   - Open Xcode
   - Drag and drop `GoogleService-Info.plist` into the project navigator
   - Make sure it's at the root level alongside `Info.plist`
   - Check **Copy items if needed**
   - Ensure the target "IMDUMB" is selected
   - Click **Finish**

## Step 4: Verify .gitignore

The `.gitignore` file already excludes `GoogleService-Info.plist` to prevent committing sensitive data:

```
# Firebase
GoogleService-Info.plist
```

**Never commit this file to version control!**

## Step 5: Set Up Firebase Remote Config

1. In the Firebase Console, navigate to **Remote Config** (under Engage section)
2. Click **Create configuration**
3. Add the following parameters:

### Required Parameters:

| Parameter Key | Default Value | Type |
|--------------|---------------|------|
| `api_base_url` | `https://api.themoviedb.org/3` | String |
| `api_key` | *(Your TMDB API Key)* | String |
| `welcome_message` | `Welcome to IMDUMB!` | String |
| `dark_mode` | `true` | Boolean |
| `recommendations` | `true` | Boolean |
| `social_sharing` | `false` | Boolean |

### Adding Each Parameter:

1. Click **Add parameter**
2. Enter the **Parameter key**
3. Set the **Default value**
4. Click **Save**

### Example for `api_key`:

- **Parameter key**: `api_key`
- **Default value**: Your TMDB API key from [themoviedb.org](https://www.themoviedb.org/settings/api)
- **Data type**: String

## Step 6: Publish Remote Config

1. After adding all parameters, click **Publish changes**
2. Add a description like "Initial configuration"
3. Click **Publish**

## Step 7: Build and Run

1. Open the project in Xcode
2. **Important**: If you see "Missing package product" errors:
   - File → Packages → Reset Package Caches
   - File → Packages → Resolve Package Versions
   - Wait for package resolution to complete
3. Build the project (`Cmd + B`)
4. If the build succeeds, run the app (`Cmd + R`)
5. The app should now:
   - Initialize Firebase on startup
   - Fetch Remote Config values during the splash screen
   - Use the configuration throughout the app

## Troubleshooting

### Build Error: "No such module 'FirebaseCore'"

- Make sure Xcode has finished downloading the Firebase SDK packages
- Try: Product → Clean Build Folder (`Cmd + Shift + K`), then rebuild
- Check: File → Packages → Resolve Package Versions

### Build Error: "Missing package product"

- Close Xcode completely
- Delete derived data: `rm -rf ~/Library/Developer/Xcode/DerivedData/*`
- Reopen Xcode and wait for packages to resolve

### Runtime Error: "FirebaseApp.configure() failed"

- Verify `GoogleService-Info.plist` is in the project
- Check that the bundle ID in Xcode matches the one in Firebase Console
- Ensure the file is added to the IMDUMB target

### Remote Config Not Loading

- Check your internet connection
- The app falls back to default values if Remote Config fails
- Check Xcode console for Firebase logs

### Testing Remote Config

To verify Remote Config is working:

1. Check the Xcode console for:
   ```
   Firebase Remote Config: fetched from remote
   ```
   or
   ```
   Firebase Remote Config: using cached data
   ```
2. The splash screen should display the `welcome_message` from Remote Config
3. Try changing a value in Firebase Console and republish
4. Restart the app to see the updated value

## Using Remote Config Values

The app fetches configuration during the splash screen via `FirebaseConfigDataStore`. Values are accessible through:

- `ConfigRepository` → `LoadConfigurationUseCase` → `SplashPresenter`
- Default values are used if fetch fails
- Configuration is cached by Firebase for offline use

## Security Best Practices

1. **Never commit** `GoogleService-Info.plist` to version control
2. For sensitive API keys, consider:
   - Using Firebase Remote Config with restricted access
   - Implementing server-side API proxies
   - Using Arkana for additional local encryption (already set up)
3. Set up Firebase App Check to prevent unauthorized API access
4. Use different Firebase projects for development and production
5. In production, change `minimumFetchInterval` from `0` to `3600` (1 hour) in `FirebaseConfigDataStore.swift:27`

## Additional Resources

- [Firebase iOS Documentation](https://firebase.google.com/docs/ios/setup)
- [Firebase Remote Config Guide](https://firebase.google.com/docs/remote-config)
- [TMDB API Documentation](https://developers.themoviedb.org/3)

## Already Integrated

✅ Firebase iOS SDK 11.0+ added via Swift Package Manager
✅ FirebaseCore and FirebaseRemoteConfig configured
✅ AppDelegate initializes Firebase on app launch
✅ FirebaseConfigDataStore implements Remote Config fetching
✅ Splash screen loads configuration on startup
✅ Default values configured for offline/fallback use

**You just need to add the `GoogleService-Info.plist` file and configure Remote Config values in Firebase Console!**
