import XCTest
@testable import IMDUMB

// MARK: - Mock DataStore for Repository Tests
class MockMovieDataStoreForTests: MovieDataStoreProtocol {
    var shouldReturnError = false
    var mockMovieDTOs: [MovieDTO] = []
    var mockMovieDetailDTO: MovieDetailDTO?

    func fetchMovies(category: String, completion: @escaping (Result<[MovieDTO], Error>) -> Void) {
        if shouldReturnError {
            completion(.failure(NSError(domain: "DataStoreError", code: 1, userInfo: nil)))
        } else {
            completion(.success(mockMovieDTOs))
        }
    }

    func fetchMovieDetails(movieId: Int, completion: @escaping (Result<MovieDetailDTO, Error>) -> Void) {
        if shouldReturnError {
            completion(.failure(NSError(domain: "DataStoreError", code: 1, userInfo: nil)))
        } else if let dto = mockMovieDetailDTO {
            completion(.success(dto))
        } else {
            completion(.failure(NSError(domain: "NoMockData", code: 2, userInfo: nil)))
        }
    }
}

// MARK: - MovieRepository Tests
class MovieRepositoryTests: XCTestCase {

    var sut: MovieRepository!
    var mockDataStore: MockMovieDataStoreForTests!

    override func setUp() {
        super.setUp()
        mockDataStore = MockMovieDataStoreForTests()
        sut = MovieRepository(dataStore: mockDataStore)
    }

    override func tearDown() {
        sut = nil
        mockDataStore = nil
        super.tearDown()
    }

    // MARK: - Test Get Categories

    func testGetCategories_WhenDataStoreReturnsMovies_ShouldMapToDomainModels() {
        // Given
        let movieDTO = MovieDTO(
            id: 1,
            title: "Test Movie",
            overview: "Test Overview",
            posterPath: "/poster.jpg",
            backdropPath: "/backdrop.jpg",
            voteAverage: 8.5,
            releaseDate: "2024-01-01"
        )
        mockDataStore.mockMovieDTOs = [movieDTO]

        let expectation = self.expectation(description: "Categories mapped")

        // When
        sut.getCategories { result in
            // Then
            switch result {
            case .success(let categories):
                XCTAssertEqual(categories.count, 4) // popular, top_rated, upcoming, now_playing

                // Check first category
                let firstCategory = categories.first!
                XCTAssertEqual(firstCategory.movies.count, 1)
                XCTAssertEqual(firstCategory.movies.first?.title, "Test Movie")
                XCTAssertEqual(firstCategory.movies.first?.voteAverage, 8.5)

                expectation.fulfill()
            case .failure:
                XCTFail("Expected success but got failure")
            }
        }

        waitForExpectations(timeout: 2.0)
    }

    func testGetCategories_WhenDataStoreReturnsError_ShouldPropagateError() {
        // Given
        mockDataStore.shouldReturnError = true

        let expectation = self.expectation(description: "Error propagated")

        // When
        sut.getCategories { result in
            // Then
            switch result {
            case .success:
                XCTFail("Expected failure but got success")
            case .failure(let error):
                XCTAssertNotNil(error)
                expectation.fulfill()
            }
        }

        waitForExpectations(timeout: 2.0)
    }

    // MARK: - Test Get Movie Details

    func testGetMovieDetails_WhenDataStoreReturnsDetails_ShouldMapToDomainModel() {
        // Given
        let castDTO = CastDTO(id: 1, name: "Actor Name", character: "Character", profilePath: "/actor.jpg")
        let imageDTO = ImageDTO(filePath: "/image.jpg")

        let detailDTO = MovieDetailDTO(
            id: 123,
            title: "Detailed Movie",
            overview: "Detailed Overview",
            posterPath: "/poster.jpg",
            backdropPath: "/backdrop.jpg",
            voteAverage: 9.0,
            releaseDate: "2024-01-01",
            images: ImagesDTO(backdrops: [imageDTO]),
            credits: CreditsDTO(cast: [castDTO])
        )
        mockDataStore.mockMovieDetailDTO = detailDTO

        let expectation = self.expectation(description: "Movie details mapped")

        // When
        sut.getMovieDetails(movieId: 123) { result in
            // Then
            switch result {
            case .success(let movie):
                XCTAssertEqual(movie.id, 123)
                XCTAssertEqual(movie.title, "Detailed Movie")
                XCTAssertEqual(movie.voteAverage, 9.0)
                XCTAssertEqual(movie.images.count, 1)
                XCTAssertEqual(movie.cast.count, 1)
                XCTAssertEqual(movie.cast.first?.name, "Actor Name")
                expectation.fulfill()
            case .failure:
                XCTFail("Expected success but got failure")
            }
        }

        waitForExpectations(timeout: 1.0)
    }

    func testGetMovieDetails_WhenDataStoreReturnsError_ShouldPropagateError() {
        // Given
        mockDataStore.shouldReturnError = true

        let expectation = self.expectation(description: "Error propagated")

        // When
        sut.getMovieDetails(movieId: 999) { result in
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

    // MARK: - Test DTO to Domain Mapping

    func testGetMovieDetails_WhenDTOHasNilValues_ShouldHandleGracefully() {
        // Given
        let detailDTO = MovieDetailDTO(
            id: 456,
            title: "Minimal Movie",
            overview: "Minimal data",
            posterPath: nil,
            backdropPath: nil,
            voteAverage: 5.0,
            releaseDate: "2024-01-01",
            images: ImagesDTO(backdrops: []),
            credits: CreditsDTO(cast: [])
        )
        mockDataStore.mockMovieDetailDTO = detailDTO

        let expectation = self.expectation(description: "Minimal movie mapped")

        // When
        sut.getMovieDetails(movieId: 456) { result in
            // Then
            switch result {
            case .success(let movie):
                XCTAssertNil(movie.posterPath)
                XCTAssertNil(movie.backdropPath)
                XCTAssertTrue(movie.images.isEmpty)
                XCTAssertTrue(movie.cast.isEmpty)
                expectation.fulfill()
            case .failure:
                XCTFail("Expected success but got failure")
            }
        }

        waitForExpectations(timeout: 1.0)
    }
}
