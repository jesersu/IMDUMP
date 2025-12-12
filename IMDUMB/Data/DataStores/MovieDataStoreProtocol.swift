import Foundation
import IMDUMBPersistence
import RxSwift

// MARK: - Data Store Protocol
// SOLID: Open/Closed Principle - Open for extension (different implementations), closed for modification
protocol MovieDataStoreProtocol {
    func fetchMovies(endpoint: String) -> Single<[MovieDTO]>
    func fetchMovieDetails(movieId: Int) -> Single<MovieDTO>
    func fetchMovieCredits(movieId: Int) -> Single<[ActorDTO]>
    func fetchMovieImages(movieId: Int) -> Single<[String]>
}

protocol ConfigDataStoreProtocol {
    func fetchConfiguration(completion: @escaping (Result<[String: Any], Error>) -> Void)
}
