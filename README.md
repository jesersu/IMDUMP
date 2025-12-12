# IMDUMB - iOS Movie Database App

[![CI](https://github.com/jesersu/IMDUMP/actions/workflows/ci.yml/badge.svg)](https://github.com/jesersu/IMDUMP/actions/workflows/ci.yml)
[![Build](https://github.com/jesersu/IMDUMP/actions/workflows/build.yml/badge.svg)](https://github.com/jesersu/IMDUMP/actions/workflows/build.yml)

IMDUMB is an iOS application that displays movie categories and details, built with **MVP + Clean Architecture** pattern. The app demonstrates professional iOS development practices including proper separation of concerns, SOLID principles, UIKit with XIB-based interface design, **encrypted secrets management with Arkana**, and **CI/CD with Fastlane & GitHub Actions**.

## 🔐 Security Features

- **Arkana Integration** - API keys and sensitive data are encrypted using Arkana
- **Environment-based Configuration** - Different settings for Debug/Release builds
- **Type-Safe Secrets** - Compile-time safety when accessing encrypted keys
- **Firebase Remote Config** - Dynamic configuration management without app updates
- See [ARKANA_SETUP.md](ARKANA_SETUP.md) for Arkana setup instructions
- See [FIREBASE_SETUP.md](FIREBASE_SETUP.md) for Firebase integration guide

## 📱 Features

- **Splash Screen** with Firebase configuration loading
- **Categories Screen** displaying movies organized by category (Popular, Top Rated, Upcoming, Now Playing)
- **Unique UI Pattern**: UICollectionView with UITableView inside each cell
- **Offline Support**:
  - CoreData caching with 24-hour TTL
  - Cache-first strategy with background refresh
  - Toast notification when viewing cached data offline
  - Automatic migration from UserDefaults to CoreData
- **Reactive Programming**:
  - RxSwift for all async operations
  - Single<T> pattern for one-time operations
  - DisposeBag for automatic memory management
  - MainScheduler for thread-safe UI updates
- **Movie Detail Screen** featuring:
  - Horizontal image carousel with pagination
  - Movie title, rating, and HTML-formatted description
  - Cast list in horizontal scrolling collection
  - Fixed bottom "Recomendar" (Recommend) button
- **Recommendation Modal** with:
  - Dynamic height that adjusts to content
  - Movie description display
  - Comment text field
  - Confirmation functionality

## 🏗️ Architecture

The project follows **Clean Architecture** principles with **MVP (Model-View-Presenter)** pattern:

```
IMDUMB/
├── Domain/                  # Business logic layer
│   ├── Entities/           # Domain models (Movie, Actor, Category)
│   ├── Repositories/       # Repository protocols
│   └── UseCases/           # Use cases (GetCategories, GetMovieDetails, LoadConfiguration)
├── Data/                   # Data layer
│   ├── DTOs/              # Data Transfer Objects
│   ├── DataStores/        # Data source implementations
│   │   ├── RemoteMovieDataStore.swift
│   │   ├── MockMovieDataStore.swift
│   │   └── FirebaseConfigDataStore.swift
│   └── Repositories/      # Repository implementations
├── Presentation/          # UI layer
│   ├── Splash/           # Splash screen (MVP)
│   ├── Categories/       # Categories screen (MVP)
│   ├── MovieDetail/      # Movie detail screen (MVP)
│   └── Recommendation/   # Recommendation modal
└── Core/                  # Shared utilities
    ├── Network/           # Network service
    ├── Protocols/         # Base protocols
    └── Extensions/        # Utility extensions
```

## 🎯 SOLID Principles Implementation

The codebase demonstrates SOLID principles throughout:

### 1. **Single Responsibility Principle (SRP)**
- **Location**: `IMDUMB/Domain/Entities/Movie.swift:5`
  ```swift
  // SOLID: Single Responsibility Principle - This struct only represents movie data
  struct Movie { ... }
  ```
- Each class/struct has one clear responsibility
- Presenters handle business logic, Views handle UI, UseCases handle domain operations

### 2. **Open/Closed Principle (OCP)**
- **Location**: `IMDUMB/Data/DataStores/MockMovieDataStore.swift:5`
  ```swift
  // SOLID: Open/Closed Principle - Open for extension (different implementations), closed for modification
  protocol MovieDataStoreProtocol { ... }
  ```
- Data stores can be extended with new implementations without modifying existing code
- Protocol-based design allows for multiple implementations (Remote, Mock, Local)

### 3. **Liskov Substitution Principle (LSP)**
- **Location**: `IMDUMB/Data/DataStores/MockMovieDataStore.swift:7`
  ```swift
  // SOLID: Liskov Substitution Principle - Can substitute RemoteMovieDataStore without breaking functionality
  class MockMovieDataStore: MovieDataStoreProtocol { ... }
  ```
- MockMovieDataStore can replace RemoteMovieDataStore seamlessly
- All DataStore implementations are interchangeable

### 4. **Interface Segregation Principle (ISP)**
- **Location**: `IMDUMB/Domain/Repositories/MovieRepositoryProtocol.swift:5`
  ```swift
  // SOLID: Interface Segregation Principle - Specific interface for movie operations
  protocol MovieRepositoryProtocol { ... }
  ```
- Protocols are focused and specific to their domain
- BaseViewProtocol provides minimal interface for views

### 5. **Dependency Inversion Principle (DIP)**
- **Location**: `IMDUMB/Domain/UseCases/GetCategoriesUseCase.swift:9`
  ```swift
  // SOLID: Dependency Inversion - Depends on abstraction (protocol), not concrete implementation
  init(repository: MovieRepositoryProtocol) { ... }
  ```
- High-level modules depend on abstractions (protocols)
- Dependency injection is used throughout the app

## 🛠️ Tech Stack

- **Language**: Swift 5.0
- **Minimum iOS Version**: 15.0
- **UI Framework**: UIKit with XIB files (no SwiftUI, no programmatic views)
- **Architecture**: MVP + Clean Architecture
- **Reactive Programming**: RxSwift 6.9.1 for asynchronous operations and data streams
- **Networking**: Alamofire 5.10.2 for HTTP requests and image loading
- **Dependency Management**: Swift Package Manager (SPM)
- **Persistence**: CoreData for offline caching (IMDUMBPersistence package)
- **Firebase**: Firebase Remote Config for dynamic configuration

## 📦 Dependencies

Dependencies are managed via Swift Package Manager:

- **Arkana** - Secrets encryption and management (Ruby gem)
- **Alamofire 5.10.2** - HTTP networking and async image loading
- **RxSwift 6.9.1** - Reactive programming for async operations
  - RxSwift - Core reactive extensions
  - RxCocoa - UIKit reactive extensions
  - RxBlocking - Synchronous testing support
- **Firebase iOS SDK 11.15.0** - Remote Config for dynamic configuration
- **IMDUMBPersistence** - Local Swift Package for CoreData caching

## 🚀 Installation & Setup

### Prerequisites

- Xcode 16.0 or later
- macOS with iOS development tools
- Git
- Ruby (for Arkana - comes with macOS)

### Steps

1. **Clone the repository**
   ```bash
   git clone https://github.com/jesersu/IMDUMP.git
   cd IMDUMB
   ```

2. **Install Arkana** (for encrypted secrets)
   ```bash
   gem install arkana
   ```

3. **Configure API Keys** (Recommended - Use Arkana)
   ```bash
   # Copy the sample environment file
   cp .env.sample .env

   # Edit .env and add your TMDB API key
   # Get your key from: https://www.themoviedb.org/settings/api

   # Generate encrypted secrets
   arkana -e .env
   ```

   See [ARKANA_SETUP.md](ARKANA_SETUP.md) for detailed instructions.

4. **Open the project**
   ```bash
   open IMDUMB.xcodeproj
   ```

4. **Configure Firebase** (Required for full functionality)
   - Follow the detailed guide in [FIREBASE_SETUP.md](FIREBASE_SETUP.md)
   - Download `GoogleService-Info.plist` from Firebase Console
   - Add it to the project root in Xcode
   - Set up Remote Config parameters in Firebase Console
   - Note: The file is excluded from git via .gitignore

5. **Build and Run**
   - Select a simulator or device
   - Press `Cmd + R` or click the Run button
   - The app will launch with the splash screen

### Running with Mock Data

The app is currently configured to use `MockMovieDataStore` for development. To test without API keys:

- File: `IMDUMB/Presentation/Categories/CategoriesViewController.swift:59`
- The app uses mock data by default, so it works immediately without configuration

### Switching to Real API

To use the real TMDB API:

1. Get a free API key from [TMDB](https://www.themoviedb.org/settings/api)
2. Update the NetworkService with your API key
3. Change data store in `CategoriesViewController.swift:59`:
   ```swift
   // Change from:
   let dataStore = MockMovieDataStore()
   // To:
   let dataStore = RemoteMovieDataStore()
   ```

## 📡 API Endpoints

The app uses The Movie Database (TMDB) API:

### Base URL
```
https://api.themoviedb.org/3
```

### Endpoints Used

| Endpoint | Description |
|----------|-------------|
| `/movie/popular` | Popular movies |
| `/movie/top_rated` | Top rated movies |
| `/movie/upcoming` | Upcoming movies |
| `/movie/now_playing` | Now playing movies |
| `/movie/{id}` | Movie details |
| `/movie/{id}/credits` | Movie cast |
| `/movie/{id}/images` | Movie images |

## 🧪 Testing

### DataStore Implementations

The app includes multiple DataStore implementations for testing:

- **MockMovieDataStore**: Provides sample data without network calls
- **RemoteMovieDataStore**: Fetches data from TMDB API
- **LocalDataStore**: (Future) For offline caching with CoreData/Realm

### Unit Tests

The project includes comprehensive unit tests covering core components:

**Test Coverage:**
- ✅ **Use Cases** (8 tests): GetCategoriesUseCase, GetMovieDetailsUseCase
- ✅ **Repositories** (4 tests): MovieRepository DTO mapping and error handling
- ✅ **Presenters** (4 tests): CategoriesPresenter view lifecycle and state management
- ✅ **DataStores** (8 tests): MockMovieDataStore data quality validation
- ✅ **Extensions** (10 tests): String+HTML parsing and edge cases

**Total: 34 unit tests**

**Running Tests:**

1. In Xcode: Press `Cmd + U`
2. Command line:
   ```bash
   xcodebuild test -project IMDUMB.xcodeproj -scheme IMDUMB -destination 'platform=iOS Simulator,name=iPhone 15'
   ```

**Test Files Location:** `IMDUMBTests/`

**Note:** To run tests in Xcode, you need to add the IMDUMBTests target to the project first (test files are included in the repository).

## 📖 Project Structure Details

### Layers

1. **Domain Layer**: Pure business logic, no dependencies on frameworks
2. **Data Layer**: Implements data fetching and mapping
3. **Presentation Layer**: UI components using MVP pattern
4. **Core Layer**: Shared utilities and extensions

### Key Design Patterns

- **MVP Pattern**: Separation of View and business logic
- **Repository Pattern**: Abstract data sources
- **Dependency Injection**: Through initializers
- **Protocol-Oriented Programming**: Extensive use of protocols

## 🎨 UI Components

All UI is built with **XIB files**:

- ✅ No SwiftUI
- ✅ No programmatic views
- ✅ Interface Builder for all screens
- ✅ Custom reusable cells

## 🚀 CI/CD & Automation

### Fastlane

The project uses Fastlane for iOS automation. Available lanes:

**Setup & Dependencies:**
```bash
bundle exec fastlane setup              # Setup project and dependencies
bundle exec fastlane update_dependencies # Update SPM dependencies
```

**Build:**
```bash
bundle exec fastlane build_debug        # Build Debug configuration
bundle exec fastlane build_release      # Build Release configuration
bundle exec fastlane archive            # Create IPA archive
```

**Testing:**
```bash
bundle exec fastlane test               # Run all unit tests
bundle exec fastlane test_with_coverage # Run tests with code coverage
```

**CI/CD:**
```bash
bundle exec fastlane ci                 # Full CI pipeline (lint, test, build)
bundle exec fastlane ci_quick           # Quick CI (test + build)
```

**Utilities:**
```bash
bundle exec fastlane clean              # Clean build artifacts
bundle exec fastlane lint               # Run SwiftLint
```

### GitHub Actions Workflows

The project includes automated CI/CD workflows:

**1. CI Workflow** (`.github/workflows/ci.yml`)
- Runs on: Push to main/develop, Pull Requests
- Steps: Install dependencies → Generate secrets → Run tests → Build release
- Uploads: Test results, code coverage reports

**2. PR Check** (`.github/workflows/pr-check.yml`)
- Runs on: Pull request events
- Quick validation and automatic PR comments

**3. Build** (`.github/workflows/build.yml`)
- Runs on: Tags (`v*`), Manual trigger
- Creates release archives and GitHub releases

**4. Dependency Update** (`.github/workflows/dependency-update.yml`)
- Runs on: Weekly schedule (Mondays), Manual trigger
- Auto-creates PRs for dependency updates

### Setting Up CI/CD

**1. Install Fastlane:**
```bash
bundle install
```

**2. Setup Secrets (for CI):**

Add these secrets to your GitHub repository (Settings → Secrets and variables → Actions):
- `TMDB_API_KEY`: Your TMDB API key
- `FIREBASE_API_KEY`: Your Firebase API key

**3. Run Locally:**
```bash
# First time setup
bundle exec fastlane setup

# Run tests
bundle exec fastlane test

# Full CI check
bundle exec fastlane ci
```

### Continuous Integration Features

✅ **Automated Testing** - All tests run on every push/PR
✅ **Code Coverage** - Coverage reports uploaded as artifacts
✅ **Build Validation** - Both Debug and Release builds verified
✅ **Dependency Caching** - Faster builds with SPM and gem caching
✅ **PR Comments** - Automatic CI result comments on PRs
✅ **Release Automation** - Automatic releases on version tags
✅ **Weekly Dependency Updates** - Automated dependency update PRs

## 📝 Additional Notes

### Firebase Configuration

The app reads configuration from Firebase on startup. Mock implementation returns:

```json
{
  "api_base_url": "https://api.themoviedb.org/3",
  "api_key": "YOUR_TMDB_API_KEY",
  "welcome_message": "Welcome to IMDUMB!",
  "enable_features": {
    "dark_mode": true,
    "recommendations": true,
    "social_sharing": false
  }
}
```

### Image Loading

Images are loaded asynchronously using URLSession. For production, consider using a caching library like Kingfisher or SDWebImage.

### HTML Rendering

Movie descriptions support HTML formatting through `String+HTML.swift` extension.

## 👤 Author

Developed as a technical challenge demonstrating iOS development skills with Clean Architecture and SOLID principles.

## 📄 License

This project is for demonstration purposes.

---

**Note**: Remember to add your TMDB API key and Firebase configuration before deploying to production.
