import UIKit

// MARK: - UIViewController Loading Extension
// Reusable loading indicator functionality
extension UIViewController {
    private static var loadingViewTag: Int { return 999999 }

    func showLoadingIndicator() {
        guard view.viewWithTag(Self.loadingViewTag) == nil else { return }

        let loadingView = UIView(frame: view.bounds)
        loadingView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        loadingView.tag = Self.loadingViewTag
        loadingView.translatesAutoresizingMaskIntoConstraints = false

        let activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.color = .white
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.startAnimating()

        loadingView.addSubview(activityIndicator)
        view.addSubview(loadingView)

        NSLayoutConstraint.activate([
            loadingView.topAnchor.constraint(equalTo: view.topAnchor),
            loadingView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            loadingView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            loadingView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            activityIndicator.centerXAnchor.constraint(equalTo: loadingView.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: loadingView.centerYAnchor)
        ])
    }

    func hideLoadingIndicator() {
        view.viewWithTag(Self.loadingViewTag)?.removeFromSuperview()
    }
}
