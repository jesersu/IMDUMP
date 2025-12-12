import Foundation
import RxSwift

// MARK: - Movie Repository Protocol
// SOLID: Dependency Inversion Principle - High-level modules depend on abstractions
// SOLID: Interface Segregation Principle - Specific interface for movie operations
protocol MovieRepositoryProtocol {
    func getCategories() -> Single<[Category]>
    func getMovieDetails(movieId: Int) -> Single<Movie>
}
