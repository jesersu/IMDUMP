import Foundation

// MARK: - Splash Contract
// MVP Pattern: Defines contract between View and Presenter
protocol SplashViewProtocol: BaseViewProtocol {
    func navigateToMain()
    func showWelcomeMessage(_ message: String)
}

protocol SplashPresenterProtocol {
    func viewDidLoad()
}
