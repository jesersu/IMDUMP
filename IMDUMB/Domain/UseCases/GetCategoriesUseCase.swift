import Foundation
import RxSwift

// MARK: - Get Categories Use Case
// SOLID: Single Responsibility Principle - Only handles getting categories
// Clean Architecture: Use case contains business logic
class GetCategoriesUseCase {
    private let repository: MovieRepositoryProtocol

    // SOLID: Dependency Inversion - Depends on abstraction (protocol), not concrete implementation
    init(repository: MovieRepositoryProtocol) {
        self.repository = repository
    }

    func execute() -> Single<[Category]> {
        return repository.getCategories()
            .map { categories in
                categories.filter { !$0.movies.isEmpty }
            }
    }
}
