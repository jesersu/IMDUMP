import Foundation
import CoreData

class CoreDataCacheService: CacheServiceProtocol {
    static let shared = CoreDataCacheService()

    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext = CoreDataStack.shared.viewContext) {
        self.context = context
    }

    func initialize() {
        // CoreData initialization handled by CoreDataStack
        // No version checking needed as CoreData handles migrations automatically
    }

    // MARK: - Generic CacheServiceProtocol Implementation

    func save<T: Codable>(_ object: T, forKey key: String) throws {
        // Handle specific types
        if let cachedMovies = object as? CachedMoviesDTO {
            try saveMoviesDTO(cachedMovies, forKey: key)
        } else if let cachedDetails = object as? CachedMovieDetailsDTO {
            try saveMovieDetailsDTO(cachedDetails, forKey: key)
        } else {
            // For other Codable types, could fall back to UserDefaults or throw error
            throw CacheError.encodingFailed
        }
    }

    func load<T: Codable>(forKey key: String) -> T? {
        // Handle specific types
        if T.self == CachedMoviesDTO.self {
            return loadMoviesDTO(forKey: key) as? T
        } else if T.self == CachedMovieDetailsDTO.self {
            return loadMovieDetailsDTO(forKey: key) as? T
        }
        return nil
    }

    func remove(forKey key: String) {
        let categoryId = extractCategoryId(from: key)

        if key.contains("cache.category.") {
            removeCategory(categoryId: categoryId)
        } else if key.contains("cache.movie.") {
            if let movieId = Int(categoryId) {
                removeMovieDetails(movieId: movieId)
            }
        }
    }

    func isExpired(forKey key: String, expirationInterval: TimeInterval) -> Bool {
        let categoryId = extractCategoryId(from: key)

        if key.contains("cache.category.") {
            return isCategoryExpired(categoryId: categoryId, expirationInterval: expirationInterval)
        } else if key.contains("cache.movie.") {
            if let movieId = Int(categoryId) {
                return isMovieDetailsExpired(movieId: movieId, expirationInterval: expirationInterval)
            }
        }

        return true
    }

    func clearAll() {
        let entities = ["CachedCategory", "CachedMovie", "CachedActor", "CachedImage"]

        for entityName in entities {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

            do {
                try context.execute(deleteRequest)
                try context.save()
            } catch {
                print("CoreData clear error for \(entityName): \(error)")
            }
        }
    }

    // MARK: - Private Helper Methods

    private func saveMoviesDTO(_ cachedMovies: CachedMoviesDTO, forKey key: String) throws {
        let categoryId = extractCategoryId(from: key)

        // Find or create category
        let categoryRequest: NSFetchRequest<CachedCategory> = CachedCategory.fetchRequest()
        categoryRequest.predicate = NSPredicate(format: "id == %@", categoryId)

        let category: CachedCategory
        if let existing = try? context.fetch(categoryRequest).first {
            category = existing
        } else {
            category = CachedCategory(context: context)
            category.id = categoryId
            category.name = categoryId.capitalized
            category.endpoint = "/movie/\(categoryId)"
        }

        category.lastUpdated = cachedMovies.timestamp

        // Remove old movies from this category
        if let existingMovies = category.movies as? Set<CachedMovie> {
            for movie in existingMovies {
                context.delete(movie)
            }
        }

        // Convert DTOs to entities and add to category
        let movieEntities = CachedMovie.fromDTOArray(cachedMovies.movies, context: context)
        for movie in movieEntities {
            movie.category = category
        }

        try context.save()
    }

    private func loadMoviesDTO(forKey key: String) -> CachedMoviesDTO? {
        let categoryId = extractCategoryId(from: key)

        let request: NSFetchRequest<CachedCategory> = CachedCategory.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", categoryId)

        guard let category = try? context.fetch(request).first,
              let moviesSet = category.movies as? Set<CachedMovie> else {
            return nil
        }

        let movies = Array(moviesSet)
        let movieDTOs = CachedMovie.toDTOArray(movies)

        return CachedMoviesDTO(movies: movieDTOs, timestamp: category.lastUpdated)
    }

    private func saveMovieDetailsDTO(_ cachedDetails: CachedMovieDetailsDTO, forKey key: String) throws {
        // Create or update movie
        let movie = CachedMovie.from(dto: cachedDetails.movie, context: context)

        // Update actors
        let actorEntities = CachedActor.fromDTOArray(cachedDetails.actors, context: context)
        movie.actors = NSSet(array: actorEntities)

        // Store image URLs as CachedImage entities
        for imageURL in cachedDetails.images {
            let imageRequest: NSFetchRequest<CachedImage> = CachedImage.fetchRequest()
            imageRequest.predicate = NSPredicate(format: "imageURL == %@", imageURL)

            let cachedImage: CachedImage
            if let existing = try? context.fetch(imageRequest).first {
                cachedImage = existing
            } else {
                cachedImage = CachedImage(context: context)
                cachedImage.imageURL = imageURL
                cachedImage.localPath = "" // Will be set by ImageCacheService
                cachedImage.type = "backdrop"
            }

            cachedImage.lastUpdated = cachedDetails.timestamp
            cachedImage.movie = movie
        }

        try context.save()
    }

    private func loadMovieDetailsDTO(forKey key: String) -> CachedMovieDetailsDTO? {
        let movieIdString = extractCategoryId(from: key)
        guard let movieId = Int(movieIdString) else { return nil }

        let request: NSFetchRequest<CachedMovie> = CachedMovie.fetchRequest()
        request.predicate = NSPredicate(format: "id == %d", movieId)

        guard let movie = try? context.fetch(request).first else {
            return nil
        }

        let movieDTO = movie.toDTO()

        let actors = (movie.actors as? Set<CachedActor>) ?? []
        let actorDTOs = CachedActor.toDTOArray(Array(actors))

        let images = (movie.images as? Set<CachedImage>) ?? []
        let imageURLs = images.map { $0.imageURL }

        return CachedMovieDetailsDTO(
            movie: movieDTO,
            actors: actorDTOs,
            images: imageURLs,
            timestamp: movie.lastUpdated
        )
    }

    private func removeCategory(categoryId: String) {
        let request: NSFetchRequest<CachedCategory> = CachedCategory.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", categoryId)

        if let category = try? context.fetch(request).first {
            context.delete(category)
            try? context.save()
        }
    }

    private func removeMovieDetails(movieId: Int) {
        let request: NSFetchRequest<CachedMovie> = CachedMovie.fetchRequest()
        request.predicate = NSPredicate(format: "id == %d", movieId)

        if let movie = try? context.fetch(request).first {
            context.delete(movie)
            try? context.save()
        }
    }

    private func isCategoryExpired(categoryId: String, expirationInterval: TimeInterval) -> Bool {
        let request: NSFetchRequest<CachedCategory> = CachedCategory.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", categoryId)

        guard let category = try? context.fetch(request).first else {
            return true
        }

        let elapsed = Date().timeIntervalSince(category.lastUpdated)
        return elapsed > expirationInterval
    }

    private func isMovieDetailsExpired(movieId: Int, expirationInterval: TimeInterval) -> Bool {
        let request: NSFetchRequest<CachedMovie> = CachedMovie.fetchRequest()
        request.predicate = NSPredicate(format: "id == %d", movieId)

        guard let movie = try? context.fetch(request).first else {
            return true
        }

        let elapsed = Date().timeIntervalSince(movie.lastUpdated)
        return elapsed > expirationInterval
    }

    private func extractCategoryId(from key: String) -> String {
        if key.hasPrefix("cache.category.") {
            return key.replacingOccurrences(of: "cache.category.", with: "")
        } else if key.hasPrefix("cache.movie.") {
            return key.replacingOccurrences(of: "cache.movie.", with: "")
        }
        return key
    }
}
