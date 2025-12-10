import Foundation

// MARK: - Config Repository Implementation
class ConfigRepository: ConfigRepositoryProtocol {
    private let dataStore: ConfigDataStoreProtocol

    init(dataStore: ConfigDataStoreProtocol) {
        self.dataStore = dataStore
    }

    func loadConfiguration(completion: @escaping (Result<AppConfig, Error>) -> Void) {
        dataStore.fetchConfiguration { result in
            switch result {
            case .success(let configData):
                let config = AppConfig(
                    apiBaseURL: configData["api_base_url"] as? String ?? "",
                    apiKey: configData["api_key"] as? String ?? "",
                    enableFeatures: configData["enable_features"] as? [String: Bool] ?? [:],
                    welcomeMessage: configData["welcome_message"] as? String ?? "Welcome!"
                )
                completion(.success(config))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
