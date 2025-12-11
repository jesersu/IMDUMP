import XCTest
@testable import IMDUMB

// MARK: - Mock Repository for Movie Details
class MockMovieDetailsRepository: MovieRepositoryProtocol {
    var shouldReturnError = false
    var mockMovie: Movie?

    func getCategories(completion: @escaping (Result<[Category], Error>) -> Void) {
        completion(.failure(NSError(domain: "NotImplemented", code: 1, userInfo: nil)))
    }

    func getMovieDetails(movieId: Int, completion: @escaping (Result<Movie, Error>) -> Void) {
        if shouldReturnError {
            completion(.failure(NSError(domain: "TestError", code: 1, userInfo: nil)))
        } else if let movie = mockMovie {
            completion(.success(movie))
        } else {
            completion(.failure(NSError(domain: "NoMockData", code: 2, userInfo: nil)))
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

    func testExecute_WhenRepositoryReturnsMovieDetails_ShouldReturnSuccess() {
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

        let expectation = self.expectation(description: "Movie details returned")

        // When
        sut.execute(movieId: 123) { result in
            // Then
            switch result {
            case .success(let movie):
                XCTAssertEqual(movie.id, 123)
                XCTAssertEqual(movie.title, "Test Movie")
                XCTAssertEqual(movie.overview, "A great movie")
                XCTAssertEqual(movie.voteAverage, 8.5)
                XCTAssertEqual(movie.images.count, 2)
                XCTAssertEqual(movie.cast.count, 1)
                XCTAssertEqual(movie.cast.first?.name, "John Doe")
                expectation.fulfill()
            case .failure:
                XCTFail("Expected success but got failure")
            }
        }

        waitForExpectations(timeout: 1.0)
    }

    func testExecute_WhenMovieHasNoCast_ShouldReturnMovieWithEmptyCast() {
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

        let expectation = self.expectation(description: "Movie with no cast returned")

        // When
        sut.execute(movieId: 456) { result in
            // Then
            switch result {
            case .success(let movie):
                XCTAssertTrue(movie.cast.isEmpty)
                expectation.fulfill()
            case .failure:
                XCTFail("Expected success but got failure")
            }
        }

        waitForExpectations(timeout: 1.0)
    }

    // MARK: - Test Failure Cases

    func testExecute_WhenRepositoryReturnsError_ShouldReturnFailure() {
        // Given
        mockRepository.shouldReturnError = true

        let expectation = self.expectation(description: "Error returned")

        // When
        sut.execute(movieId: 999) { result in
            // Then
            switch result {
            case .success:
                XCTFail("Expected failure but got success")
            case .failure(let error):
                XCTAssertNotNil(error)
                expectation.fulfill()
            }
        }

        waitForExpectations(timeout: 1.0)
    }

    // MARK: - Test Data Integrity

    func testExecute_WhenMovieHasMultipleImages_ShouldPreserveOrder() {
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

        let expectation = self.expectation(description: "Movie with ordered images returned")

        // When
        sut.execute(movieId: 789) { result in
            // Then
            switch result {
            case .success(let movie):
                XCTAssertEqual(movie.images.count, 3)
                XCTAssertEqual(movie.images[0], "/img1.jpg")
                XCTAssertEqual(movie.images[1], "/img2.jpg")
                XCTAssertEqual(movie.images[2], "/img3.jpg")
                expectation.fulfill()
            case .failure:
                XCTFail("Expected success but got failure")
            }
        }

        waitForExpectations(timeout: 1.0)
    }
}
