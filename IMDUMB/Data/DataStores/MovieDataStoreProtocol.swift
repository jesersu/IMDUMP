import Foundation

// MARK: - Data Store Protocol
// SOLID: Open/Closed Principle - Open for extension (different implementations), closed for modification
protocol MovieDataStoreProtocol {
    func fetchMovies(endpoint: String, completion: @escaping (Result<[MovieDTO], Error>) -> Void)
    func fetchMovieDetails(movieId: Int, completion: @escaping (Result<MovieDTO, Error>) -> Void)
    func fetchMovieCredits(movieId: Int, completion: @escaping (Result<[ActorDTO], Error>) -> Void)
    func fetchMovieImages(movieId: Int, completion: @escaping (Result<[String], Error>) -> Void)
}

protocol ConfigDataStoreProtocol {
    func fetchConfiguration(completion: @escaping (Result<[String: Any], Error>) -> Void)
}
