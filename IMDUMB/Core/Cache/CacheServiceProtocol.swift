import Foundation

protocol CacheServiceProtocol {
    func save<T: Codable>(_ object: T, forKey key: String) throws
    func load<T: Codable>(forKey key: String) -> T?
    func remove(forKey key: String)
    func isExpired(forKey key: String, expirationInterval: TimeInterval) -> Bool
    func clearAll()
    func initialize()
}
