import Foundation
import CoreData

public extension CachedMovie {

    // MARK: - DTO Conversion

    /// Converts CachedMovie entity to MovieDTO
    public func toDTO() -> MovieDTO {
        return MovieDTO(
            id: Int(id),
            title: title,
            overview: overview,
            posterPath: posterPath,
            backdropPath: backdropPath,
            voteAverage: voteAverage,
            releaseDate: releaseDate
        )
    }

    /// Creates or updates CachedMovie from MovieDTO
    /// - Parameters:
    ///   - dto: The MovieDTO to convert
    ///   - context: The managed object context
    /// - Returns: CachedMovie entity
    public static func from(dto: MovieDTO, context: NSManagedObjectContext) -> CachedMovie {
        let request: NSFetchRequest<CachedMovie> = CachedMovie.fetchRequest()
        request.predicate = NSPredicate(format: "id == %d", dto.id)

        // Try to find existing movie
        let existing = try? context.fetch(request).first
        let movie = existing ?? CachedMovie(context: context)

        // Update properties
        movie.id = Int64(dto.id)
        movie.title = dto.title
        movie.overview = dto.overview
        movie.posterPath = dto.posterPath
        movie.backdropPath = dto.backdropPath
        movie.voteAverage = dto.voteAverage
        movie.releaseDate = dto.releaseDate
        movie.lastUpdated = Date()

        return movie
    }

    /// Converts array of CachedMovie to array of MovieDTO
    public static func toDTOArray(_ movies: [CachedMovie]) -> [MovieDTO] {
        return movies.map { $0.toDTO() }
    }

    /// Converts array of MovieDTO to array of CachedMovie
    public static func fromDTOArray(_ dtos: [MovieDTO], context: NSManagedObjectContext) -> [CachedMovie] {
        return dtos.map { from(dto: $0, context: context) }
    }
}
