import XCTest
import RxSwift
import RxBlocking
@testable import IMDUMB

// MARK: - Mock Repository for Movie Details
class MockMovieDetailsRepository: MovieRepositoryProtocol {
    var shouldReturnError = false
    var mockMovie: Movie?

    func getCategories() -> Single<[IMDUMB.Category]> {
        return Single.error(NSError(domain: "NotImplemented", code: 1, userInfo: nil))
    }

    func getMovieDetails(movieId: Int) -> Single<Movie> {
        if shouldReturnError {
            return Single.error(NSError(domain: "TestError", code: 1, userInfo: nil))
        } else if let movie = mockMovie {
            return Single.just(movie)
        } else {
            return Single.error(NSError(domain: "NoMockData", code: 2, userInfo: nil))
        }
    }
}

// MARK: - GetMovieDetailsUseCase Tests
class GetMovieDetailsUseCaseTests: XCTestCase {

    var sut: GetMovieDetailsUseCase!
    var mockRepository: MockMovieDetailsRepository!

    override func setUp() {
        super.setUp()
        mockRepository = MockMovieDetailsRepository()
        sut = GetMovieDetailsUseCase(repository: mockRepository)
    }

    override func tearDown() {
        sut = nil
        mockRepository = nil
        super.tearDown()
    }

    // MARK: - Test Success Cases

    func testExecute_WhenRepositoryReturnsMovieDetails_ShouldReturnSuccess() throws {
        // Given
        let expectedActor = Actor(id: 1, name: "John Doe", character: "Hero", profilePath: "/actor.jpg")
        let expectedMovie = Movie(
            id: 123,
            title: "Test Movie",
            overview: "A great movie",
            posterPath: "/poster.jpg",
            backdropPath: "/backdrop.jpg",
            voteAverage: 8.5,
            releaseDate: "2024-01-01",
            images: ["/image1.jpg", "/image2.jpg"],
            cast: [expectedActor]
        )
        mockRepository.mockMovie = expectedMovie

        // When
        let movie = try sut.execute(movieId: 123).toBlocking().first()!

        // Then
        XCTAssertEqual(movie.id, 123)
        XCTAssertEqual(movie.title, "Test Movie")
        XCTAssertEqual(movie.overview, "A great movie")
        XCTAssertEqual(movie.voteAverage, 8.5)
        XCTAssertEqual(movie.images.count, 2)
        XCTAssertEqual(movie.cast.count, 1)
        XCTAssertEqual(movie.cast.first?.name, "John Doe")
    }

    func testExecute_WhenMovieHasNoCast_ShouldReturnMovieWithEmptyCast() throws {
        // Given
        let expectedMovie = Movie(
            id: 456,
            title: "No Cast Movie",
            overview: "No actors",
            posterPath: nil,
            backdropPath: nil,
            voteAverage: 5.0,
            releaseDate: "2024-01-01",
            images: [],
            cast: []
        )
        mockRepository.mockMovie = expectedMovie

        // When
        let movie = try sut.execute(movieId: 456).toBlocking().first()!

        // Then
        XCTAssertTrue(movie.cast.isEmpty)
    }

    // MARK: - Test Failure Cases

    func testExecute_WhenRepositoryReturnsError_ShouldPropagateError() {
        // Given
        mockRepository.shouldReturnError = true

        // When/Then
        XCTAssertThrowsError(try sut.execute(movieId: 999).toBlocking().first()) { error in
            XCTAssertNotNil(error)
        }
    }

    // MARK: - Test Data Integrity

    func testExecute_WhenMovieHasMultipleImages_ShouldPreserveOrder() throws {
        // Given
        let images = ["/img1.jpg", "/img2.jpg", "/img3.jpg"]
        let expectedMovie = Movie(
            id: 789,
            title: "Multi Image Movie",
            overview: "Has multiple images",
            posterPath: nil,
            backdropPath: nil,
            voteAverage: 7.0,
            releaseDate: "2024-01-01",
            images: images,
            cast: []
        )
        mockRepository.mockMovie = expectedMovie

        // When
        let movie = try sut.execute(movieId: 789).toBlocking().first()!

        // Then
        XCTAssertEqual(movie.images.count, 3)
        XCTAssertEqual(movie.images[0], "/img1.jpg")
        XCTAssertEqual(movie.images[1], "/img2.jpg")
        XCTAssertEqual(movie.images[2], "/img3.jpg")
    }
}
