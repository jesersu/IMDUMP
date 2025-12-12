import Foundation
import CoreData

public extension CachedActor {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CachedActor> {
        return NSFetchRequest<CachedActor>(entityName: "CachedActor")
    }

    @NSManaged public var id: Int64
    @NSManaged public var name: String
    @NSManaged public var character: String
    @NSManaged public var profilePath: String?
    @NSManaged public var movies: NSSet?

}

// MARK: Generated accessors for movies
public extension CachedActor {

    @objc(addMoviesObject:)
    @NSManaged public func addToMovies(_ value: CachedMovie)

    @objc(removeMoviesObject:)
    @NSManaged public func removeFromMovies(_ value: CachedMovie)

    @objc(addMovies:)
    @NSManaged public func addToMovies(_ values: NSSet)

    @objc(removeMovies:)
    @NSManaged public func removeFromMovies(_ values: NSSet)

}

extension CachedActor : Identifiable {

}
