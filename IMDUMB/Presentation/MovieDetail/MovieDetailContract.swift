import Foundation

// MARK: - Movie Detail Contract
protocol MovieDetailViewProtocol: BaseViewProtocol {
    func displayMovieDetails()
    func showRecommendationModal()
}

protocol MovieDetailPresenterProtocol {
    func viewDidLoad()
    func didTapRecommend()
}
