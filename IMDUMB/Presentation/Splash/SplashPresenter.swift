import Foundation

// MARK: - Splash Presenter
// MVP Pattern: Presenter handles business logic and coordinates between View and Use Cases
class SplashPresenter: SplashPresenterProtocol {
    weak var view: SplashViewProtocol?
    private let loadConfigUseCase: LoadConfigurationUseCase

    init(view: SplashViewProtocol, loadConfigUseCase: LoadConfigurationUseCase) {
        self.view = view
        self.loadConfigUseCase = loadConfigUseCase
    }

    func viewDidLoad() {
        view?.showLoading()

        loadConfigUseCase.execute { [weak self] result in
            DispatchQueue.main.async {
                self?.view?.hideLoading()

                switch result {
                case .success(let config):
                    self?.view?.showWelcomeMessage(config.welcomeMessage)
                    // Wait a moment to show welcome message
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        self?.view?.navigateToMain()
                    }
                case .failure(let error):
                    self?.view?.showError(error.localizedDescription)
                    // Navigate anyway after showing error
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                        self?.view?.navigateToMain()
                    }
                }
            }
        }
    }
}
