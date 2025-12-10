import Foundation

// MARK: - Get Movie Details Use Case
// SOLID: Single Responsibility Principle - Only handles getting movie details
class GetMovieDetailsUseCase {
    private let repository: MovieRepositoryProtocol

    init(repository: MovieRepositoryProtocol) {
        self.repository = repository
    }

    func execute(movieId: Int, completion: @escaping (Result<Movie, Error>) -> Void) {
        repository.getMovieDetails(movieId: movieId, completion: completion)
    }
}
