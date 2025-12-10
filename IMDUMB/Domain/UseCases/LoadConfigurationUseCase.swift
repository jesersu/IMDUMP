import Foundation

// MARK: - Load Configuration Use Case
// Handles loading app configuration from Firebase
class LoadConfigurationUseCase {
    private let repository: ConfigRepositoryProtocol

    init(repository: ConfigRepositoryProtocol) {
        self.repository = repository
    }

    func execute(completion: @escaping (Result<AppConfig, Error>) -> Void) {
        repository.loadConfiguration(completion: completion)
    }
}
