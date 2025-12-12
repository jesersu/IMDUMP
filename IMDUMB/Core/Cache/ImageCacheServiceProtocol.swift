import Foundation
import UIKit

enum ImageType: String {
    case poster
    case backdrop
    case profile
}

protocol ImageCacheServiceProtocol {
    func saveImage(_ image: UIImage, forURL url: URL, type: ImageType) -> Bool
    func loadImage(forURL url: URL) -> UIImage?
    func isExpired(forURL url: URL, expirationInterval: TimeInterval) -> Bool
    func clearExpiredImages()
    func clearAll()
    func initialize()
}
