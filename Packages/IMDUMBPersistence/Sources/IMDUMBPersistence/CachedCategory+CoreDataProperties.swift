import Foundation
import CoreData

public extension CachedCategory {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CachedCategory> {
        return NSFetchRequest<CachedCategory>(entityName: "CachedCategory")
    }

    @NSManaged public var id: String
    @NSManaged public var name: String
    @NSManaged public var endpoint: String
    @NSManaged public var lastUpdated: Date
    @NSManaged public var movies: NSSet?

}

// MARK: Generated accessors for movies
public extension CachedCategory {

    @objc(addMoviesObject:)
    @NSManaged public func addToMovies(_ value: CachedMovie)

    @objc(removeMoviesObject:)
    @NSManaged public func removeFromMovies(_ value: CachedMovie)

    @objc(addMovies:)
    @NSManaged public func addToMovies(_ values: NSSet)

    @objc(removeMovies:)
    @NSManaged public func removeFromMovies(_ values: NSSet)

}

public extension CachedCategory : Identifiable {

}
