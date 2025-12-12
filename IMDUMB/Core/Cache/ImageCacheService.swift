import Foundation
import UIKit
import CommonCrypto

class ImageCacheService: ImageCacheServiceProtocol {
    static let shared = ImageCacheService()

    private let fileManager = FileManager.default
    private let cacheDirectory: URL
    private let metadataKey = "image.cache.metadata"
    private var metadata: [String: Date] = [:]

    private init() {
        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        self.cacheDirectory = documentsURL.appendingPathComponent("ImageCache")
    }

    func initialize() {
        createDirectoryStructure()
        loadMetadata()
    }

    private func createDirectoryStructure() {
        let subdirectories = [
            cacheDirectory.appendingPathComponent("posters"),
            cacheDirectory.appendingPathComponent("backdrops"),
            cacheDirectory.appendingPathComponent("profiles")
        ]

        for directory in subdirectories {
            if !fileManager.fileExists(atPath: directory.path) {
                try? fileManager.createDirectory(at: directory, withIntermediateDirectories: true, attributes: nil)
            }
        }
    }

    func saveImage(_ image: UIImage, forURL url: URL, type: ImageType) -> Bool {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            return false
        }

        let fileURL = fileURL(for: url, type: type)

        do {
            try imageData.write(to: fileURL)
            metadata[url.absoluteString] = Date()
            saveMetadata()
            return true
        } catch {
            return false
        }
    }

    func loadImage(forURL url: URL) -> UIImage? {
        for type in [ImageType.poster, .backdrop, .profile] {
            let fileURL = fileURL(for: url, type: type)
            if let imageData = try? Data(contentsOf: fileURL),
               let image = UIImage(data: imageData) {
                return image
            }
        }
        return nil
    }

    func isExpired(forURL url: URL, expirationInterval: TimeInterval) -> Bool {
        guard let timestamp = metadata[url.absoluteString] else {
            return true
        }

        let elapsed = Date().timeIntervalSince(timestamp)
        return elapsed > expirationInterval
    }

    func clearExpiredImages() {
        let expirationInterval: TimeInterval = 24 * 60 * 60
        var expiredURLs: [String] = []

        for (urlString, timestamp) in metadata {
            let elapsed = Date().timeIntervalSince(timestamp)
            if elapsed > expirationInterval {
                expiredURLs.append(urlString)

                if let url = URL(string: urlString) {
                    for type in [ImageType.poster, .backdrop, .profile] {
                        let fileURL = fileURL(for: url, type: type)
                        try? fileManager.removeItem(at: fileURL)
                    }
                }
            }
        }

        for urlString in expiredURLs {
            metadata.removeValue(forKey: urlString)
        }

        if !expiredURLs.isEmpty {
            saveMetadata()
        }
    }

    func clearAll() {
        try? fileManager.removeItem(at: cacheDirectory)
        metadata.removeAll()
        saveMetadata()
        createDirectoryStructure()
    }

    private func fileURL(for url: URL, type: ImageType) -> URL {
        let hash = md5Hash(of: url.absoluteString)
        let subdirectory = cacheDirectory.appendingPathComponent("\(type.rawValue)s")
        return subdirectory.appendingPathComponent("\(hash).jpg")
    }

    private func md5Hash(of string: String) -> String {
        guard let data = string.data(using: .utf8) else {
            return string
        }

        var digest = [UInt8](repeating: 0, count: Int(CC_MD5_DIGEST_LENGTH))
        data.withUnsafeBytes { buffer in
            _ = CC_MD5(buffer.baseAddress, CC_LONG(buffer.count), &digest)
        }

        return digest.map { String(format: "%02hhx", $0) }.joined()
    }

    private func loadMetadata() {
        if let data = UserDefaults.standard.data(forKey: metadataKey),
           let decoded = try? JSONDecoder().decode([String: Date].self, from: data) {
            metadata = decoded
        }
    }

    private func saveMetadata() {
        if let encoded = try? JSONEncoder().encode(metadata) {
            UserDefaults.standard.set(encoded, forKey: metadataKey)
        }
    }
}
