import Foundation
import CoreData

extension CachedMovie {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CachedMovie> {
        return NSFetchRequest<CachedMovie>(entityName: "CachedMovie")
    }

    @NSManaged public var id: Int64
    @NSManaged public var title: String
    @NSManaged public var overview: String
    @NSManaged public var posterPath: String?
    @NSManaged public var backdropPath: String?
    @NSManaged public var voteAverage: Double
    @NSManaged public var releaseDate: String?
    @NSManaged public var lastUpdated: Date
    @NSManaged public var category: CachedCategory?
    @NSManaged public var actors: NSSet?
    @NSManaged public var images: NSSet?

}

// MARK: Generated accessors for actors
extension CachedMovie {

    @objc(addActorsObject:)
    @NSManaged public func addToActors(_ value: CachedActor)

    @objc(removeActorsObject:)
    @NSManaged public func removeFromActors(_ value: CachedActor)

    @objc(addActors:)
    @NSManaged public func addToActors(_ values: NSSet)

    @objc(removeActors:)
    @NSManaged public func removeFromActors(_ values: NSSet)

}

// MARK: Generated accessors for images
extension CachedMovie {

    @objc(addImagesObject:)
    @NSManaged public func addToImages(_ value: CachedImage)

    @objc(removeImagesObject:)
    @NSManaged public func removeFromImages(_ value: CachedImage)

    @objc(addImages:)
    @NSManaged public func addToImages(_ values: NSSet)

    @objc(removeImages:)
    @NSManaged public func removeFromImages(_ values: NSSet)

}

extension CachedMovie : Identifiable {

}
