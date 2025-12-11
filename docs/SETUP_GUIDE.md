# Setup Guide

Panduan lengkap untuk setup dan development aplikasi Salims Apps.

## 📋 Prerequisites

### Required Software

1. **Flutter SDK**
   - Version: 3.5.0 or higher
   - Download: https://flutter.dev/docs/get-started/install
   - Verify: `flutter --version`

2. **Dart SDK**
   - Included dengan Flutter
   - Verify: `dart --version`

3. **IDE**
   - **Android Studio** (Recommended)
     - Download: https://developer.android.com/studio
     - Install Flutter & Dart plugins
   - **VS Code** (Alternative)
     - Download: https://code.visualstudio.com/
     - Install Flutter extension

4. **Platform-specific Tools**

   **Android:**
   - Android SDK
   - Android Studio dengan Android SDK
   - Android Emulator atau physical device

   **iOS (macOS only):**
   - Xcode (latest version)
   - CocoaPods: `sudo gem install cocoapods`
   - iOS Simulator atau physical device

### Required Accounts

1. **Firebase Account**
   - Create project di https://console.firebase.google.com
   - Enable Cloud Messaging
   - Download configuration files

2. **API Access**
   - Base URL: `https://api-salims.chemitechlogilab.com/v1`
   - Valid credentials untuk testing

## 🚀 Initial Setup

### Step 1: Clone Repository

```bash
git clone <repository-url>
cd SalimsApps
```

### Step 2: Install Dependencies

```bash
flutter pub get
```

### Step 3: Firebase Setup

#### Android

1. Download `google-services.json` dari Firebase Console
2. Place file di: `android/app/google-services.json`
3. Pastikan file sudah ada di project

#### iOS

1. Download `GoogleService-Info.plist` dari Firebase Console
2. Place file di: `ios/Runner/GoogleService-Info.plist`
3. Buka Xcode project: `ios/Runner.xcworkspace`
4. Drag file ke Xcode project (pastikan "Copy items if needed" checked)

### Step 4: Configure API

Edit `lib/core/services/api_services.dart`:

```dart
class ApiService {
  final String baseUrl = "https://api-salims.chemitechlogilab.com/v1";
  // ... rest of code
}
```

Update base URL jika diperlukan.

### Step 5: Run Application

```bash
# List available devices
flutter devices

# Run on specific device
flutter run

# Run in release mode
flutter run --release
```

## 🔧 Development Setup

### Enable Null Safety

Project sudah menggunakan null safety. Pastikan:
- Dart SDK >= 2.12.0
- Semua dependencies support null safety

### Code Formatting

```bash
# Format code
flutter format .

# Analyze code
flutter analyze
```

### Hot Reload

- Press `r` di terminal untuk hot reload
- Press `R` untuk hot restart
- Press `q` untuk quit

## 📱 Platform-Specific Setup

### Android

#### Minimum SDK Version

Edit `android/app/build.gradle.kts`:

```kotlin
android {
    defaultConfig {
        minSdkVersion 21  // Minimum Android 5.0
        targetSdkVersion 33
    }
}
```

#### Permissions

Edit `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
<uses-permission android:name="android.permission.CAMERA"/>
```

#### Google Maps API Key

1. Get API key dari Google Cloud Console
2. Edit `android/app/src/main/AndroidManifest.xml`:

```xml
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="YOUR_API_KEY"/>
```

### iOS

#### Minimum iOS Version

Edit `ios/Podfile`:

```ruby
platform :ios, '12.0'
```

#### Permissions

Edit `ios/Runner/Info.plist`:

```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>We need your location to track sampling location</string>
<key>NSCameraUsageDescription</key>
<string>We need camera access to take sample photos</string>
```

#### Google Maps API Key

1. Get API key dari Google Cloud Console
2. Edit `ios/Runner/AppDelegate.swift`:

```swift
GMSServices.provideAPIKey("YOUR_API_KEY")
```

## 🧪 Testing Setup

### Run Tests

```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/widget_test.dart

# Run with coverage
flutter test --coverage
```

### Test Coverage

```bash
# Generate coverage report
flutter test --coverage

# View coverage (install lcov first)
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

## 📦 Build Setup

### Android APK

```bash
# Debug APK
flutter build apk

# Release APK
flutter build apk --release

# Split APK by ABI
flutter build apk --split-per-abi
```

### Android App Bundle

```bash
flutter build appbundle --release
```

### iOS

```bash
# Build for iOS
flutter build ios --release

# Open in Xcode
open ios/Runner.xcworkspace
```

## 🔐 Environment Variables

Untuk production, pertimbangkan menggunakan environment variables:

1. Create `.env` file (add to `.gitignore`)
2. Use `flutter_dotenv` package
3. Store sensitive data (API keys, etc.)

Example:
```dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

final apiKey = dotenv.env['API_KEY'];
```

## 🐛 Debugging

### Enable Debug Logging

Logger sudah dikonfigurasi di project. Untuk melihat logs:

```dart
var logger = Logger(
  printer: PrettyPrinter(
    methodCount: 2,
    errorMethodCount: 5,
    lineLength: 80,
    colors: true,
    printEmojis: true,
    printTime: true,
  ),
);

logger.d("Debug message");
logger.i("Info message");
logger.w("Warning message");
logger.e("Error message", error: e);
```

### Flutter DevTools

```bash
# Start DevTools
flutter pub global activate devtools
flutter pub global run devtools
```

## 📝 Common Issues & Solutions

### Issue: Gradle Build Failed

**Solution:**
```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
```

### Issue: CocoaPods Error (iOS)

**Solution:**
```bash
cd ios
pod deintegrate
pod install
cd ..
```

### Issue: Location Permission Not Working

**Solution:**
- Check permissions di `AndroidManifest.xml` / `Info.plist`
- Restart aplikasi setelah grant permission
- Check device settings

### Issue: Firebase Not Initialized

**Solution:**
- Verify `google-services.json` / `GoogleService-Info.plist` sudah benar
- Check Firebase project configuration
- Verify package name/bundle ID matches Firebase project

### Issue: API Connection Failed

**Solution:**
- Check internet connection
- Verify base URL di `api_services.dart`
- Check API server status
- Verify SSL certificate (untuk HTTPS)

## 🔄 Update Dependencies

```bash
# Check outdated packages
flutter pub outdated

# Update packages
flutter pub upgrade

# Update to latest compatible versions
flutter pub upgrade --major-versions
```

## 📚 Additional Resources

- [Flutter Documentation](https://flutter.dev/docs)
- [Dart Documentation](https://dart.dev/guides)
- [Stacked Documentation](https://stacked.filledstacks.com/)
- [Firebase Documentation](https://firebase.google.com/docs)

## 💡 Tips

1. **Use VS Code/Android Studio Flutter extensions** untuk better development experience
2. **Enable Flutter Inspector** untuk UI debugging
3. **Use Flutter DevTools** untuk performance profiling
4. **Keep dependencies updated** untuk security patches
5. **Test on real devices** sebelum release
6. **Use version control** (Git) untuk track changes

---

**Last Updated:** 2024

