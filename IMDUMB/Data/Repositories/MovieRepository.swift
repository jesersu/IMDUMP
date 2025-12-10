import Foundation

// MARK: - Movie Repository Implementation
// SOLID: Dependency Inversion - Depends on DataStore protocol, not concrete implementation
class MovieRepository: MovieRepositoryProtocol {
    private let dataStore: MovieDataStoreProtocol

    // SOLID: Dependency Injection through initializer
    init(dataStore: MovieDataStoreProtocol) {
        self.dataStore = dataStore
    }

    func getCategories(completion: @escaping (Result<[Category], Error>) -> Void) {
        let group = DispatchGroup()
        var categories: [Category] = []
        var fetchError: Error?

        let categoryEndpoints: [(id: String, name: String, endpoint: String)] = [
            ("popular", "Popular", "/movie/popular"),
            ("top_rated", "Top Rated", "/movie/top_rated"),
            ("upcoming", "Upcoming", "/movie/upcoming"),
            ("now_playing", "Now Playing", "/movie/now_playing")
        ]

        for category in categoryEndpoints {
            group.enter()
            dataStore.fetchMovies(endpoint: category.endpoint) { result in
                switch result {
                case .success(let movieDTOs):
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

    func getMovieDetails(movieId: Int, completion: @escaping (Result<Movie, Error>) -> Void) {
        let group = DispatchGroup()
        var movieDTO: MovieDTO?
        var actors: [Actor] = []
        var images: [String] = []
        var fetchError: Error?

        // Fetch movie details
        group.enter()
        dataStore.fetchMovieDetails(movieId: movieId) { result in
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
        dataStore.fetchMovieCredits(movieId: movieId) { result in
            switch result {
            case .success(let actorDTOs):
                actors = actorDTOs.prefix(10).map { $0.toDomain() }
            case .failure:
                // Non-critical, can continue without actors
                break
            }
            group.leave()
        }

        // Fetch movie images
        group.enter()
        dataStore.fetchMovieImages(movieId: movieId) { result in
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
            if let error = fetchError {
                completion(.failure(error))
            } else if let dto = movieDTO {
                let movie = dto.toDomain(images: images, cast: actors)
                completion(.success(movie))
            } else {
                completion(.failure(NetworkError.noData))
            }
        }
    }
}
