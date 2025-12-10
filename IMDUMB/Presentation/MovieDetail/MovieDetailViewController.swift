import UIKit

// MARK: - Movie Detail View Controller
class MovieDetailViewController: UIViewController {

    // MARK: - IBOutlets
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var carouselScrollView: UIScrollView!
    @IBOutlet weak var carouselPageControl: UIPageControl!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var overviewTextView: UITextView!
    @IBOutlet weak var actorsCollectionView: UICollectionView!
    @IBOutlet weak var recommendButton: UIButton!

    // MARK: - Properties
    var movie: Movie!
    var presenter: MovieDetailPresenterProtocol!

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupCarousel()
        setupActorsCollection()
        setupPresenter()
        presenter.viewDidLoad()
    }

    private func setupUI() {
        view.backgroundColor = UIColor(red: 0.12, green: 0.12, blue: 0.12, alpha: 1.0)
        title = "Movie Details"

        titleLabel.font = UIFont.boldSystemFont(ofSize: 24)
        titleLabel.textColor = .white
        titleLabel.numberOfLines = 0

        ratingLabel.font = UIFont.systemFont(ofSize: 18)
        ratingLabel.textColor = .systemYellow

        overviewTextView.backgroundColor = .clear
        overviewTextView.textColor = .white
        overviewTextView.font = UIFont.systemFont(ofSize: 16)
        overviewTextView.isEditable = false
        overviewTextView.isScrollEnabled = false

        recommendButton.backgroundColor = .systemBlue
        recommendButton.setTitle("Recomendar", for: .normal)
        recommendButton.setTitleColor(.white, for: .normal)
        recommendButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        recommendButton.layer.cornerRadius = 8
        recommendButton.addTarget(self, action: #selector(recommendTapped), for: .touchUpInside)
    }

    private func setupCarousel() {
        carouselScrollView.delegate = self
        carouselScrollView.isPagingEnabled = true
        carouselScrollView.showsHorizontalScrollIndicator = false

        carouselPageControl.currentPageIndicatorTintColor = .white
        carouselPageControl.pageIndicatorTintColor = .gray
    }

    private func setupActorsCollection() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 80, height: 120)
        layout.minimumLineSpacing = 10

        actorsCollectionView.collectionViewLayout = layout
        actorsCollectionView.delegate = self
        actorsCollectionView.dataSource = self
        actorsCollectionView.backgroundColor = .clear
        actorsCollectionView.showsHorizontalScrollIndicator = false

        actorsCollectionView.register(
            ActorCollectionViewCell.self,
            forCellWithReuseIdentifier: "ActorCell"
        )
    }

    private func setupPresenter() {
        presenter = MovieDetailPresenter(view: self, movie: movie)
    }

    private func loadCarouselImages() {
        let imagePaths = movie.images.isEmpty ?
            [movie.backdropPath].compactMap { $0 } :
            movie.images

        carouselPageControl.numberOfPages = imagePaths.count

        let imageWidth = carouselScrollView.bounds.width
        let imageHeight = carouselScrollView.bounds.height

        for (index, imagePath) in imagePaths.enumerated() {
            let imageView = UIImageView(frame: CGRect(
                x: CGFloat(index) * imageWidth,
                y: 0,
                width: imageWidth,
                height: imageHeight
            ))
            imageView.contentMode = .scaleAspectFill
            imageView.clipsToBounds = true
            imageView.backgroundColor = UIColor(white: 0.2, alpha: 1.0)

            let imageURL = URL(string: "https://image.tmdb.org/t/p/w780\(imagePath)")
            if let url = imageURL {
                loadImage(from: url, into: imageView)
            }

            carouselScrollView.addSubview(imageView)
        }

        carouselScrollView.contentSize = CGSize(
            width: imageWidth * CGFloat(imagePaths.count),
            height: imageHeight
        )
    }

    private func loadImage(from url: URL, into imageView: UIImageView) {
        URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data = data, let image = UIImage(data: data) else { return }
            DispatchQueue.main.async {
                imageView.image = image
            }
        }.resume()
    }

    @objc private func recommendTapped() {
        presenter.didTapRecommend()
    }
}

// MARK: - MovieDetailViewProtocol
extension MovieDetailViewController: MovieDetailViewProtocol {
    func displayMovieDetails() {
        titleLabel.text = movie.title
        ratingLabel.text = "⭐ \(String(format: "%.1f", movie.voteAverage))/10"

        // Display HTML overview
        if let attributedString = movie.overview.htmlToAttributedString {
            overviewTextView.attributedText = attributedString
        } else {
            overviewTextView.text = movie.overview
        }

        loadCarouselImages()
        actorsCollectionView.reloadData()
    }

    func showRecommendationModal() {
        let modalVC = RecommendationModalViewController(nibName: "RecommendationModalViewController", bundle: nil)
        modalVC.movie = movie
        modalVC.modalPresentationStyle = .pageSheet

        if let sheet = modalVC.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
            sheet.prefersGrabberVisible = true
        }

        present(modalVC, animated: true)
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

// MARK: - UIScrollViewDelegate
extension MovieDetailViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard scrollView == carouselScrollView else { return }
        let pageIndex = round(scrollView.contentOffset.x / scrollView.frame.width)
        carouselPageControl.currentPage = Int(pageIndex)
    }
}

// MARK: - UICollectionViewDelegate & DataSource
extension MovieDetailViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return movie.cast.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ActorCell", for: indexPath) as! ActorCollectionViewCell
        let actor = movie.cast[indexPath.item]
        cell.configure(with: actor)
        return cell
    }
}

// MARK: - Actor Collection View Cell
class ActorCollectionViewCell: UICollectionViewCell {
    private let nameLabel = UILabel()
    private let characterLabel = UILabel()
    private let profileImageView = UIImageView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    private func setupUI() {
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.clipsToBounds = true
        profileImageView.layer.cornerRadius = 6
        profileImageView.backgroundColor = UIColor(white: 0.2, alpha: 1.0)

        nameLabel.font = UIFont.boldSystemFont(ofSize: 12)
        nameLabel.textColor = .white
        nameLabel.textAlignment = .center
        nameLabel.numberOfLines = 2

        characterLabel.font = UIFont.systemFont(ofSize: 10)
        characterLabel.textColor = .lightGray
        characterLabel.textAlignment = .center
        characterLabel.numberOfLines = 2

        addSubview(profileImageView)
        addSubview(nameLabel)
        addSubview(characterLabel)

        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        characterLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            profileImageView.topAnchor.constraint(equalTo: topAnchor),
            profileImageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            profileImageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            profileImageView.heightAnchor.constraint(equalToConstant: 80),

            nameLabel.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 4),
            nameLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            nameLabel.trailingAnchor.constraint(equalTo: trailingAnchor),

            characterLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 2),
            characterLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            characterLabel.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }

    func configure(with actor: Actor) {
        nameLabel.text = actor.name
        characterLabel.text = actor.character

        if let url = actor.profileURL {
            URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
                guard let data = data, let image = UIImage(data: data) else { return }
                DispatchQueue.main.async {
                    self?.profileImageView.image = image
                }
            }.resume()
        }
    }
}
