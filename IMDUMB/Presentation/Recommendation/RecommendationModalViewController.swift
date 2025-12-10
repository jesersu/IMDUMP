import UIKit

// MARK: - Recommendation Modal View Controller
// Modal that displays movie details and allows user to add a comment
class RecommendationModalViewController: UIViewController {

    // MARK: - IBOutlets
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var movieDescriptionTextView: UITextView!
    @IBOutlet weak var commentTitleLabel: UILabel!
    @IBOutlet weak var commentTextView: UITextView!
    @IBOutlet weak var confirmButton: UIButton!
    @IBOutlet weak var contentHeightConstraint: NSLayoutConstraint!

    // MARK: - Properties
    var movie: Movie!

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        displayMovieInfo()
        setupKeyboardObservers()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    private func setupUI() {
        view.backgroundColor = UIColor(red: 0.12, green: 0.12, blue: 0.12, alpha: 1.0)

        titleLabel.font = UIFont.boldSystemFont(ofSize: 22)
        titleLabel.textColor = .white
        titleLabel.numberOfLines = 0

        commentTitleLabel.font = UIFont.boldSystemFont(ofSize: 18)
        commentTitleLabel.textColor = .white
        commentTitleLabel.text = "Tu comentario:"

        // Movie description setup
        movieDescriptionTextView.backgroundColor = UIColor(white: 0.15, alpha: 1.0)
        movieDescriptionTextView.textColor = .white
        movieDescriptionTextView.font = UIFont.systemFont(ofSize: 15)
        movieDescriptionTextView.isEditable = false
        movieDescriptionTextView.isScrollEnabled = false
        movieDescriptionTextView.layer.cornerRadius = 8
        movieDescriptionTextView.textContainerInset = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)

        // Comment text view setup
        commentTextView.backgroundColor = UIColor(white: 0.15, alpha: 1.0)
        commentTextView.textColor = .white
        commentTextView.font = UIFont.systemFont(ofSize: 15)
        commentTextView.layer.cornerRadius = 8
        commentTextView.layer.borderColor = UIColor.systemBlue.cgColor
        commentTextView.layer.borderWidth = 1.0
        commentTextView.textContainerInset = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        commentTextView.delegate = self

        // Button setup
        confirmButton.backgroundColor = .systemBlue
        confirmButton.setTitle("Confirmar Recomendación", for: .normal)
        confirmButton.setTitleColor(.white, for: .normal)
        confirmButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        confirmButton.layer.cornerRadius = 8
        confirmButton.addTarget(self, action: #selector(confirmTapped), for: .touchUpInside)
    }

    private func displayMovieInfo() {
        titleLabel.text = movie.title

        // Display HTML overview
        if let attributedString = movie.overview.htmlToAttributedString {
            let mutableAttributedString = NSMutableAttributedString(attributedString: attributedString)
            mutableAttributedString.addAttributes([
                .font: UIFont.systemFont(ofSize: 15),
                .foregroundColor: UIColor.white
            ], range: NSRange(location: 0, length: mutableAttributedString.length))
            movieDescriptionTextView.attributedText = mutableAttributedString
        } else {
            movieDescriptionTextView.text = movie.overview
        }

        // Update content height to fit text
        view.layoutIfNeeded()
    }

    private func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }

    @objc private func keyboardWillShow(notification: NSNotification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else {
            return
        }

        let keyboardHeight = keyboardFrame.height
        scrollView.contentInset.bottom = keyboardHeight
        scrollView.verticalScrollIndicatorInsets.bottom = keyboardHeight

        // Scroll to show the active text view
        if commentTextView.isFirstResponder {
            let rect = commentTextView.convert(commentTextView.bounds, to: scrollView)
            scrollView.scrollRectToVisible(rect, animated: true)
        }
    }

    @objc private func keyboardWillHide(notification: NSNotification) {
        scrollView.contentInset.bottom = 0
        scrollView.verticalScrollIndicatorInsets.bottom = 0
    }

    @objc private func confirmTapped() {
        view.endEditing(true)

        let comment = commentTextView.text.trimmingCharacters(in: .whitespacesAndNewlines)

        let alert = UIAlertController(
            title: "¡Éxito!",
            message: comment.isEmpty ?
                "Has recomendado \"\(movie.title)\"" :
                "Has recomendado \"\(movie.title)\" con tu comentario",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            self?.dismiss(animated: true)
        })

        present(alert, animated: true)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
}

// MARK: - UITextViewDelegate
extension RecommendationModalViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        // Dynamic height adjustment happens automatically with isScrollEnabled = false
    }
}
