import Foundation

// MARK: - Movie Detail Presenter
class MovieDetailPresenter: MovieDetailPresenterProtocol {
    weak var view: MovieDetailViewProtocol?
    private let movie: Movie

    init(view: MovieDetailViewProtocol, movie: Movie) {
        self.view = view
        self.movie = movie
    }

    func viewDidLoad() {
        view?.displayMovieDetails()
    }

    func didTapRecommend() {
        view?.showRecommendationModal()
    }
}
