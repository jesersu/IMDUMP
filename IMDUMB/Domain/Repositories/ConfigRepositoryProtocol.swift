import Foundation

// MARK: - Config Repository Protocol
// Protocol for Firebase configuration operations
protocol ConfigRepositoryProtocol {
    func loadConfiguration(completion: @escaping (Result<AppConfig, Error>) -> Void)
}

// MARK: - App Configuration Model
struct AppConfig {
    let apiBaseURL: String
    let apiKey: String
    let enableFeatures: [String: Bool]
    let welcomeMessage: String
}
