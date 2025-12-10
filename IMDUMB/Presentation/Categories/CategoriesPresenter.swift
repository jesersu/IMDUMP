import Foundation

// MARK: - Categories Presenter
class CategoriesPresenter: CategoriesPresenterProtocol {
    weak var view: CategoriesViewProtocol?
    private let getCategoriesUseCase: GetCategoriesUseCase

    init(view: CategoriesViewProtocol, getCategoriesUseCase: GetCategoriesUseCase) {
        self.view = view
        self.getCategoriesUseCase = getCategoriesUseCase
    }

    func viewDidLoad() {
        view?.showLoading()

        getCategoriesUseCase.execute { [weak self] result in
            DispatchQueue.main.async {
                self?.view?.hideLoading()

                switch result {
                case .success(let categories):
                    self?.view?.displayCategories(categories)
                case .failure(let error):
                    self?.view?.showError("Failed to load categories: \(error.localizedDescription)")
                }
            }
        }
    }

    func didSelectMovie(_ movie: Movie) {
        // View will handle navigation
    }
}
