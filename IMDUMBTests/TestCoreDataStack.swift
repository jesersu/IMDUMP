import Foundation
import CoreData
@testable import IMDUMB

class TestCoreDataStack {

    static var testContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "IMDUMBModel")

        // Use in-memory store for testing (data doesn't persist between test runs)
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        container.persistentStoreDescriptions = [description]

        container.loadPersistentStores { storeDescription, error in
            if let error = error as NSError? {
                fatalError("Failed to load in-memory store: \(error), \(error.userInfo)")
            }
        }

        return container
    }()

    /// Creates a new background context for testing
    static func createTestContext() -> NSManagedObjectContext {
        return testContainer.newBackgroundContext()
    }

    /// Resets the test container by deleting all objects
    static func reset() {
        let context = testContainer.viewContext
        let entities = ["CachedCategory", "CachedMovie", "CachedActor", "CachedImage"]

        for entityName in entities {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

            do {
                try context.execute(deleteRequest)
                try context.save()
            } catch {
                print("Failed to reset entity \(entityName): \(error)")
            }
        }
    }
}
