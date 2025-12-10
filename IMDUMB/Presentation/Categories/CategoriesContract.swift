import Foundation

// MARK: - Categories Contract
// MVP Pattern: Contract between View and Presenter
protocol CategoriesViewProtocol: BaseViewProtocol {
    func displayCategories(_ categories: [Category])
}

protocol CategoriesPresenterProtocol {
    func viewDidLoad()
    func didSelectMovie(_ movie: Movie)
}
