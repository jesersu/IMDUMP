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

The project implements a **Clean Architecture** with **MVP (Model-View-Presenter)** pattern, enhanced with **RxSwift** for reactive data flow. This architecture ensures complete separation of concerns, testability, and maintainability.

### Architecture Layers

The application is divided into four distinct layers, each with specific responsibilities:

#### 1. **Domain Layer** (Business Logic - Framework Independent)
The core of the application, containing pure business logic with zero dependencies on frameworks or external libraries.

- **Entities** (`Domain/Entities/`):
  - Pure Swift structs representing business models
  - `Movie.swift`: Movie entity with all its properties
  - `Actor.swift`: Actor/cast member entity
  - `Category.swift`: Movie category grouping
  - No dependencies, no frameworks, just data structures

- **Repository Protocols** (`Domain/Repositories/`):
  - Abstract interfaces defining data operations
  - `MovieRepositoryProtocol`: Defines methods to get categories and movie details
  - Returns `Single<T>` (RxSwift) for reactive data flow
  - Allows dependency inversion (high-level modules don't depend on low-level details)

- **Use Cases** (`Domain/UseCases/`):
  - Single-purpose business operations following SRP
  - `GetCategoriesUseCase`: Fetches movie categories, filters empty categories
  - `GetMovieDetailsUseCase`: Fetches complete movie information
  - `LoadConfigurationUseCase`: Loads Firebase Remote Config
  - Each use case depends only on repository protocols (DIP)

#### 2. **Data Layer** (Data Management)
Handles all data operations: network requests, local caching, and data transformation.

- **DTOs** (`Data/DTOs/`):
  - Data Transfer Objects for API responses and cache storage
  - `MovieDTO`, `ActorDTO`: Match API/database structure
  - `CachedMoviesDTO`, `CachedMovieDetailsDTO`: CoreData cache wrappers
  - `DTO+Mapping.swift`: Extension methods to convert DTOs to Domain entities
  - Separated from domain models to allow independent evolution

- **DataStores** (`Data/DataStores/`):
  - Different data source implementations following OCP
  - `RemoteMovieDataStore`: Fetches from TMDB API via Alamofire, returns `Single<T>`
  - `LocalMovieDataStore`: Retrieves from CoreData cache with 24-hour TTL
  - `MockMovieDataStore`: Provides sample data for testing
  - `FirebaseConfigDataStore`: Fetches Remote Config from Firebase
  - All conform to `MovieDataStoreProtocol` (LSP - interchangeable)

- **Repositories** (`Data/Repositories/`):
  - Concrete implementations of domain repository protocols
  - `MovieRepository`: Coordinates between multiple data sources
  - Implements cache-first strategy with background refresh
  - Uses `Single.zip()` to parallelize 4 category fetches
  - Converts DTOs to Domain entities using mapping extensions

#### 3. **Presentation Layer** (UI - MVP Pattern)
Handles all user interface concerns following the MVP pattern.

Each screen is organized with:
- **View Protocol**: Defines what the view can do (display data, show loading, show errors)
- **Presenter Protocol**: Defines what actions the presenter handles
- **View Controller**: UIKit view that conforms to View Protocol
  - Displays data received from presenter
  - Forwards user interactions to presenter
  - Uses XIB files (no SwiftUI, no programmatic views)
- **Presenter**: Business logic coordinator
  - Subscribes to use case `Single<T>` observables
  - Transforms data for view display
  - Handles errors and edge cases
  - Uses `DisposeBag` for automatic memory management
  - Uses `MainScheduler.instance` for thread-safe UI updates

**Screens:**
- `Splash/`: Firebase config loading, navigation to main screen
- `Categories/`: Movie categories with nested UICollectionView/UITableView
- `MovieDetail/`: Movie details with image carousel, cast, and recommendation
- `Recommendation/`: Modal for movie recommendation with dynamic height

#### 4. **Core Layer** (Shared Utilities)
Cross-cutting concerns and shared infrastructure.

- **Network** (`Core/Network/`):
  - `NetworkService`: Alamofire-based HTTP client with generic request handling
  - Thread-safe, reusable across all data stores

- **Cache** (`Core/Cache/`):
  - `CacheServiceProtocol`: Abstract cache interface
  - `CoreDataCacheService`: CoreData implementation with TTL support
  - `ImageCacheService`: In-memory image caching for performance

- **Extensions** (`Core/Extensions/`):
  - `UIViewController+Loading.swift`: Loading indicators and toast notifications
  - `String+HTML.swift`: HTML parsing for movie descriptions
  - `UIImageView+Alamofire.swift`: Async image loading with Alamofire

- **Utilities** (`Core/Utils/`):
  - `NetworkReachability`: Detects online/offline status for cache-first UX

### Project Structure

```
IMDUMB/
├── Domain/                          # 🎯 Business Logic (Pure Swift)
│   ├── Entities/                   # Business models
│   │   ├── Movie.swift
│   │   ├── Actor.swift
│   │   └── Category.swift
│   ├── Repositories/               # Abstract data interfaces
│   │   └── MovieRepositoryProtocol.swift
│   └── UseCases/                   # Business operations
│       ├── GetCategoriesUseCase.swift
│       ├── GetMovieDetailsUseCase.swift
│       └── LoadConfigurationUseCase.swift
│
├── Data/                            # 💾 Data Management
│   ├── DTOs/                       # Data transfer objects
│   │   ├── MovieDTO.swift
│   │   ├── ActorDTO.swift
│   │   ├── CachedDTOs.swift
│   │   └── DTO+Mapping.swift       # DTO → Domain mapping
│   ├── DataStores/                 # Data source implementations
│   │   ├── MovieDataStoreProtocol.swift
│   │   ├── RemoteMovieDataStore.swift    # Network (Alamofire)
│   │   ├── LocalMovieDataStore.swift     # Cache (CoreData)
│   │   ├── MockMovieDataStore.swift      # Testing
│   │   └── FirebaseConfigDataStore.swift # Remote Config
│   └── Repositories/               # Repository implementations
│       └── MovieRepository.swift   # Cache-first + parallel fetching
│
├── Presentation/                    # 🎨 UI Layer (MVP Pattern)
│   ├── Splash/
│   │   ├── SplashViewController.swift     # View (XIB)
│   │   ├── SplashPresenter.swift          # Presenter (RxSwift)
│   │   └── SplashContracts.swift          # View/Presenter protocols
│   ├── Categories/
│   │   ├── CategoriesViewController.swift # View (XIB)
│   │   ├── CategoriesPresenter.swift      # Presenter (RxSwift + offline detection)
│   │   ├── CategoryCollectionViewCell.swift
│   │   └── MovieTableViewCell.swift
│   ├── MovieDetail/
│   │   ├── MovieDetailViewController.swift
│   │   └── MovieDetailPresenter.swift
│   └── Recommendation/
│       └── RecommendationViewController.swift
│
├── Core/                            # 🔧 Shared Infrastructure
│   ├── Network/
│   │   └── NetworkService.swift    # Alamofire HTTP client
│   ├── Cache/
│   │   ├── CacheServiceProtocol.swift
│   │   ├── CoreDataCacheService.swift
│   │   └── ImageCacheService.swift
│   ├── Extensions/
│   │   ├── UIViewController+Loading.swift
│   │   ├── String+HTML.swift
│   │   └── UIImageView+Alamofire.swift
│   ├── Utils/
│   │   └── NetworkReachability.swift
│   └── Protocols/
│       └── BaseViewProtocol.swift
│
└── Packages/                        # 📦 Swift Packages
    └── IMDUMBPersistence/          # CoreData persistence module
        ├── Sources/
        │   └── IMDUMBPersistence/
        │       ├── CoreDataModels.xcdatamodeld
        │       ├── CacheService.swift
        │       ├── MovieDTO.swift
        │       └── ActorDTO.swift
        └── Tests/
```

### Data Flow with RxSwift

The application uses **RxSwift** for reactive, declarative data flow:

```
┌─────────────┐
│    View     │  User taps "Load Movies"
└──────┬──────┘
       │ viewDidLoad()
       ▼
┌─────────────┐
│  Presenter  │  getCategoriesUseCase.execute()
└──────┬──────┘       .observe(on: MainScheduler.instance)
       │              .subscribe(onSuccess: { view.display($0) })
       │              .disposed(by: disposeBag)
       ▼
┌─────────────┐
│   UseCase   │  repository.getCategories() → Single<[Category]>
└──────┬──────┘       .map { $0.filter { !$0.movies.isEmpty } }
       │
       ▼
┌─────────────┐
│ Repository  │  1. Try cache: localDataStore.fetchMovies()
└──────┬──────┘                   .catch { remoteDataStore.fetchMovies() }
       │         2. Parallel fetch 4 categories: Single.zip(...)
       │         3. Background refresh: .do(onSuccess: { refresh() })
       │         4. Map DTOs → Domain: dtos.map { $0.toDomain() }
       ▼
┌─────────────┐
│  DataStore  │  RemoteDataStore: Alamofire HTTP request → Single<[MovieDTO]>
└──────┬──────┘  LocalDataStore:  CoreData fetch → Single<[MovieDTO]>
       │
       ▼
┌─────────────┐
│  Network /  │  TMDB API or CoreData
│   Cache     │
└─────────────┘

Response flows back up through Single chain:
MovieDTO[] → (mapping) → Movie[] → Category[] → View displays
```

### Reactive Patterns Used

**1. Single for One-Time Operations:**
```swift
func getCategories() -> Single<[Category]> {
    return repository.getCategories()
        .map { categories in categories.filter { !$0.movies.isEmpty } }
}
```

**2. Parallel Execution with Single.zip:**
```swift
let singles = [popular, topRated, upcoming, nowPlaying].map { endpoint in
    dataStore.fetchMovies(endpoint: endpoint)
}
Single.zip(singles) // Runs all 4 fetches in parallel
```

**3. Cache-First with Fallback:**
```swift
localDataStore.fetchMovies(endpoint)
    .do(onSuccess: { refreshInBackground() })  // Background refresh
    .catch { remoteDataStore.fetchMovies(endpoint) }  // Fallback to network
```

**4. Thread-Safe UI Updates:**
```swift
useCase.execute()
    .observe(on: MainScheduler.instance)  // Ensures UI updates on main thread
    .subscribe(onSuccess: { view.display($0) })
    .disposed(by: disposeBag)  // Auto-cleanup on deinit
```

**5. Non-Critical Operations:**
```swift
fetchMovieCredits(movieId)
    .catchAndReturn([])  // Continue with empty array if credits fail
```

### Offline Support Flow

```
User opens app (offline)
    ↓
NetworkReachability.shared.isReachable → false
    ↓
Repository tries LocalDataStore first (cache-first)
    ↓
Cache hit → Returns cached data
    ↓
Presenter detects offline: if !isReachable { view.showToast("Offline") }
    ↓
View displays cached data + toast notification
    ↓
When online: Background refresh updates cache
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
