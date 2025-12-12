import XCTest
import RxSwift
import RxBlocking
@testable import IMDUMB

// MARK: - Mock Repository for Testing
class MockMovieRepository: MovieRepositoryProtocol {
    var shouldReturnError = false
    var mockCategories: [IMDUMB.Category] = []

    func getCategories() -> Single<[IMDUMB.Category]> {
        if shouldReturnError {
            return Single.error(NSError(domain: "TestError", code: 1, userInfo: nil))
        } else {
            return Single.just(mockCategories)
        }
    }

    func getMovieDetails(movieId: Int) -> Single<Movie> {
        return Single.error(NSError(domain: "NotImplemented", code: 1, userInfo: nil))
    }
}

// MARK: - GetCategoriesUseCase Tests
class GetCategoriesUseCaseTests: XCTestCase {

    var sut: GetCategoriesUseCase!
    var mockRepository: MockMovieRepository!

    override func setUp() {
        super.setUp()
        mockRepository = MockMovieRepository()
        sut = GetCategoriesUseCase(repository: mockRepository)
    }

    override func tearDown() {
        sut = nil
        mockRepository = nil
        super.tearDown()
    }

    // MARK: - Test Success Cases

    func testExecute_WhenRepositoryReturnsCategories_ShouldReturnSuccess() throws {
        // Given
        let expectedMovie = Movie(
            id: 1,
            title: "Test Movie",
            overview: "Test Overview",
            posterPath: "/test.jpg",
            backdropPath: "/backdrop.jpg",
            voteAverage: 8.5,
            releaseDate: "2024-01-01",
            images: [],
            cast: []
        )
        let expectedCategory = Category(id: "popular", name: "Popular", movies: [expectedMovie])
        mockRepository.mockCategories = [expectedCategory]

        // When
        let categories = try sut.execute().toBlocking().first()!

        // Then
        XCTAssertEqual(categories.count, 1)
        XCTAssertEqual(categories.first?.id, "popular")
        XCTAssertEqual(categories.first?.name, "Popular")
        XCTAssertEqual(categories.first?.movies.count, 1)
        XCTAssertEqual(categories.first?.movies.first?.title, "Test Movie")
    }

    func testExecute_WhenRepositoryReturnsEmptyArray_ShouldFilterEmptyCategories() throws {
        // Given - Mix of empty and non-empty categories
        let movie = Movie(id: 1, title: "Movie", overview: "Test", posterPath: nil, backdropPath: nil, voteAverage: 7.0, releaseDate: "2024-01-01", images: [], cast: [])
        mockRepository.mockCategories = [
            Category(id: "popular", name: "Popular", movies: [movie]),
            Category(id: "empty", name: "Empty", movies: [])
        ]

        // When
        let categories = try sut.execute().toBlocking().first()!

        // Then - Only non-empty categories returned
        XCTAssertEqual(categories.count, 1)
        XCTAssertEqual(categories.first?.id, "popular")
    }

    // MARK: - Test Failure Cases

    func testExecute_WhenRepositoryReturnsError_ShouldPropagateError() {
        // Given
        mockRepository.shouldReturnError = true

        // When/Then
        XCTAssertThrowsError(try sut.execute().toBlocking().first()) { error in
            XCTAssertNotNil(error)
        }
    }

    // MARK: - Test Multiple Categories

    func testExecute_WhenRepositoryReturnsMultipleCategories_ShouldReturnAllCategories() throws {
        // Given
        let movie1 = Movie(id: 1, title: "Movie 1", overview: "Overview 1", posterPath: nil, backdropPath: nil, voteAverage: 7.0, releaseDate: "2024-01-01", images: [], cast: [])
        let movie2 = Movie(id: 2, title: "Movie 2", overview: "Overview 2", posterPath: nil, backdropPath: nil, voteAverage: 8.0, releaseDate: "2024-01-02", images: [], cast: [])

        let category1 = Category(id: "popular", name: "Popular", movies: [movie1])
        let category2 = Category(id: "top_rated", name: "Top Rated", movies: [movie2])

        mockRepository.mockCategories = [category1, category2]

        // When
        let categories = try sut.execute().toBlocking().first()!

        // Then
        XCTAssertEqual(categories.count, 2)
        XCTAssertEqual(categories[0].id, "popular")
        XCTAssertEqual(categories[1].id, "top_rated")
    }
}
