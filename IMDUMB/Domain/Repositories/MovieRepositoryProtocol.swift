import Foundation

// MARK: - Movie Repository Protocol
// SOLID: Dependency Inversion Principle - High-level modules depend on abstractions
// SOLID: Interface Segregation Principle - Specific interface for movie operations
protocol MovieRepositoryProtocol {
    func getCategories(completion: @escaping (Result<[Category], Error>) -> Void)
    func getMovieDetails(movieId: Int, completion: @escaping (Result<Movie, Error>) -> Void)
}
