import Foundation
import IMDUMBPersistence
import RxSwift

// MARK: - Movie Repository Implementation
// SOLID: Dependency Inversion - Depends on DataStore protocol, not concrete implementation
class MovieRepository: MovieRepositoryProtocol {
    private let localDataStore: MovieDataStoreProtocol
    private let remoteDataStore: MovieDataStoreProtocol
    private let disposeBag = DisposeBag()

    // SOLID: Dependency Injection through initializer
    init(localDataStore: MovieDataStoreProtocol, remoteDataStore: MovieDataStoreProtocol) {
        self.localDataStore = localDataStore
        self.remoteDataStore = remoteDataStore
    }

    // Convenience initializer for backward compatibility
    convenience init(dataStore: MovieDataStoreProtocol) {
        self.init(localDataStore: LocalMovieDataStore(), remoteDataStore: dataStore)
    }

    func getCategories() -> Single<[Category]> {
        let categoryEndpoints: [(id: String, name: String, endpoint: String)] = [
            ("popular", "Popular", "/movie/popular"),
            ("top_rated", "Top Rated", "/movie/top_rated"),
            ("upcoming", "Upcoming", "/movie/upcoming"),
            ("now_playing", "Now Playing", "/movie/now_playing")
        ]

        // Cache-first with fallback to remote
        return fetchCategoriesFromCache(endpoints: categoryEndpoints)
            .do(onSuccess: { [weak self] _ in
                // Trigger background refresh on cache hit
                self?.refreshCategoriesInBackground(endpoints: categoryEndpoints)
            })
            .catch { [weak self] _ in
                // Cache miss or expired - fetch from remote
                guard let self = self else {
                    return Single.error(NetworkError.unknown)
                }
                return self.fetchCategoriesFromRemote(endpoints: categoryEndpoints)
            }
    }

    private func fetchCategoriesFromCache(endpoints: [(id: String, name: String, endpoint: String)]) -> Single<[Category]> {
        let singles = endpoints.map { category in
            localDataStore.fetchMovies(endpoint: category.endpoint)
                .map { movieDTOs in
                    let movies = movieDTOs.prefix(10).map { $0.toDomain() }
                    return Category(id: category.id, name: category.name, movies: Array(movies))
                }
        }

        return Single.zip(singles)
    }

    private func fetchCategoriesFromRemote(endpoints: [(id: String, name: String, endpoint: String)]) -> Single<[Category]> {
        let singles = endpoints.map { category in
            remoteDataStore.fetchMovies(endpoint: category.endpoint)
                .do(onSuccess: { [weak self] movieDTOs in
                    // Save to cache
                    if let localStore = self?.localDataStore as? LocalMovieDataStore {
                        try? localStore.saveMovies(movieDTOs, forEndpoint: category.endpoint)
                    }
                })
                .map { movieDTOs in
                    let movies = movieDTOs.prefix(10).map { $0.toDomain() }
                    return Category(id: category.id, name: category.name, movies: Array(movies))
                }
        }

        return Single.zip(singles)
    }

    private func refreshCategoriesInBackground(endpoints: [(id: String, name: String, endpoint: String)]) {
        fetchCategoriesFromRemote(endpoints: endpoints)
            .subscribe(onSuccess: { _ in
                // Silent refresh - categories updated in cache
            }, onFailure: { _ in
                // Silent failure - user already has cached data
            })
            .disposed(by: disposeBag)
    }

    func getMovieDetails(movieId: Int) -> Single<Movie> {
        // Cache-first with fallback to remote
        return fetchMovieDetailsFromCache(movieId: movieId)
            .do(onSuccess: { [weak self] _ in
                // Trigger background refresh on cache hit
                self?.refreshMovieDetailsInBackground(movieId: movieId)
            })
            .catch { [weak self] _ in
                // Cache miss or expired - fetch from remote
                guard let self = self else {
                    return Single.error(NetworkError.unknown)
                }
                return self.fetchMovieDetailsFromRemote(movieId: movieId)
            }
    }

    private func fetchMovieDetailsFromCache(movieId: Int) -> Single<Movie> {
        let movieSingle = localDataStore.fetchMovieDetails(movieId: movieId)
        let actorsSingle = localDataStore.fetchMovieCredits(movieId: movieId)
            .map { actorDTOs in actorDTOs.prefix(10).map { $0.toDomain() } }
            .catchAndReturn([])  // Non-critical, continue without actors
        let imagesSingle = localDataStore.fetchMovieImages(movieId: movieId)
            .catchAndReturn([])  // Non-critical, continue without images

        return Single.zip(movieSingle, actorsSingle, imagesSingle)
            .map { movieDTO, actors, images in
                movieDTO.toDomain(images: images, cast: actors)
            }
    }

    private func fetchMovieDetailsFromRemote(movieId: Int) -> Single<Movie> {
        let movieSingle = remoteDataStore.fetchMovieDetails(movieId: movieId)
        let actorsSingle = remoteDataStore.fetchMovieCredits(movieId: movieId)
            .map { Array($0.prefix(10)) }
            .catchAndReturn([])  // Non-critical, continue without actors
        let imagesSingle = remoteDataStore.fetchMovieImages(movieId: movieId)
            .catchAndReturn([])  // Non-critical, continue without images

        return Single.zip(movieSingle, actorsSingle, imagesSingle)
            .do(onSuccess: { [weak self] movieDTO, actorDTOs, images in
                // Save to cache
                if let localStore = self?.localDataStore as? LocalMovieDataStore {
                    try? localStore.saveMovieDetails(movieDTO, actors: actorDTOs, images: images, movieId: movieId)
                }
            })
            .map { movieDTO, actorDTOs, images in
                let actors = actorDTOs.map { $0.toDomain() }
                return movieDTO.toDomain(images: images, cast: actors)
            }
    }

    private func refreshMovieDetailsInBackground(movieId: Int) {
        fetchMovieDetailsFromRemote(movieId: movieId)
            .subscribe(onSuccess: { _ in
                // Silent refresh - movie details updated in cache
            }, onFailure: { _ in
                // Silent failure - user already has cached data
            })
            .disposed(by: disposeBag)
    }
}
