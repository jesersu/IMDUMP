import Foundation

// MARK: - Secrets Manager
// Uses Arkana to securely access encrypted API keys and sensitive information
// SOLID: Single Responsibility - Only handles secret retrieval

struct SecretsManager {

    // MARK: - Singleton
    static let shared = SecretsManager()

    private init() {}

    // MARK: - Public Properties

    /// TMDB API Key - Encrypted by Arkana
    var tmdbAPIKey: String {
        // When Arkana is set up, this will use the encrypted keys
        // For now, returns a placeholder that needs to be replaced
        #if DEBUG
        return ProcessInfo.processInfo.environment["TMDB_API_KEY"] ?? "YOUR_API_KEY_HERE"
        #else
        // In production, this should use Arkana's encrypted keys
        // Example: return ArkanaKeys.Global.current.tMDBAPIKey
        return ProcessInfo.processInfo.environment["TMDB_API_KEY"] ?? "YOUR_API_KEY_HERE"
        #endif
    }

    /// Firebase API Key - Encrypted by Arkana
    var firebaseAPIKey: String {
        #if DEBUG
        return ProcessInfo.processInfo.environment["FIREBASE_API_KEY"] ?? "YOUR_FIREBASE_KEY_HERE"
        #else
        return ProcessInfo.processInfo.environment["FIREBASE_API_KEY"] ?? "YOUR_FIREBASE_KEY_HERE"
        #endif
    }

    /// API Base URL - Encrypted by Arkana
    var apiBaseURL: String {
        return "https://api.themoviedb.org/3"
    }
}

// MARK: - Usage Example
/*
 To use encrypted secrets:

 1. Install Arkana: gem install arkana
 2. Copy .env.sample to .env and add your real keys
 3. Run: arkana -e .env
 4. Import the generated package in your target
 5. Replace the implementations above with:

    var tmdbAPIKey: String {
        return ArkanaKeys.Global.current.tMDBAPIKey
    }
 */
