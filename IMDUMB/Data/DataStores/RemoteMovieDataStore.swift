import Foundation
import IMDUMBPersistence
import RxSwift

// MARK: - Remote Movie Data Store
// SOLID: Single Responsibility - Handles remote data fetching only
// SOLID: Open/Closed Principle - Implements protocol, can be extended without modification
class RemoteMovieDataStore: MovieDataStoreProtocol {
    private let networkService: NetworkServiceProtocol

    init(networkService: NetworkServiceProtocol = NetworkService.shared) {
        self.networkService = networkService
    }

    func fetchMovies(endpoint: String) -> Single<[MovieDTO]> {
        return Single.create { [weak self] observer in
            guard let self = self else {
                observer(.failure(NetworkError.unknown))
                return Disposables.create()
            }

            self.networkService.request(endpoint: endpoint, method: .get, parameters: nil) {
                (result: Result<MoviesResponse, Error>) in
                switch result {
                case .success(let response):
                    observer(.success(response.results))
                case .failure(let error):
                    observer(.failure(error))
                }
            }

            return Disposables.create()
        }
    }

    func fetchMovieDetails(movieId: Int) -> Single<MovieDTO> {
        return Single.create { [weak self] observer in
            guard let self = self else {
                observer(.failure(NetworkError.unknown))
                return Disposables.create()
            }

            let endpoint = "/movie/\(movieId)"
            self.networkService.request(endpoint: endpoint, method: .get, parameters: nil) {
                (result: Result<MovieDTO, Error>) in
                switch result {
                case .success(let movie):
                    observer(.success(movie))
                case .failure(let error):
                    observer(.failure(error))
                }
            }

            return Disposables.create()
        }
    }

    func fetchMovieCredits(movieId: Int) -> Single<[ActorDTO]> {
        return Single.create { [weak self] observer in
            guard let self = self else {
                observer(.failure(NetworkError.unknown))
                return Disposables.create()
            }

            let endpoint = "/movie/\(movieId)/credits"
            self.networkService.request(endpoint: endpoint, method: .get, parameters: nil) {
                (result: Result<CreditsResponse, Error>) in
                switch result {
                case .success(let response):
                    observer(.success(response.cast))
                case .failure(let error):
                    observer(.failure(error))
                }
            }

            return Disposables.create()
        }
    }

    func fetchMovieImages(movieId: Int) -> Single<[String]> {
        return Single.create { [weak self] observer in
            guard let self = self else {
                observer(.failure(NetworkError.unknown))
                return Disposables.create()
            }

            let endpoint = "/movie/\(movieId)/images"
            self.networkService.request(endpoint: endpoint, method: .get, parameters: nil) {
                (result: Result<ImagesResponse, Error>) in
                switch result {
                case .success(let response):
                    let imagePaths = response.backdrops.prefix(5).map { $0.filePath }
                    observer(.success(Array(imagePaths)))
                case .failure(let error):
                    observer(.failure(error))
                }
            }

            return Disposables.create()
        }
    }
}
