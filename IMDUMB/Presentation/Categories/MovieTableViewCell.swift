import UIKit

// MARK: - Movie Table View Cell
// Displays a single movie in the table
class MovieTableViewCell: UITableViewCell {

    // MARK: - IBOutlets
    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var overviewLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!

    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }

    private func setupUI() {
        backgroundColor = .clear
        contentView.backgroundColor = UIColor(white: 0.15, alpha: 1.0)
        contentView.layer.cornerRadius = 8
        contentView.layer.masksToBounds = true

        posterImageView.contentMode = .scaleAspectFill
        posterImageView.clipsToBounds = true
        posterImageView.layer.cornerRadius = 6
        posterImageView.backgroundColor = UIColor(white: 0.2, alpha: 1.0)

        titleLabel.font = UIFont.boldSystemFont(ofSize: 16)
        titleLabel.textColor = .white

        overviewLabel.font = UIFont.systemFont(ofSize: 13)
        overviewLabel.textColor = .lightGray
        overviewLabel.numberOfLines = 2

        ratingLabel.font = UIFont.systemFont(ofSize: 14)
        ratingLabel.textColor = .systemYellow
    }

    // MARK: - Configuration
    func configure(with movie: Movie) {
        titleLabel.text = movie.title
        overviewLabel.text = movie.overview
        ratingLabel.text = "⭐ \(String(format: "%.1f", movie.voteAverage))"

        // Load image
        if let url = movie.posterURL {
            loadImage(from: url)
        } else {
            posterImageView.image = nil
        }
    }

    private func loadImage(from url: URL) {
        URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
            guard let data = data, let image = UIImage(data: data) else { return }
            DispatchQueue.main.async {
                self?.posterImageView.image = image
            }
        }.resume()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        posterImageView.image = nil
        titleLabel.text = nil
        overviewLabel.text = nil
        ratingLabel.text = nil
    }
}
