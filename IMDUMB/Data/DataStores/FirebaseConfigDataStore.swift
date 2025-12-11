import Foundation
import FirebaseRemoteConfig

// MARK: - Firebase Config Data Store
// Handles Firebase Remote Config for dynamic app configuration
class FirebaseConfigDataStore: ConfigDataStoreProtocol {

    private let remoteConfig: RemoteConfig

    init() {
        remoteConfig = RemoteConfig.remoteConfig()

        // Set default configuration values
        let defaults: [String: NSObject] = [
            "api_base_url": "https://api.themoviedb.org/3" as NSString,
            "api_key": "" as NSString,
            "welcome_message": "Welcome to IMDUMB!" as NSString,
            "dark_mode": NSNumber(value: true),
            "recommendations": NSNumber(value: true),
            "social_sharing": NSNumber(value: false)
        ]

        remoteConfig.setDefaults(defaults)

        // Configure settings for development (faster fetch intervals)
        let settings = RemoteConfigSettings()
        settings.minimumFetchInterval = 0 // For development only - use 3600 in production
        remoteConfig.configSettings = settings
    }

    func fetchConfiguration(completion: @escaping (Result<[String: Any], Error>) -> Void) {
        // Fetch and activate remote config values
        remoteConfig.fetchAndActivate { [weak self] status, error in
            guard let self = self else { return }

            if let error = error {
                print("Firebase Remote Config fetch error: \(error.localizedDescription)")
                // Fall back to defaults on error
                completion(.success(self.getConfigurationValues()))
                return
            }

            switch status {
            case .successFetchedFromRemote:
                print("Firebase Remote Config: fetched from remote")
                completion(.success(self.getConfigurationValues()))
            case .successUsingPreFetchedData:
                print("Firebase Remote Config: using cached data")
                completion(.success(self.getConfigurationValues()))
            case .error:
                print("Firebase Remote Config: error status")
                completion(.success(self.getConfigurationValues()))
            @unknown default:
                completion(.success(self.getConfigurationValues()))
            }
        }
    }

    private func getConfigurationValues() -> [String: Any] {
        let config: [String: Any] = [
            "api_base_url": remoteConfig.configValue(forKey: "api_base_url").stringValue ?? "https://api.themoviedb.org/3",
            "api_key": remoteConfig.configValue(forKey: "api_key").stringValue ?? "",
            "welcome_message": remoteConfig.configValue(forKey: "welcome_message").stringValue ?? "Welcome to IMDUMB!",
            "enable_features": [
                "dark_mode": remoteConfig.configValue(forKey: "dark_mode").boolValue,
                "recommendations": remoteConfig.configValue(forKey: "recommendations").boolValue,
                "social_sharing": remoteConfig.configValue(forKey: "social_sharing").boolValue
            ]
        ]
        return config
    }
}
