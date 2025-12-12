import Foundation

public enum CacheError: Error {
    case saveFailed
    case loadFailed
    case corruptedData
    case expired
    case notFound
    case encodingFailed
    case decodingFailed
    case diskFull
    case invalidCacheVersion
}

extension CacheError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .saveFailed:
            return "Failed to save data to cache"
        case .loadFailed:
            return "Failed to load data from cache"
        case .corruptedData:
            return "Cached data is corrupted or invalid"
        case .expired:
            return "Cached data has expired"
        case .notFound:
            return "Cached data not found"
        case .encodingFailed:
            return "Failed to encode data for caching"
        case .decodingFailed:
            return "Failed to decode cached data"
        case .diskFull:
            return "Insufficient disk space for caching"
        case .invalidCacheVersion:
            return "Cache version mismatch"
        }
    }
}
