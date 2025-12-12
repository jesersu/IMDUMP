import Foundation
import RxSwift

// MARK: - Categories Presenter
class CategoriesPresenter: CategoriesPresenterProtocol {
    weak var view: CategoriesViewProtocol?
    private let getCategoriesUseCase: GetCategoriesUseCase
    private let disposeBag = DisposeBag()

    init(view: CategoriesViewProtocol, getCategoriesUseCase: GetCategoriesUseCase) {
        self.view = view
        self.getCategoriesUseCase = getCategoriesUseCase
    }

    func viewDidLoad() {
        // Check network status before loading
        let isOffline = !NetworkReachability.shared.isReachable

        view?.showLoading()

        getCategoriesUseCase.execute()
            .observe(on: MainScheduler.instance)
            .do(
                onSuccess: { [weak self] _ in self?.view?.hideLoading() },
                onError: { [weak self] _ in self?.view?.hideLoading() }
            )
            .subscribe(
                onSuccess: { [weak self] categories in
                    self?.view?.displayCategories(categories)

                    // Show toast if displaying cached data while offline
                    if isOffline {
                        self?.view?.showToast("You're offline - showing cached data")
                    }
                },
                onFailure: { [weak self] error in
                    self?.view?.showError("Failed to load categories: \(error.localizedDescription)")
                }
            )
            .disposed(by: disposeBag)
    }

    func didSelectMovie(_ movie: Movie) {
        // View will handle navigation
    }
}
