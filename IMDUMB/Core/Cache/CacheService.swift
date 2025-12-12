import Foundation

class CacheService: CacheServiceProtocol {
    static let shared = CacheService()

    private let userDefaults: UserDefaults
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder
    private let cacheVersion = "1.0"

    private init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
        self.encoder = JSONEncoder()
        self.encoder.dateEncodingStrategy = .iso8601
        self.decoder = JSONDecoder()
        self.decoder.dateDecodingStrategy = .iso8601
    }

    func initialize() {
        let cachedVersion = userDefaults.string(forKey: CacheKey.version)

        if cachedVersion != cacheVersion {
            clearAll()
            userDefaults.set(cacheVersion, forKey: CacheKey.version)
        }
    }

    func save<T: Codable>(_ object: T, forKey key: String) throws {
        do {
            let data = try encoder.encode(object)
            userDefaults.set(data, forKey: key)

            let timestamp = Date()
            let timestampData = try encoder.encode(timestamp)
            userDefaults.set(timestampData, forKey: CacheKey.timestamp(for: key))

            userDefaults.synchronize()
        } catch {
            throw CacheError.encodingFailed
        }
    }

    func load<T: Codable>(forKey key: String) -> T? {
        guard let data = userDefaults.data(forKey: key) else {
            return nil
        }

        do {
            let object = try decoder.decode(T.self, from: data)
            return object
        } catch {
            remove(forKey: key)
            return nil
        }
    }

    func remove(forKey key: String) {
        userDefaults.removeObject(forKey: key)
        userDefaults.removeObject(forKey: CacheKey.timestamp(for: key))
        userDefaults.synchronize()
    }

    func isExpired(forKey key: String, expirationInterval: TimeInterval) -> Bool {
        guard let timestampData = userDefaults.data(forKey: CacheKey.timestamp(for: key)) else {
            return true
        }

        do {
            let timestamp = try decoder.decode(Date.self, from: timestampData)
            let elapsed = Date().timeIntervalSince(timestamp)
            return elapsed > expirationInterval
        } catch {
            return true
        }
    }

    func clearAll() {
        let allKeys = userDefaults.dictionaryRepresentation().keys
        for key in allKeys where key.hasPrefix("cache.") {
            userDefaults.removeObject(forKey: key)
        }
        userDefaults.synchronize()
    }
}

struct CacheKey {
    static func category(_ id: String) -> String { "cache.category.\(id)" }
    static func movieDetails(_ id: Int) -> String { "cache.movie.\(id)" }
    static func timestamp(for key: String) -> String { "\(key).timestamp" }
    static let version = "cache.version"
}
