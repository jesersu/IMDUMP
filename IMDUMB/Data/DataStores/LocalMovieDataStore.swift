import Foundation
import IMDUMBPersistence

class LocalMovieDataStore: MovieDataStoreProtocol {

    private let cacheService: CacheServiceProtocol
    private let expirationInterval: TimeInterval = 24 * 60 * 60

    init(cacheService: CacheServiceProtocol = CoreDataCacheService.shared) {
        self.cacheService = cacheService
    }

    func fetchMovies(endpoint: String, completion: @escaping (Result<[MovieDTO], Error>) -> Void) {
        let categoryId = extractCategoryId(from: endpoint)
        let cacheKey = CacheKey.category(categoryId)

        if cacheService.isExpired(forKey: cacheKey, expirationInterval: expirationInterval) {
            completion(.failure(CacheError.expired))
            return
        }

        if let cachedMovies: CachedMoviesDTO = cacheService.load(forKey: cacheKey) {
            completion(.success(cachedMovies.movies))
        } else {
            completion(.failure(CacheError.notFound))
        }
    }

    func fetchMovieDetails(movieId: Int, completion: @escaping (Result<MovieDTO, Error>) -> Void) {
        let cacheKey = CacheKey.movieDetails(movieId)

        if cacheService.isExpired(forKey: cacheKey, expirationInterval: expirationInterval) {
            completion(.failure(CacheError.expired))
            return
        }

        if let cachedDetails: CachedMovieDetailsDTO = cacheService.load(forKey: cacheKey) {
            completion(.success(cachedDetails.movie))
        } else {
            completion(.failure(CacheError.notFound))
        }
    }

    func fetchMovieCredits(movieId: Int, completion: @escaping (Result<[ActorDTO], Error>) -> Void) {
        let cacheKey = CacheKey.movieDetails(movieId)

        if cacheService.isExpired(forKey: cacheKey, expirationInterval: expirationInterval) {
            completion(.failure(CacheError.expired))
            return
        }

        if let cachedDetails: CachedMovieDetailsDTO = cacheService.load(forKey: cacheKey) {
            completion(.success(cachedDetails.actors))
        } else {
            completion(.failure(CacheError.notFound))
        }
    }

    func fetchMovieImages(movieId: Int, completion: @escaping (Result<[String], Error>) -> Void) {
        let cacheKey = CacheKey.movieDetails(movieId)

        if cacheService.isExpired(forKey: cacheKey, expirationInterval: expirationInterval) {
            completion(.failure(CacheError.expired))
            return
        }

        if let cachedDetails: CachedMovieDetailsDTO = cacheService.load(forKey: cacheKey) {
            completion(.success(cachedDetails.images))
        } else {
            completion(.failure(CacheError.notFound))
        }
    }

    func saveMovies(_ movies: [MovieDTO], forEndpoint endpoint: String) throws {
        let categoryId = extractCategoryId(from: endpoint)
        let cacheKey = CacheKey.category(categoryId)
        let cachedMovies = CachedMoviesDTO(movies: movies, timestamp: Date())

        try cacheService.save(cachedMovies, forKey: cacheKey)
    }

    func saveMovieDetails(_ movie: MovieDTO, actors: [ActorDTO], images: [String], movieId: Int) throws {
        let cacheKey = CacheKey.movieDetails(movieId)
        let cachedDetails = CachedMovieDetailsDTO(movie: movie, actors: actors, images: images, timestamp: Date())

        try cacheService.save(cachedDetails, forKey: cacheKey)
    }

    private func extractCategoryId(from endpoint: String) -> String {
        let components = endpoint.components(separatedBy: "/")
        return components.last ?? endpoint
    }
}
