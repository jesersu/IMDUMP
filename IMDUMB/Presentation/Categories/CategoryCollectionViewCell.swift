import UIKit

// MARK: - Category Collection View Cell
// This cell contains a UITableView to display movies
class CategoryCollectionViewCell: UICollectionViewCell {

    // MARK: - IBOutlets
    @IBOutlet weak var categoryTitleLabel: UILabel!
    @IBOutlet weak var moviesTableView: UITableView!

    // MARK: - Properties
    private var movies: [Movie] = []
    var onMovieSelected: ((Movie) -> Void)?

    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        setupTableView()
        setupUI()
    }

    private func setupUI() {
        backgroundColor = .clear
        categoryTitleLabel.font = UIFont.boldSystemFont(ofSize: 22)
        categoryTitleLabel.textColor = .white
    }

    private func setupTableView() {
        moviesTableView.delegate = self
        moviesTableView.dataSource = self
        moviesTableView.backgroundColor = .clear
        moviesTableView.separatorStyle = .none
        moviesTableView.showsVerticalScrollIndicator = false

        // Register cell
        moviesTableView.register(
            UINib(nibName: "MovieTableViewCell", bundle: nil),
            forCellReuseIdentifier: "MovieTableViewCell"
        )
    }

    // MARK: - Configuration
    func configure(with category: Category) {
        categoryTitleLabel.text = category.name
        self.movies = category.movies
        moviesTableView.reloadData()
    }
}

// MARK: - UITableViewDelegate & DataSource
extension CategoryCollectionViewCell: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movies.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "MovieTableViewCell",
            for: indexPath
        ) as? MovieTableViewCell else {
            return UITableViewCell()
        }

        let movie = movies[indexPath.row]
        cell.configure(with: movie)
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let movie = movies[indexPath.row]
        onMovieSelected?(movie)
    }
}
