# IMDUMB - iOS Movie Database App

IMDUMB is an iOS application that displays movie categories and details, built with **MVP + Clean Architecture** pattern. The app demonstrates professional iOS development practices including proper separation of concerns, SOLID principles, and UIKit with XIB-based interface design.

## 📱 Features

- **Splash Screen** with Firebase configuration loading
- **Categories Screen** displaying movies organized by category (Popular, Top Rated, Upcoming, Now Playing)
- **Unique UI Pattern**: UICollectionView with UITableView inside each cell
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
- **Networking**: URLSession (prepared for Alamofire integration)
- **Dependency Management**: Swift Package Manager (SPM)
- **Firebase**: Firebase Remote Config / Realtime Database (for configuration)

## 📦 Dependencies

Dependencies are managed via Swift Package Manager:

- **Firebase iOS SDK** (planned - for Remote Config/Database)
- **Alamofire** (planned - for advanced networking)

## 🚀 Installation & Setup

### Prerequisites

- Xcode 16.0 or later
- macOS with iOS development tools
- Git

### Steps

1. **Clone the repository**
   ```bash
   git clone https://github.com/jesersu/IMDUMP.git
   cd IMDUMB
   ```

2. **Open the project**
   ```bash
   open IMDUMB.xcodeproj
   ```

3. **Configure API Key** (for production use)
   - Open `IMDUMB/Core/Network/NetworkService.swift`
   - Replace `YOUR_API_KEY_HERE` with your TMDB API key
   ```swift
   init(baseURL: String = "https://api.themoviedb.org/3",
        apiKey: String = "YOUR_TMDB_API_KEY")
   ```

4. **Configure Firebase** (optional)
   - Download `GoogleService-Info.plist` from Firebase Console
   - Add it to the project root (excluded from git via .gitignore)
   - The app will work with mock data even without Firebase

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

The app includes multiple DataStore implementations for testing:

- **MockMovieDataStore**: Provides sample data without network calls
- **RemoteMovieDataStore**: Fetches data from TMDB API
- **LocalDataStore**: (Future) For offline caching with CoreData/Realm

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
