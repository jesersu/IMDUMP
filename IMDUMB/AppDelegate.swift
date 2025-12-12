import UIKit
import FirebaseCore
import IMDUMBPersistence

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Configure Firebase
        FirebaseApp.configure()

        // Initialize CoreData
        _ = CoreDataStack.shared.persistentContainer

        // Migrate from UserDefaults to CoreData (one-time migration)
        CacheMigration.migrateUserDefaultsToCoreData()

        // Initialize cache services
        CoreDataCacheService.shared.initialize()
        ImageCacheService.shared.initialize()

        // Periodic cleanup of expired images
        ImageCacheService.shared.clearExpiredImages()

        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Save CoreData context before app terminates
        CoreDataStack.shared.saveContext()
    }
}
