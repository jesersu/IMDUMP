import Foundation
import IMDUMBPersistence

// MARK: - Remote Movie Data Store
// SOLID: Single Responsibility - Handles remote data fetching only
// SOLID: Open/Closed Principle - Implements protocol, can be extended without modification
class RemoteMovieDataStore: MovieDataStoreProtocol {
    private let networkService: NetworkServiceProtocol

    init(networkService: NetworkServiceProtocol = NetworkService.shared) {
        self.networkService = networkService
    }

    func fetchMovies(endpoint: String, completion: @escaping (Result<[MovieDTO], Error>) -> Void) {
        networkService.request(endpoint: endpoint, method: .get, parameters: nil) { (result: Result<MoviesResponse, Error>) in
            switch result {
            case .success(let response):
                completion(.success(response.results))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    func fetchMovieDetails(movieId: Int, completion: @escaping (Result<MovieDTO, Error>) -> Void) {
        let endpoint = "/movie/\(movieId)"
        networkService.request(endpoint: endpoint, method: .get, parameters: nil, completion: completion)
    }

    func fetchMovieCredits(movieId: Int, completion: @escaping (Result<[ActorDTO], Error>) -> Void) {
        let endpoint = "/movie/\(movieId)/credits"
        networkService.request(endpoint: endpoint, method: .get, parameters: nil) { (result: Result<CreditsResponse, Error>) in
            switch result {
            case .success(let response):
                completion(.success(response.cast))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    func fetchMovieImages(movieId: Int, completion: @escaping (Result<[String], Error>) -> Void) {
        let endpoint = "/movie/\(movieId)/images"
        networkService.request(endpoint: endpoint, method: .get, parameters: nil) { (result: Result<ImagesResponse, Error>) in
            switch result {
            case .success(let response):
                let imagePaths = response.backdrops.prefix(5).map { $0.filePath }
                completion(.success(Array(imagePaths)))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
