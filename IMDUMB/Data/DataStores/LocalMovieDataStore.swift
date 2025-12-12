import Foundation
import IMDUMBPersistence
import RxSwift

class LocalMovieDataStore: MovieDataStoreProtocol {

    private let cacheService: CacheServiceProtocol
    private let expirationInterval: TimeInterval = 24 * 60 * 60

    init(cacheService: CacheServiceProtocol = CoreDataCacheService.shared as! CacheServiceProtocol) {
        self.cacheService = cacheService
    }

    func fetchMovies(endpoint: String) -> Single<[MovieDTO]> {
        return Single.create { [weak self] observer in
            guard let self = self else {
                observer(.failure(CacheError.notFound))
                return Disposables.create()
            }

            let categoryId = self.extractCategoryId(from: endpoint)
            let cacheKey = CacheKey.category(categoryId)

            if self.cacheService.isExpired(forKey: cacheKey, expirationInterval: self.expirationInterval) {
                observer(.failure(CacheError.expired))
                return Disposables.create()
            }

            if let cachedMovies: CachedMoviesDTO = self.cacheService.load(forKey: cacheKey) {
                observer(.success(cachedMovies.movies))
            } else {
                observer(.failure(CacheError.notFound))
            }

            return Disposables.create()
        }
    }

    func fetchMovieDetails(movieId: Int) -> Single<MovieDTO> {
        return Single.create { [weak self] observer in
            guard let self = self else {
                observer(.failure(CacheError.notFound))
                return Disposables.create()
            }

            let cacheKey = CacheKey.movieDetails(movieId)

            if self.cacheService.isExpired(forKey: cacheKey, expirationInterval: self.expirationInterval) {
                observer(.failure(CacheError.expired))
                return Disposables.create()
            }

            if let cachedDetails: CachedMovieDetailsDTO = self.cacheService.load(forKey: cacheKey) {
                observer(.success(cachedDetails.movie))
            } else {
                observer(.failure(CacheError.notFound))
            }

            return Disposables.create()
        }
    }

    func fetchMovieCredits(movieId: Int) -> Single<[ActorDTO]> {
        return Single.create { [weak self] observer in
            guard let self = self else {
                observer(.failure(CacheError.notFound))
                return Disposables.create()
            }

            let cacheKey = CacheKey.movieDetails(movieId)

            if self.cacheService.isExpired(forKey: cacheKey, expirationInterval: self.expirationInterval) {
                observer(.failure(CacheError.expired))
                return Disposables.create()
            }

            if let cachedDetails: CachedMovieDetailsDTO = self.cacheService.load(forKey: cacheKey) {
                observer(.success(cachedDetails.actors))
            } else {
                observer(.failure(CacheError.notFound))
            }

            return Disposables.create()
        }
    }

    func fetchMovieImages(movieId: Int) -> Single<[String]> {
        return Single.create { [weak self] observer in
            guard let self = self else {
                observer(.failure(CacheError.notFound))
                return Disposables.create()
            }

            let cacheKey = CacheKey.movieDetails(movieId)

            if self.cacheService.isExpired(forKey: cacheKey, expirationInterval: self.expirationInterval) {
                observer(.failure(CacheError.expired))
                return Disposables.create()
            }

            if let cachedDetails: CachedMovieDetailsDTO = self.cacheService.load(forKey: cacheKey) {
                observer(.success(cachedDetails.images))
            } else {
                observer(.failure(CacheError.notFound))
            }

            return Disposables.create()
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
