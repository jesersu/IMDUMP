import Foundation

public class CacheMigration {

    private static let migrationKey = "cache.migration.userdefaults_to_coredata.completed"

    /// Migrates cache data from UserDefaults to CoreData
    /// This is a one-time migration that runs on app launch
    public static func migrateUserDefaultsToCoreData() {
        // Check if migration already completed
        if UserDefaults.standard.bool(forKey: migrationKey) {
            print("Cache migration already completed")
            return
        }

        print("Starting cache migration from UserDefaults to CoreData...")

        let oldCache = CacheService.shared
        let newCache = CoreDataCacheService.shared

        // Migrate categories
        let categories = ["popular", "top_rated", "upcoming", "now_playing"]

        for categoryId in categories {
            let cacheKey = "cache.category.\(categoryId)"

            // Try to load old cached movies
            if let cachedMovies: CachedMoviesDTO = oldCache.load(forKey: cacheKey) {
                do {
                    try newCache.save(cachedMovies, forKey: cacheKey)
                    print("✓ Migrated category: \(categoryId) (\(cachedMovies.movies.count) movies)")
                } catch {
                    print("✗ Failed to migrate category \(categoryId): \(error)")
                }
            }
        }

        // Migrate movie details (if any cached)
        // Note: We can't enumerate all possible movie IDs, so we'll only migrate
        // what we find in UserDefaults by scanning all keys
        let allKeys = UserDefaults.standard.dictionaryRepresentation().keys
        let movieDetailKeys = allKeys.filter { $0.hasPrefix("cache.movie.") && !$0.contains(".timestamp") }

        for key in movieDetailKeys {
            if let cachedDetails: CachedMovieDetailsDTO = oldCache.load(forKey: key) {
                do {
                    try newCache.save(cachedDetails, forKey: key)
                    print("✓ Migrated movie details: \(key)")
                } catch {
                    print("✗ Failed to migrate movie details \(key): \(error)")
                }
            }
        }

        // Mark migration as completed
        UserDefaults.standard.set(true, forKey: migrationKey)

        // Clear old cache to free up space
        oldCache.clearAll()
        print("Cache migration completed successfully")
    }

    /// Resets the migration flag (useful for testing)
    public static func resetMigrationFlag() {
        UserDefaults.standard.removeObject(forKey: migrationKey)
        print("Migration flag reset")
    }

    /// Checks if migration has been completed
    public static func isMigrationCompleted() -> Bool {
        return UserDefaults.standard.bool(forKey: migrationKey)
    }
}
