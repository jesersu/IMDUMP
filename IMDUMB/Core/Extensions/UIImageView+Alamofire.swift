import UIKit
import Alamofire

// MARK: - UIImageView Image Loading Extension
// Uses Alamofire for async image loading with persistent caching
extension UIImageView {

    /// Load image from URL using cache-first strategy with Alamofire
    func loadImage(from url: URL, placeholder: UIImage? = nil, imageType: ImageType = .poster) {
        // Set placeholder immediately
        self.image = placeholder

        let cacheService = ImageCacheService.shared
        let expirationInterval: TimeInterval = 24 * 60 * 60

        // Check cache first
        if let cachedImage = cacheService.loadImage(forURL: url) {
            DispatchQueue.main.async { [weak self] in
                self?.image = cachedImage
            }

            // If expired, refresh in background
            if cacheService.isExpired(forURL: url, expirationInterval: expirationInterval) {
                downloadAndCacheImage(from: url, imageType: imageType, updateUI: false)
            }
            return
        }

        // Not cached - download and cache
        downloadAndCacheImage(from: url, imageType: imageType, updateUI: true)
    }

    private func downloadAndCacheImage(from url: URL, imageType: ImageType, updateUI: Bool) {
        AF.request(url).responseData { [weak self] response in
            guard let self = self else { return }

            switch response.result {
            case .success(let data):
                if let image = UIImage(data: data) {
                    // Save to cache
                    _ = ImageCacheService.shared.saveImage(image, forURL: url, type: imageType)

                    // Update UI if needed
                    if updateUI {
                        DispatchQueue.main.async {
                            self.image = image
                        }
                    }
                }
            case .failure(let error):
                print("Image loading error: \(error.localizedDescription)")
                // Keep placeholder on error
            }
        }
    }

    /// Cancel any ongoing image download
    func cancelImageLoad() {
        // Alamofire automatically cancels requests when deallocated
    }
}
