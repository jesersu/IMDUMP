import Foundation

// MARK: - Firebase Config Data Store
// Handles Firebase Remote Config or Realtime Database
class FirebaseConfigDataStore: ConfigDataStoreProtocol {

    func fetchConfiguration(completion: @escaping (Result<[String: Any], Error>) -> Void) {
        // For now, we'll use mock configuration
        // In production, this would use Firebase RemoteConfig or Realtime Database
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            let mockConfig: [String: Any] = [
                "api_base_url": "https://api.themoviedb.org/3",
                "api_key": "YOUR_TMDB_API_KEY",
                "welcome_message": "Welcome to IMDUMB!",
                "enable_features": [
                    "dark_mode": true,
                    "recommendations": true,
                    "social_sharing": false
                ]
            ]
            completion(.success(mockConfig))
        }
    }
}
