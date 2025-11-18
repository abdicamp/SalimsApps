# Salims Apps

Aplikasi mobile Flutter untuk Quality Control dan Sampling Management System. Aplikasi ini membantu tim quality control dalam mengelola tugas sampling, melacak lokasi, dan mengelola data pengujian.

## 📱 Fitur Utama

### 1. **Authentication & Security**
- Login dengan username dan password
- Token-based authentication
- Auto-logout jika token expired
- Location permission handling

### 2. **Home Dashboard**
- Overview tugas dan notifikasi
- Quick access ke fitur utama
- Badge untuk notifikasi baru

### 3. **Task Management (Taking Sample)**
- Daftar tugas sampling
- Detail tugas dengan informasi lengkap
- Upload foto sampel
- Input parameter pengujian
- Tracking lokasi dengan Google Maps

### 4. **History**
- Riwayat tugas yang sudah diselesaikan
- Filter dan pencarian history
- Detail history lengkap

### 5. **Profile**
- Informasi akun pengguna
- Change password
- **Language Selection** (Indonesia & English)

### 6. **Notifications**
- Push notifications via Firebase Cloud Messaging
- Local notifications
- Background message handling

### 7. **Location Services**
- GPS tracking
- Location permission handling
- Geocoding untuk alamat
- Google Maps integration

## 🛠️ Teknologi yang Digunakan

### Core Framework
- **Flutter** 3.5.0+
- **Dart** SDK

### State Management
- **Stacked** - MVVM pattern
- **Provider** - Global state management

### Backend & API
- RESTful API integration
- HTTP client
- Token-based authentication

### Firebase Services
- **Firebase Core** - Firebase initialization
- **Firebase Cloud Messaging** - Push notifications
- **Firebase Local Notifications** - Local notifications

### Location & Maps
- **Geolocator** - GPS location services
- **Geocoding** - Address conversion
- **Google Maps Flutter** - Map display

### UI/UX
- **Google Fonts** - Custom typography
- **Flutter SVG** - SVG icons
- **Badges** - Notification badges
- **Dotted Border** - Custom borders

### Storage
- **Shared Preferences** - Local data storage

### Internationalization
- **Flutter Localizations** - Multi-language support
- **Intl** - Date/time formatting

### Utilities
- **Logger** - Logging system
- **Image Picker** - Photo capture
- **URL Launcher** - External links

## 📁 Struktur Project

```
lib/
├── core/
│   ├── api_response.dart          # API response wrapper
│   ├── models/                     # Data models
│   │   ├── login_models.dart
│   │   ├── task_list_models.dart
│   │   ├── sample_models.dart
│   │   └── ...
│   ├── services/
│   │   ├── api_services.dart      # API service
│   │   ├── language_service.dart  # Language management
│   │   └── local_storage_services.dart
│   ├── utils/
│   │   ├── app_localizations.dart  # Localization
│   │   ├── colors.dart
│   │   ├── style.dart
│   │   └── ...
│   └── widgets/
│       └── language_selector.dart  # Language selector widget
├── ui/
│   └── views/
│       ├── splash_screen/         # Splash screen
│       ├── login/                  # Login page
│       ├── home/                   # Home dashboard
│       ├── task_list/              # Task list
│       ├── detail_task/            # Task detail
│       ├── history/                # History
│       ├── profile/                # Profile & settings
│       └── bottom_navigator_view.dart
├── state_global/
│   ├── state_global.dart           # Global state
│   └── loading_overlay.dart       # Loading overlay
├── logger/
│   └── app_logger.dart            # Logger configuration
└── main.dart                       # App entry point
```

## 🚀 Getting Started

### Prerequisites

- Flutter SDK 3.5.0 or higher
- Dart SDK
- Android Studio / Xcode (untuk iOS)
- Firebase project setup

### Installation

1. **Clone repository**
   ```bash
   git clone <repository-url>
   cd SalimsApps
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Setup Firebase**
   - Pastikan file `google-services.json` (Android) sudah ada di `android/app/`
   - Pastikan file `GoogleService-Info.plist` (iOS) sudah ada di `ios/Runner/`
   - Konfigurasi Firebase di Firebase Console

4. **Setup API Base URL**
   - Edit `lib/core/services/api_services.dart`
   - Update `baseUrl` sesuai dengan API server Anda

5. **Run aplikasi**
   ```bash
   flutter run
   ```

## 🌐 Multi-Language Support

Aplikasi mendukung 2 bahasa:
- **Indonesia** (default)
- **English**

Untuk mengubah bahasa:
1. Buka halaman Profile
2. Scroll ke bagian "Bahasa" / "Language"
3. Pilih bahasa yang diinginkan

### Menambah Terjemahan Baru

Edit file `lib/core/utils/app_localizations.dart`:

```dart
static final Map<String, Map<String, String>> _localizedValues = {
  'id': {
    'newKey': 'Terjemahan Indonesia',
    // ...
  },
  'en': {
    'newKey': 'English Translation',
    // ...
  },
};
```

Kemudian tambahkan getter di class `AppLocalizations`:

```dart
String get newKey => _localizedValues[locale.languageCode]?['newKey'] ?? 'Default';
```

## 🔐 Authentication Flow

1. **Splash Screen**
   - Cek user data di local storage
   - Validasi token dengan API
   - Redirect ke Home atau Login

2. **Login**
   - Input username & password
   - Request location permission
   - Get FCM token
   - Call login API
   - Save user data & token

3. **Auto Logout**
   - Token validation di splash screen
   - Clear data jika token invalid

## 📍 Location Services

Aplikasi memerlukan izin lokasi untuk:
- Tracking lokasi saat mengambil sampel
- Menampilkan lokasi di Google Maps
- Geocoding alamat

Permission handling:
- Request permission saat login
- Handle denied permission
- Open settings jika permission denied forever

## 🔔 Push Notifications

### Setup
1. Firebase Cloud Messaging sudah dikonfigurasi
2. FCM token dikirim ke server saat login
3. Notifications ditangani di background dan foreground

### Features
- Background message handling
- Foreground notifications
- Local notifications
- Notification payload untuk navigation

## 🧪 Testing

```bash
# Run tests
flutter test

# Run with coverage
flutter test --coverage
```

## 📦 Build

### Android
```bash
flutter build apk --release
# atau
flutter build appbundle --release
```

### iOS
```bash
flutter build ios --release
```

## 🐛 Troubleshooting

### Location Permission Issues
- Pastikan permission sudah di-request
- Cek di device settings jika permission denied
- Restart aplikasi setelah enable permission

### Firebase Issues
- Pastikan `google-services.json` sudah benar
- Cek Firebase project configuration
- Pastikan FCM sudah di-enable di Firebase Console

### API Connection Issues
- Cek base URL di `api_services.dart`
- Pastikan device/emulator bisa akses internet
- Cek API server status

## 📝 Code Style

Project ini menggunakan:
- **Dart lint rules** dari `flutter_lints`
- **Null safety** - semua kode menggunakan null safety
- **MVVM pattern** dengan Stacked
- **Clean architecture** principles

## 👥 Contributing

1. Fork repository
2. Create feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to branch (`git push origin feature/AmazingFeature`)
5. Open Pull Request

## 📄 License

This project is private and proprietary.

## 📞 Support

Untuk pertanyaan atau support, silakan hubungi tim development.

---

**Version:** 1.0.0+1  
**Last Updated:** 2024
