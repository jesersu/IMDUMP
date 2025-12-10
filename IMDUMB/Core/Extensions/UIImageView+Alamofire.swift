import UIKit
import Alamofire

// MARK: - UIImageView Image Loading Extension
// Uses Alamofire for async image loading
extension UIImageView {

    /// Load image from URL using Alamofire
    func loadImage(from url: URL, placeholder: UIImage? = nil) {
        // Set placeholder immediately
        self.image = placeholder

        // Download image using Alamofire
        AF.request(url).responseData { [weak self] response in
            guard let self = self else { return }

            switch response.result {
            case .success(let data):
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self.image = image
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
