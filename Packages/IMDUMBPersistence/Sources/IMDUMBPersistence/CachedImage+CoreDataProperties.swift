import Foundation
import CoreData

public extension CachedImage {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CachedImage> {
        return NSFetchRequest<CachedImage>(entityName: "CachedImage")
    }

    @NSManaged public var imageURL: String
    @NSManaged public var localPath: String
    @NSManaged public var type: String
    @NSManaged public var lastUpdated: Date
    @NSManaged public var movie: CachedMovie?

}

public extension CachedImage : Identifiable {

}
