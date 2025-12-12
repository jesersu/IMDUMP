import XCTest
import RxSwift
import RxBlocking
@testable import IMDUMB

// MARK: - Mock View for Presenter Tests
class MockCategoriesView: CategoriesViewProtocol {
    var displayCategoriesCalled = false
    var showLoadingCalled = false
    var hideLoadingCalled = false
    var showErrorCalled = false
    var showToastCalled = false
    var errorMessage: String?
    var toastMessage: String?
    var displayedCategories: [IMDUMB.Category]?

    func displayCategories(_ categories: [IMDUMB.Category]) {
        displayCategoriesCalled = true
        displayedCategories = categories
    }

    func showLoading() {
        showLoadingCalled = true
    }

    func hideLoading() {
        hideLoadingCalled = true
    }

    func showError(_ message: String) {
        showErrorCalled = true
        errorMessage = message
    }

    func showToast(_ message: String) {
        showToastCalled = true
        toastMessage = message
    }
}

// MARK: - Mock Use Case for Presenter Tests
class MockGetCategoriesUseCase: GetCategoriesUseCase {
    var shouldReturnError = false
    var mockCategories: [IMDUMB.Category] = []

    // Mock repository to satisfy parent initializer
    private class MockRepository: MovieRepositoryProtocol {
        var categories: [IMDUMB.Category] = []
        func getCategories() -> Single<[IMDUMB.Category]> {
            return Single.just(categories)
        }
        func getMovieDetails(movieId: Int) -> Single<Movie> {
            return Single.error(NSError(domain: "NotImplemented", code: 1, userInfo: nil))
        }
    }

    init() {
        super.init(repository: MockRepository())
    }

    override func execute() -> Single<[IMDUMB.Category]> {
        if shouldReturnError {
            return Single.error(NSError(domain: "UseCaseError", code: 1, userInfo: nil))
        } else {
            return Single.just(mockCategories)
        }
    }
}

// MARK: - CategoriesPresenter Tests
class CategoriesPresenterTests: XCTestCase {

    var sut: CategoriesPresenter!
    var mockView: MockCategoriesView!
    var mockUseCase: MockGetCategoriesUseCase!

    override func setUp() {
        super.setUp()
        mockView = MockCategoriesView()
        mockUseCase = MockGetCategoriesUseCase()
        sut = CategoriesPresenter(view: mockView, getCategoriesUseCase: mockUseCase)
    }

    override func tearDown() {
        sut = nil
        mockView = nil
        mockUseCase = nil
        super.tearDown()
    }

    // MARK: - Test View Did Load

    func testViewDidLoad_ShouldShowLoadingAndFetchCategories() {
        // Given
        let movie = Movie(
            id: 1,
            title: "Test Movie",
            overview: "Test",
            posterPath: nil,
            backdropPath: nil,
            voteAverage: 7.0,
            releaseDate: "2024-01-01",
            images: [],
            cast: []
        )
        let category = Category(id: "popular", name: "Popular", movies: [movie])
        mockUseCase.mockCategories = [category]

        // When
        sut.viewDidLoad()

        // Give RxSwift MainScheduler time to complete
        let expectation = self.expectation(description: "Categories loaded")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1.0)

        // Then
        XCTAssertTrue(mockView.showLoadingCalled, "Should show loading indicator")
        XCTAssertTrue(mockView.hideLoadingCalled, "Should hide loading indicator")
        XCTAssertTrue(mockView.displayCategoriesCalled, "Should display categories")
        XCTAssertEqual(mockView.displayedCategories?.count, 1)
        XCTAssertEqual(mockView.displayedCategories?.first?.name, "Popular")
    }

    func testViewDidLoad_WhenUseCaseReturnsError_ShouldShowError() {
        // Given
        mockUseCase.shouldReturnError = true

        // When
        sut.viewDidLoad()

        // Give RxSwift MainScheduler time to complete
        let expectation = self.expectation(description: "Error shown")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1.0)

        // Then
        XCTAssertTrue(mockView.showLoadingCalled, "Should show loading indicator")
        XCTAssertTrue(mockView.hideLoadingCalled, "Should hide loading indicator")
        XCTAssertTrue(mockView.showErrorCalled, "Should show error message")
        XCTAssertNotNil(mockView.errorMessage)
    }

    func testViewDidLoad_WhenUseCaseReturnsEmptyCategories_ShouldDisplayEmptyList() {
        // Given
        mockUseCase.mockCategories = []

        // When
        sut.viewDidLoad()

        // Give RxSwift MainScheduler time to complete
        let expectation = self.expectation(description: "Empty categories displayed")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1.0)

        // Then
        XCTAssertTrue(mockView.displayCategoriesCalled)
        XCTAssertEqual(mockView.displayedCategories?.count, 0)
        XCTAssertFalse(mockView.showErrorCalled, "Should not show error for empty list")
    }

    // MARK: - Test Multiple Categories

    func testViewDidLoad_WhenUseCaseReturnsMultipleCategories_ShouldDisplayAll() {
        // Given
        let movie1 = Movie(id: 1, title: "Movie 1", overview: "Test 1", posterPath: nil, backdropPath: nil, voteAverage: 7.0, releaseDate: "2024-01-01", images: [], cast: [])
        let movie2 = Movie(id: 2, title: "Movie 2", overview: "Test 2", posterPath: nil, backdropPath: nil, voteAverage: 8.0, releaseDate: "2024-01-02", images: [], cast: [])

        let category1 = Category(id: "popular", name: "Popular", movies: [movie1])
        let category2 = Category(id: "top_rated", name: "Top Rated", movies: [movie2])

        mockUseCase.mockCategories = [category1, category2]

        // When
        sut.viewDidLoad()

        // Give RxSwift MainScheduler time to complete
        let expectation = self.expectation(description: "Multiple categories displayed")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1.0)

        // Then
        XCTAssertTrue(mockView.displayCategoriesCalled)
        XCTAssertEqual(mockView.displayedCategories?.count, 2)
    }
}
