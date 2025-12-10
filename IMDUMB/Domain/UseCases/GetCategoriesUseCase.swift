import Foundation

// MARK: - Get Categories Use Case
// SOLID: Single Responsibility Principle - Only handles getting categories
// Clean Architecture: Use case contains business logic
class GetCategoriesUseCase {
    private let repository: MovieRepositoryProtocol

    // SOLID: Dependency Inversion - Depends on abstraction (protocol), not concrete implementation
    init(repository: MovieRepositoryProtocol) {
        self.repository = repository
    }

    func execute(completion: @escaping (Result<[Category], Error>) -> Void) {
        repository.getCategories(completion: completion)
    }
}
