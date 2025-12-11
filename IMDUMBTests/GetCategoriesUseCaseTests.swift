import XCTest
@testable import IMDUMB

// MARK: - Mock Repository for Testing
class MockMovieRepository: MovieRepositoryProtocol {
    var shouldReturnError = false
    var mockCategories: [Category] = []

    func getCategories(completion: @escaping (Result<[Category], Error>) -> Void) {
        if shouldReturnError {
            completion(.failure(NSError(domain: "TestError", code: 1, userInfo: nil)))
        } else {
            completion(.success(mockCategories))
        }
    }

    func getMovieDetails(movieId: Int, completion: @escaping (Result<Movie, Error>) -> Void) {
        completion(.failure(NSError(domain: "NotImplemented", code: 1, userInfo: nil)))
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

    func testExecute_WhenRepositoryReturnsCategories_ShouldReturnSuccess() {
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

        let expectation = self.expectation(description: "Categories returned")

        // When
        sut.execute { result in
            // Then
            switch result {
            case .success(let categories):
                XCTAssertEqual(categories.count, 1)
                XCTAssertEqual(categories.first?.id, "popular")
                XCTAssertEqual(categories.first?.name, "Popular")
                XCTAssertEqual(categories.first?.movies.count, 1)
                XCTAssertEqual(categories.first?.movies.first?.title, "Test Movie")
                expectation.fulfill()
            case .failure:
                XCTFail("Expected success but got failure")
            }
        }

        waitForExpectations(timeout: 1.0)
    }

    func testExecute_WhenRepositoryReturnsEmptyArray_ShouldReturnEmptySuccess() {
        // Given
        mockRepository.mockCategories = []

        let expectation = self.expectation(description: "Empty categories returned")

        // When
        sut.execute { result in
            // Then
            switch result {
            case .success(let categories):
                XCTAssertTrue(categories.isEmpty)
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
        sut.execute { result in
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

    // MARK: - Test Multiple Categories

    func testExecute_WhenRepositoryReturnsMultipleCategories_ShouldReturnAllCategories() {
        // Given
        let movie1 = Movie(id: 1, title: "Movie 1", overview: "Overview 1", posterPath: nil, backdropPath: nil, voteAverage: 7.0, releaseDate: "2024-01-01", images: [], cast: [])
        let movie2 = Movie(id: 2, title: "Movie 2", overview: "Overview 2", posterPath: nil, backdropPath: nil, voteAverage: 8.0, releaseDate: "2024-01-02", images: [], cast: [])

        let category1 = Category(id: "popular", name: "Popular", movies: [movie1])
        let category2 = Category(id: "top_rated", name: "Top Rated", movies: [movie2])

        mockRepository.mockCategories = [category1, category2]

        let expectation = self.expectation(description: "Multiple categories returned")

        // When
        sut.execute { result in
            // Then
            switch result {
            case .success(let categories):
                XCTAssertEqual(categories.count, 2)
                XCTAssertEqual(categories[0].id, "popular")
                XCTAssertEqual(categories[1].id, "top_rated")
                expectation.fulfill()
            case .failure:
                XCTFail("Expected success but got failure")
            }
        }

        waitForExpectations(timeout: 1.0)
    }
}
