# Architecture Documentation

Dokumentasi arsitektur aplikasi Salims Apps.

## Architecture Pattern

Aplikasi menggunakan **MVVM (Model-View-ViewModel)** pattern dengan library **Stacked**.

### Pattern Overview

```
┌─────────────┐
│    View     │  (UI Layer)
└──────┬──────┘
       │
       │ Uses
       ▼
┌─────────────┐
│ ViewModel   │  (Business Logic)
└──────┬──────┘
       │
       │ Uses
       ▼
┌─────────────┐
│   Service   │  (Data Layer)
└──────┬──────┘
       │
       │ Uses
       ▼
┌─────────────┐
│    Model    │  (Data Models)
└─────────────┘
```

## Layer Structure

### 1. View Layer (`lib/ui/views/`)

**Responsibility:**
- Menampilkan UI
- Menangani user interaction
- Binding dengan ViewModel

**Pattern:**
- StatefulWidget atau StatelessWidget
- Menggunakan `ViewModelBuilder` dari Stacked
- Tidak mengandung business logic

**Example:**
```dart
class HomeView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<HomeViewModel>.reactive(
      viewModelBuilder: () => HomeViewModel(),
      builder: (context, viewModel, child) {
        return Scaffold(
          // UI code
        );
      },
    );
  }
}
```

### 2. ViewModel Layer (`lib/ui/views/*/viewmodel.dart`)

**Responsibility:**
- Business logic
- State management
- API calls melalui Service
- Data transformation

**Pattern:**
- Extends `FutureViewModel` atau `BaseViewModel` dari Stacked
- Menggunakan `setBusy()` untuk loading state
- Menggunakan `notifyListeners()` untuk update UI

**Example:**
```dart
class HomeViewModel extends FutureViewModel {
  final ApiService _apiService = ApiService();
  
  Future<void> loadData() async {
    setBusy(true);
    try {
      // Business logic
    } finally {
      setBusy(false);
    }
  }
  
  @override
  Future futureToRun() => loadData();
}
```

### 3. Service Layer (`lib/core/services/`)

**Responsibility:**
- API communication
- Local storage
- External services integration

**Services:**
- `ApiService` - HTTP requests
- `LocalStorageService` - SharedPreferences
- `LanguageService` - Language management

### 4. Model Layer (`lib/core/models/`)

**Responsibility:**
- Data structure
- JSON serialization/deserialization

**Pattern:**
- Dart classes dengan `fromJson()` dan `toJson()`

## State Management

### Global State

Menggunakan **Provider** untuk global state:

```dart
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => GlobalLoadingState()),
    ChangeNotifierProvider(create: (_) => LanguageService()),
  ],
  child: MyApp(),
)
```

### Local State

Menggunakan **Stacked ViewModel** untuk local state per screen.

## Dependency Injection

Saat ini menggunakan direct instantiation. Untuk scale lebih besar, bisa menggunakan:
- `get_it`
- `injectable`
- Stacked's dependency injection

## Navigation

Menggunakan Flutter's default navigation:
- `Navigator.push()`
- `Navigator.pushReplacement()`
- `MaterialPageRoute`

## Error Handling

### API Errors

```dart
try {
  final result = await _apiService.login(...);
  if (result.data != null) {
    // Success
  } else {
    // Handle error
    showError(result.error);
  }
} catch (e) {
  // Handle exception
}
```

### Null Safety

Semua kode menggunakan null safety:
- Nullable types dengan `?`
- Null checks sebelum penggunaan
- Null coalescing operator `??`

## Code Organization

### File Naming Convention

- Views: `{feature}_view.dart`
- ViewModels: `{feature}_viewmodel.dart`
- Models: `{feature}_models.dart`
- Services: `{feature}_services.dart`
- Utils: `{feature}.dart`

### Folder Structure

```
lib/
├── core/           # Core functionality
│   ├── models/     # Data models
│   ├── services/   # Business services
│   ├── utils/      # Utilities
│   └── widgets/    # Reusable widgets
├── ui/             # UI layer
│   └── views/      # Screen views
├── state_global/   # Global state
└── main.dart       # Entry point
```

## Best Practices

### 1. Separation of Concerns
- View hanya untuk UI
- ViewModel untuk business logic
- Service untuk data access

### 2. Error Handling
- Selalu wrap async operations dengan try-catch
- Provide user-friendly error messages
- Log errors untuk debugging

### 3. Null Safety
- Always check null sebelum penggunaan
- Use null-aware operators
- Provide default values

### 4. Code Reusability
- Extract common widgets
- Create utility functions
- Use mixins untuk shared functionality

### 5. Performance
- Use `const` constructors where possible
- Avoid unnecessary rebuilds
- Lazy load data

## Testing Strategy

### Unit Tests
- Test ViewModels
- Test Services
- Test Utils

### Widget Tests
- Test UI components
- Test user interactions

### Integration Tests
- Test complete flows
- Test API integration

## Future Improvements

1. **Dependency Injection**
   - Implement proper DI
   - Use get_it or injectable

2. **State Management**
   - Consider Riverpod or Bloc
   - Better state management for complex flows

3. **Code Generation**
   - Use json_serializable
   - Use build_runner

4. **Error Handling**
   - Centralized error handling
   - Error tracking (Sentry)

5. **Testing**
   - Increase test coverage
   - Add integration tests

