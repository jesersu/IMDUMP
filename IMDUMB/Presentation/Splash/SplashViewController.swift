import UIKit

// MARK: - Splash View Controller
// MVP Pattern: View layer, handles UI updates only
class SplashViewController: UIViewController {

    // MARK: - IBOutlets
    @IBOutlet weak var logoLabel: UILabel!
    @IBOutlet weak var welcomeLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    // MARK: - Properties
    var presenter: SplashPresenterProtocol!

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupPresenter()
        presenter.viewDidLoad()
    }

    private func setupUI() {
        view.backgroundColor = UIColor(red: 0.12, green: 0.12, blue: 0.12, alpha: 1.0)
        logoLabel?.font = UIFont.boldSystemFont(ofSize: 48)
        logoLabel?.textColor = .white
        welcomeLabel?.font = UIFont.systemFont(ofSize: 18)
        welcomeLabel?.textColor = .lightGray
        welcomeLabel?.text = ""
    }

    private func setupPresenter() {
        // Dependency Injection: Creating dependencies for presenter
        let configDataStore = FirebaseConfigDataStore()
        let configRepository = ConfigRepository(dataStore: configDataStore)
        let loadConfigUseCase = LoadConfigurationUseCase(repository: configRepository)

        presenter = SplashPresenter(view: self, loadConfigUseCase: loadConfigUseCase)
    }
}

// MARK: - SplashViewProtocol
extension SplashViewController: SplashViewProtocol {
    func showToast(_ message: String) {}
    
    func showLoading() {
        activityIndicator?.startAnimating()
    }

    func hideLoading() {
        activityIndicator?.stopAnimating()
    }

    func showError(_ message: String) {
        welcomeLabel?.text = "Error: \(message)"
        welcomeLabel?.textColor = .systemRed
    }

    func showWelcomeMessage(_ message: String) {
        welcomeLabel?.text = message
        welcomeLabel?.textColor = .white
    }

    func navigateToMain() {
        // Create and navigate to main categories screen
        let categoriesVC = CategoriesViewController(nibName: "CategoriesViewController", bundle: nil)
        let navController = UINavigationController(rootViewController: categoriesVC)
        navController.modalPresentationStyle = .fullScreen

        present(navController, animated: true)
    }
}
