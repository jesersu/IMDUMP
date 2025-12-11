import UIKit

// MARK: - Categories View Controller
// MVP Pattern: View displays categories in UICollectionView
class CategoriesViewController: UIViewController {

    // MARK: - IBOutlets
    @IBOutlet weak var categoriesCollectionView: UICollectionView!

    // MARK: - Properties
    var presenter: CategoriesPresenterProtocol!
    private var categories: [Category] = []

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupCollectionView()
        setupPresenter()
        presenter.viewDidLoad()
    }

    private func setupUI() {
        title = "IMDUMB"
        view.backgroundColor = UIColor(red: 0.12, green: 0.12, blue: 0.12, alpha: 1.0)

        // Navigation bar styling
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.backgroundColor = .clear
        navigationController?.navigationBar.barTintColor = UIColor(red: 0.12, green: 0.12, blue: 0.12, alpha: 1.0)
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
        navigationController?.navigationBar.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
    }

    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 20
        layout.sectionInset = UIEdgeInsets(top: 20, left: 0, bottom: 20, right: 0)

        categoriesCollectionView.collectionViewLayout = layout
        categoriesCollectionView.delegate = self
        categoriesCollectionView.dataSource = self
        categoriesCollectionView.backgroundColor = .clear

        // Register cell
        categoriesCollectionView.register(
            UINib(nibName: "CategoryCollectionViewCell", bundle: nil),
            forCellWithReuseIdentifier: "CategoryCollectionViewCell"
        )
    }

    private func setupPresenter() {
        // Using mock data store for development
        // Change to RemoteMovieDataStore for production
        let dataStore = RemoteMovieDataStore()
        let repository = MovieRepository(dataStore: dataStore)
        let useCase = GetCategoriesUseCase(repository: repository)

        presenter = CategoriesPresenter(view: self, getCategoriesUseCase: useCase)
    }

    private func navigateToMovieDetail(_ movie: Movie) {
        let detailVC = MovieDetailViewController(nibName: "MovieDetailViewController", bundle: nil)
        detailVC.movie = movie
        navigationController?.pushViewController(detailVC, animated: true)
    }
}

// MARK: - CategoriesViewProtocol
extension CategoriesViewController: CategoriesViewProtocol {
    func displayCategories(_ categories: [Category]) {
        self.categories = categories
        categoriesCollectionView.reloadData()
    }

    func showLoading() {
        showLoadingIndicator()
    }

    func hideLoading() {
        hideLoadingIndicator()
    }

    func showError(_ message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UICollectionViewDelegate & DataSource
extension CategoriesViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categories.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "CategoryCollectionViewCell",
            for: indexPath
        ) as? CategoryCollectionViewCell else {
            return UICollectionViewCell()
        }

        let category = categories[indexPath.item]
        cell.configure(with: category)

        cell.onMovieSelected = { [weak self] movie in
            self?.navigateToMovieDetail(movie)
        }

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.bounds.width
        // Height = title (40) + table height (120 per row * number of movies, max 3)
        let category = categories[indexPath.item]
        let numberOfMovies = min(category.movies.count, 3)
        let height: CGFloat = 60 + (120 * CGFloat(numberOfMovies))

        return CGSize(width: width, height: height)
    }
}
