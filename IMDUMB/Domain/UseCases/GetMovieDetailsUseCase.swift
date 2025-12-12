import Foundation
import RxSwift

// MARK: - Get Movie Details Use Case
// SOLID: Single Responsibility Principle - Only handles getting movie details
class GetMovieDetailsUseCase {
    private let repository: MovieRepositoryProtocol

    init(repository: MovieRepositoryProtocol) {
        self.repository = repository
    }

    func execute(movieId: Int) -> Single<Movie> {
        return repository.getMovieDetails(movieId: movieId)
    }
}
