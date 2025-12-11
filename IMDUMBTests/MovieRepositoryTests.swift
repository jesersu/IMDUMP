import XCTest
@testable import IMDUMB

// MARK: - Mock DataStore for Repository Tests
class MockMovieDataStoreForTests: MovieDataStoreProtocol {
    var shouldReturnError = false
    var mockMovieDTOs: [MovieDTO] = []
    var mockMovieDTO: MovieDTO?
    var mockActorDTOs: [ActorDTO] = []
    var mockImages: [String] = []

    func fetchMovies(endpoint: String, completion: @escaping (Result<[MovieDTO], Error>) -> Void) {
        if shouldReturnError {
            completion(.failure(NSError(domain: "DataStoreError", code: 1, userInfo: nil)))
        } else {
            completion(.success(mockMovieDTOs))
        }
    }

    func fetchMovieDetails(movieId: Int, completion: @escaping (Result<MovieDTO, Error>) -> Void) {
        if shouldReturnError {
            completion(.failure(NSError(domain: "DataStoreError", code: 1, userInfo: nil)))
        } else if let dto = mockMovieDTO {
            completion(.success(dto))
        } else {
            completion(.failure(NSError(domain: "NoMockData", code: 2, userInfo: nil)))
        }
    }

    func fetchMovieCredits(movieId: Int, completion: @escaping (Result<[ActorDTO], Error>) -> Void) {
        if shouldReturnError {
            completion(.failure(NSError(domain: "DataStoreError", code: 1, userInfo: nil)))
        } else {
            completion(.success(mockActorDTOs))
        }
    }

    func fetchMovieImages(movieId: Int, completion: @escaping (Result<[String], Error>) -> Void) {
        if shouldReturnError {
            completion(.failure(NSError(domain: "DataStoreError", code: 1, userInfo: nil)))
        } else {
            completion(.success(mockImages))
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
        let movieDTO = MovieDTO(
            id: 123,
            title: "Detailed Movie",
            overview: "Detailed Overview",
            posterPath: "/poster.jpg",
            backdropPath: "/backdrop.jpg",
            voteAverage: 9.0,
            releaseDate: "2024-01-01"
        )
        let actorDTO = ActorDTO(
            id: 1,
            name: "Actor Name",
            character: "Character",
            profilePath: "/actor.jpg"
        )
        mockDataStore.mockMovieDTO = movieDTO
        mockDataStore.mockActorDTOs = [actorDTO]
        mockDataStore.mockImages = ["/image1.jpg", "/image2.jpg"]

        let expectation = self.expectation(description: "Movie details mapped")

        // When
        sut.getMovieDetails(movieId: 123) { result in
            // Then
            switch result {
            case .success(let movie):
                XCTAssertEqual(movie.id, 123)
                XCTAssertEqual(movie.title, "Detailed Movie")
                XCTAssertEqual(movie.voteAverage, 9.0)
                XCTAssertEqual(movie.images.count, 2)
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
                XCTFail("Expected failure but got failure")
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
        let movieDTO = MovieDTO(
            id: 456,
            title: "Minimal Movie",
            overview: "Minimal data",
            posterPath: nil,
            backdropPath: nil,
            voteAverage: 5.0,
            releaseDate: nil
        )
        mockDataStore.mockMovieDTO = movieDTO
        mockDataStore.mockActorDTOs = []
        mockDataStore.mockImages = []

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
