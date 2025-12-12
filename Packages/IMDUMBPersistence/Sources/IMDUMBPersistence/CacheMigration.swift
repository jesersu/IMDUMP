import Foundation

public class CacheMigration {

    private static let migrationKey = "cache.migration.userdefaults_to_coredata.completed"

    /// Migrates cache data from UserDefaults to CoreData
    /// This is a one-time migration that runs on app launch
    /// Note: This migration is now a no-op since the app starts fresh with CoreData
    public static func migrateUserDefaultsToCoreData() {
        // Check if migration already completed
        if UserDefaults.standard.bool(forKey: migrationKey) {
            print("✓ Cache migration already completed")
            return
        }

        print("⚠️  No legacy UserDefaults cache found - marking migration as complete")

        // Since we're starting fresh with CoreData and there's no legacy cache to migrate,
        // just mark the migration as completed to prevent this check on future launches
        UserDefaults.standard.set(true, forKey: migrationKey)

        print("✓ Cache migration completed successfully")
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
