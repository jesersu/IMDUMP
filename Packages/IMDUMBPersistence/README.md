# IMDUMBPersistence

A Swift Package Module for managing persistence and caching in the IMDUMB iOS application.

## Overview

This package provides a CoreData-based caching solution with a clean, protocol-oriented API. It encapsulates all persistence logic, making it reusable and testable.

## Features

- ✅ **CoreData Stack Management** - Singleton-based CoreData initialization with automatic merging
- ✅ **Cache Service Protocol** - Generic caching interface for any `Codable` type
- ✅ **Movie & Actor DTOs** - Data transfer objects for API responses
- ✅ **Automatic Migration** - One-time migration from UserDefaults to CoreData
- ✅ **Entity Mapping** - Seamless conversion between DTOs and CoreData entities
- ✅ **Expiration Handling** - 24-hour TTL with timestamp-based expiration
- ✅ **Type-Safe** - Leverages Swift generics and protocols

## Architecture

### Module Structure

```
IMDUMBPersistence/
├── Sources/
│   └── IMDUMBPersistence/
│       ├── CoreDataStack.swift           # Manages NSPersistentContainer
│       ├── CoreDataCacheService.swift    # Implements caching with CoreData
│       ├── CacheMigration.swift          # Migration utilities
│       ├── CacheServiceProtocol.swift    # Generic cache protocol
│       ├── CacheError.swift              # Error types
│       ├── MovieDTO.swift                # API response models
│       ├── CachedDTOs.swift              # Cache wrapper models
│       ├── Cached[Entity]+*.swift        # CoreData entities & mapping
│       └── Resources/
│           └── IMDUMBModel.xcdatamodeld  # CoreData model
└── Tests/
    └── IMDUMBPersistenceTests/
```

### CoreData Entities

- **CachedCategory** - Movie categories (popular, top_rated, etc.)
- **CachedMovie** - Movie metadata with relationships
- **CachedActor** - Actor information (many-to-many with movies)
- **CachedImage** - Image metadata (paths and timestamps)

## Usage

### Importing the Package

```swift
import IMDUMBPersistence
```

### Initialize CoreData

```swift
// In AppDelegate
func application(_ application: UIApplication,
                 didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    // Initialize CoreData
    _ = CoreDataStack.shared.persistentContainer

    // Run one-time migration
    CacheMigration.migrateUserDefaultsToCoreData()

    // Initialize cache service
    CoreDataCacheService.shared.initialize()

    return true
}
```

### Using the Cache Service

```swift
let cacheService = CoreDataCacheService.shared

// Save data
let movies = [MovieDTO(id: 1, title: "Test", ...)]
let cached = CachedMoviesDTO(movies: movies, timestamp: Date())
try cacheService.save(cached, forKey: "cache.category.popular")

// Load data
if let loaded: CachedMoviesDTO = cacheService.load(forKey: "cache.category.popular") {
    print("Found \(loaded.movies.count) cached movies")
}

// Check expiration
let isExpired = cacheService.isExpired(forKey: "cache.category.popular",
                                       expirationInterval: 24 * 60 * 60)

// Clear cache
cacheService.clearAll()
```

### Data Store Integration

```swift
// Use in a DataStore implementation
class LocalMovieDataStore: MovieDataStoreProtocol {
    private let cacheService: CacheServiceProtocol

    init(cacheService: CacheServiceProtocol = CoreDataCacheService.shared) {
        self.cacheService = cacheService
    }

    func fetchMovies(endpoint: String, completion: @escaping (Result<[MovieDTO], Error>) -> Void) {
        // Try cache first
        if let cached: CachedMoviesDTO = cacheService.load(forKey: "cache.category.\(endpoint)") {
            completion(.success(cached.movies))
        } else {
            completion(.failure(CacheError.notFound))
        }
    }
}
```

## Testing

The package includes in-memory CoreData support for testing:

```swift
import XCTest
@testable import IMDUMBPersistence

class MyTests: XCTestCase {
    var testContext: NSManagedObjectContext!
    var cacheService: CoreDataCacheService!

    override func setUp() {
        super.setUp()
        // Use in-memory store for tests
        testContext = TestCoreDataStack.testContainer.viewContext
        cacheService = CoreDataCacheService(context: testContext)
    }
}
```

## Clean Architecture

This package follows Clean Architecture principles:

- **Protocol-Oriented**: `CacheServiceProtocol` allows dependency injection
- **Separation of Concerns**: Persistence logic isolated from business logic
- **Testability**: In-memory CoreData for fast, isolated tests
- **Dependency Inversion**: High-level modules don't depend on low-level details

## Requirements

- iOS 15.0+
- Swift 5.9+
- Xcode 15.0+

## License

Part of the IMDUMB iOS application.
