import UIKit

// MARK: - UIViewController Loading & Toast Extension
// Reusable loading indicator and toast functionality
extension UIViewController {
    private static var loadingViewTag: Int { return 999999 }
    private static var toastViewTag: Int { return 888888 }

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

    func showToastMessage(_ message: String, duration: TimeInterval = 3.0) {
        // Remove any existing toast
        view.viewWithTag(Self.toastViewTag)?.removeFromSuperview()

        // Create toast container
        let toastView = UIView()
        toastView.backgroundColor = UIColor.green.withAlphaComponent(0.8)
        toastView.layer.cornerRadius = 10
        toastView.tag = Self.toastViewTag
        toastView.translatesAutoresizingMaskIntoConstraints = false
        toastView.alpha = 0

        // Create label
        let label = UILabel()
        label.text = message
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false

        toastView.addSubview(label)
        view.addSubview(toastView)

        // Add constraints
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: toastView.topAnchor, constant: 12),
            label.leadingAnchor.constraint(equalTo: toastView.leadingAnchor, constant: 16),
            label.trailingAnchor.constraint(equalTo: toastView.trailingAnchor, constant: -16),
            label.bottomAnchor.constraint(equalTo: toastView.bottomAnchor, constant: -12),

            toastView.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 16),
            toastView.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -16),
            toastView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            toastView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])

        // Animate in
        UIView.animate(withDuration: 0.3, animations: {
            toastView.alpha = 1.0
        }) { _ in
            // Auto-dismiss after duration
            UIView.animate(withDuration: 0.3, delay: duration, options: [], animations: {
                toastView.alpha = 0.0
            }) { _ in
                toastView.removeFromSuperview()
            }
        }
    }
}
