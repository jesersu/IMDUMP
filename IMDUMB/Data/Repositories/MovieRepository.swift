import Foundation
import IMDUMBPersistence

// MARK: - Movie Repository Implementation
// SOLID: Dependency Inversion - Depends on DataStore protocol, not concrete implementation
class MovieRepository: MovieRepositoryProtocol {
    private let localDataStore: MovieDataStoreProtocol
    private let remoteDataStore: MovieDataStoreProtocol

    // SOLID: Dependency Injection through initializer
    init(localDataStore: MovieDataStoreProtocol, remoteDataStore: MovieDataStoreProtocol) {
        self.localDataStore = localDataStore
        self.remoteDataStore = remoteDataStore
    }

    // Convenience initializer for backward compatibility
    convenience init(dataStore: MovieDataStoreProtocol) {
        self.init(localDataStore: LocalMovieDataStore(), remoteDataStore: dataStore)
    }

    func getCategories(completion: @escaping (Result<[Category], Error>) -> Void) {
        let categoryEndpoints: [(id: String, name: String, endpoint: String)] = [
            ("popular", "Popular", "/movie/popular"),
            ("top_rated", "Top Rated", "/movie/top_rated"),
            ("upcoming", "Upcoming", "/movie/upcoming"),
            ("now_playing", "Now Playing", "/movie/now_playing")
        ]

        // Try cache first
        tryFetchCategoriesFromCache(endpoints: categoryEndpoints) { [weak self] cachedResult in
            guard let self = self else { return }

            switch cachedResult {
            case .success(let cachedCategories):
                // Cache hit - return immediately
                completion(.success(cachedCategories))

                // Refresh in background
                self.refreshCategoriesInBackground(endpoints: categoryEndpoints)

            case .failure:
                // Cache miss - fetch from remote
                self.fetchCategoriesFromRemote(endpoints: categoryEndpoints, completion: completion)
            }
        }
    }

    private func tryFetchCategoriesFromCache(endpoints: [(id: String, name: String, endpoint: String)],
                                            completion: @escaping (Result<[Category], Error>) -> Void) {
        let group = DispatchGroup()
        var categories: [Category] = []
        var cacheError: Error?

        for category in endpoints {
            group.enter()
            localDataStore.fetchMovies(endpoint: category.endpoint) { result in
                switch result {
                case .success(let movieDTOs):
                    let movies = movieDTOs.prefix(10).map { $0.toDomain() }
                    let categoryModel = Category(id: category.id, name: category.name, movies: Array(movies))
                    categories.append(categoryModel)
                case .failure(let error):
                    cacheError = error
                }
                group.leave()
            }
        }

        group.notify(queue: .main) {
            if let error = cacheError {
                completion(.failure(error))
            } else {
                completion(.success(categories))
            }
        }
    }

    private func fetchCategoriesFromRemote(endpoints: [(id: String, name: String, endpoint: String)],
                                          completion: @escaping (Result<[Category], Error>) -> Void) {
        let group = DispatchGroup()
        var categories: [Category] = []
        var fetchError: Error?

        for category in endpoints {
            group.enter()
            remoteDataStore.fetchMovies(endpoint: category.endpoint) { [weak self] result in
                switch result {
                case .success(let movieDTOs):
                    // Save to cache
                    if let localStore = self?.localDataStore as? LocalMovieDataStore {
                        try? localStore.saveMovies(movieDTOs, forEndpoint: category.endpoint)
                    }

                    let movies = movieDTOs.prefix(10).map { $0.toDomain() }
                    let categoryModel = Category(id: category.id, name: category.name, movies: Array(movies))
                    categories.append(categoryModel)
                case .failure(let error):
                    fetchError = error
                }
                group.leave()
            }
        }

        group.notify(queue: .main) {
            if let error = fetchError {
                completion(.failure(error))
            } else {
                completion(.success(categories))
            }
        }
    }

    private func refreshCategoriesInBackground(endpoints: [(id: String, name: String, endpoint: String)]) {
        DispatchQueue.global(qos: .background).async { [weak self] in
            self?.fetchCategoriesFromRemote(endpoints: endpoints) { _ in
                // Silent refresh - no action needed
            }
        }
    }

    func getMovieDetails(movieId: Int, completion: @escaping (Result<Movie, Error>) -> Void) {
        // Try cache first
        tryFetchMovieDetailsFromCache(movieId: movieId) { [weak self] cachedResult in
            guard let self = self else { return }

            switch cachedResult {
            case .success(let cachedMovie):
                // Cache hit - return immediately
                completion(.success(cachedMovie))

                // Refresh in background
                self.refreshMovieDetailsInBackground(movieId: movieId)

            case .failure:
                // Cache miss - fetch from remote
                self.fetchMovieDetailsFromRemote(movieId: movieId, completion: completion)
            }
        }
    }

    private func tryFetchMovieDetailsFromCache(movieId: Int, completion: @escaping (Result<Movie, Error>) -> Void) {
        let group = DispatchGroup()
        var movieDTO: MovieDTO?
        var actors: [Actor] = []
        var images: [String] = []
        var cacheError: Error?

        // Fetch movie details from cache
        group.enter()
        localDataStore.fetchMovieDetails(movieId: movieId) { result in
            switch result {
            case .success(let dto):
                movieDTO = dto
            case .failure(let error):
                cacheError = error
            }
            group.leave()
        }

        // Fetch movie credits from cache
        group.enter()
        localDataStore.fetchMovieCredits(movieId: movieId) { result in
            switch result {
            case .success(let actorDTOs):
                actors = actorDTOs.prefix(10).map { $0.toDomain() }
            case .failure:
                // Non-critical, can continue without actors
                break
            }
            group.leave()
        }

        // Fetch movie images from cache
        group.enter()
        localDataStore.fetchMovieImages(movieId: movieId) { result in
            switch result {
            case .success(let imagePaths):
                images = imagePaths
            case .failure:
                // Non-critical, can continue without extra images
                break
            }
            group.leave()
        }

        group.notify(queue: .main) {
            if let error = cacheError {
                completion(.failure(error))
            } else if let dto = movieDTO {
                let movie = dto.toDomain(images: images, cast: actors)
                completion(.success(movie))
            } else {
                completion(.failure(CacheError.notFound))
            }
        }
    }

    private func fetchMovieDetailsFromRemote(movieId: Int, completion: @escaping (Result<Movie, Error>) -> Void) {
        let group = DispatchGroup()
        var movieDTO: MovieDTO?
        var actors: [Actor] = []
        var actorDTOs: [ActorDTO] = []
        var images: [String] = []
        var fetchError: Error?

        // Fetch movie details
        group.enter()
        remoteDataStore.fetchMovieDetails(movieId: movieId) { result in
            switch result {
            case .success(let dto):
                movieDTO = dto
            case .failure(let error):
                fetchError = error
            }
            group.leave()
        }

        // Fetch movie credits
        group.enter()
        remoteDataStore.fetchMovieCredits(movieId: movieId) { result in
            switch result {
            case .success(let dtos):
                actorDTOs = Array(dtos.prefix(10))
                actors = actorDTOs.map { $0.toDomain() }
            case .failure:
                // Non-critical, can continue without actors
                break
            }
            group.leave()
        }

        // Fetch movie images
        group.enter()
        remoteDataStore.fetchMovieImages(movieId: movieId) { result in
            switch result {
            case .success(let imagePaths):
                images = imagePaths
            case .failure:
                // Non-critical, can continue without extra images
                break
            }
            group.leave()
        }

        group.notify(queue: .main) { [weak self] in
            if let error = fetchError {
                completion(.failure(error))
            } else if let dto = movieDTO {
                // Save to cache
                if let localStore = self?.localDataStore as? LocalMovieDataStore {
                    try? localStore.saveMovieDetails(dto, actors: actorDTOs, images: images, movieId: movieId)
                }

                let movie = dto.toDomain(images: images, cast: actors)
                completion(.success(movie))
            } else {
                completion(.failure(NetworkError.noData))
            }
        }
    }

    private func refreshMovieDetailsInBackground(movieId: Int) {
        DispatchQueue.global(qos: .background).async { [weak self] in
            self?.fetchMovieDetailsFromRemote(movieId: movieId) { _ in
                // Silent refresh - no action needed
            }
        }
    }
}
