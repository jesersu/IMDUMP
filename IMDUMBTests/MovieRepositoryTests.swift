import XCTest
import RxSwift
import RxBlocking
@testable import IMDUMB

// MARK: - Mock DataStore for Repository Tests
class MockMovieDataStoreForTests: MovieDataStoreProtocol {
    var shouldReturnError = false
    var mockMovieDTOs: [MovieDTO] = []
    var mockMovieDTO: MovieDTO?
    var mockActorDTOs: [ActorDTO] = []
    var mockImages: [String] = []

    func fetchMovies(endpoint: String) -> Single<[MovieDTO]> {
        if shouldReturnError {
            return Single.error(NSError(domain: "DataStoreError", code: 1, userInfo: nil))
        } else {
            return Single.just(mockMovieDTOs)
        }
    }

    func fetchMovieDetails(movieId: Int) -> Single<MovieDTO> {
        if shouldReturnError {
            return Single.error(NSError(domain: "DataStoreError", code: 1, userInfo: nil))
        } else if let dto = mockMovieDTO {
            return Single.just(dto)
        } else {
            return Single.error(NSError(domain: "NoMockData", code: 2, userInfo: nil))
        }
    }

    func fetchMovieCredits(movieId: Int) -> Single<[ActorDTO]> {
        if shouldReturnError {
            return Single.error(NSError(domain: "DataStoreError", code: 1, userInfo: nil))
        } else {
            return Single.just(mockActorDTOs)
        }
    }

    func fetchMovieImages(movieId: Int) -> Single<[String]> {
        if shouldReturnError {
            return Single.error(NSError(domain: "DataStoreError", code: 1, userInfo: nil))
        } else {
            return Single.just(mockImages)
        }
    }
}

// MARK: - MovieRepository Tests
class MovieRepositoryTests: XCTestCase {

    var sut: MovieRepository!
    var mockDataStore: MockMovieDataStoreForTests!
    var mockLocalDataStore: MockMovieDataStoreForTests!
    var mockRemoteDataStore: MockMovieDataStoreForTests!

    override func setUp() {
        super.setUp()
        mockDataStore = MockMovieDataStoreForTests()
        sut = MovieRepository(dataStore: mockDataStore)
    }

    override func tearDown() {
        sut = nil
        mockDataStore = nil
        mockLocalDataStore = nil
        mockRemoteDataStore = nil
        super.tearDown()
    }

    // MARK: - Test Get Categories

    func testGetCategories_WhenDataStoreReturnsMovies_ShouldMapToDomainModels() throws {
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

        // When
        let categories = try sut.getCategories().toBlocking().first()!

        // Then
        XCTAssertEqual(categories.count, 4) // popular, top_rated, upcoming, now_playing

        // Check first category
        let firstCategory = categories.first!
        XCTAssertEqual(firstCategory.movies.count, 1)
        XCTAssertEqual(firstCategory.movies.first?.title, "Test Movie")
        XCTAssertEqual(firstCategory.movies.first?.voteAverage, 8.5)
    }

    func testGetCategories_WhenDataStoreReturnsError_ShouldPropagateError() {
        // Given
        mockDataStore.shouldReturnError = true

        // When/Then
        XCTAssertThrowsError(try sut.getCategories().toBlocking().first())
    }

    // MARK: - Test Get Movie Details

    func testGetMovieDetails_WhenDataStoreReturnsDetails_ShouldMapToDomainModel() throws {
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

        // When
        let movie = try sut.getMovieDetails(movieId: 123).toBlocking().first()!

        // Then
        XCTAssertEqual(movie.id, 123)
        XCTAssertEqual(movie.title, "Detailed Movie")
        XCTAssertEqual(movie.voteAverage, 9.0)
        XCTAssertEqual(movie.images.count, 2)
        XCTAssertEqual(movie.cast.count, 1)
        XCTAssertEqual(movie.cast.first?.name, "Actor Name")
    }

    func testGetMovieDetails_WhenDataStoreReturnsError_ShouldPropagateError() {
        // Given
        mockDataStore.shouldReturnError = true

        // When/Then
        XCTAssertThrowsError(try sut.getMovieDetails(movieId: 999).toBlocking().first())
    }

    // MARK: - Test DTO to Domain Mapping

    func testGetMovieDetails_WhenDTOHasNilValues_ShouldHandleGracefully() throws {
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

        // When
        let movie = try sut.getMovieDetails(movieId: 456).toBlocking().first()!

        // Then
        XCTAssertNil(movie.posterPath)
        XCTAssertNil(movie.backdropPath)
        XCTAssertTrue(movie.images.isEmpty)
        XCTAssertTrue(movie.cast.isEmpty)
    }

    // MARK: - Test Cache-First Behavior

    func testGetCategories_WhenCacheHit_ShouldReturnCachedData() throws {
        // Given
        mockLocalDataStore = MockMovieDataStoreForTests()
        mockRemoteDataStore = MockMovieDataStoreForTests()

        let movieDTO = MovieDTO(id: 1, title: "Cached Movie", overview: "Test", posterPath: nil, backdropPath: nil, voteAverage: 7.0, releaseDate: "2024-01-01")
        mockLocalDataStore.mockMovieDTOs = [movieDTO]
        mockRemoteDataStore.mockMovieDTOs = []

        sut = MovieRepository(localDataStore: mockLocalDataStore, remoteDataStore: mockRemoteDataStore)

        // When
        let categories = try sut.getCategories().toBlocking().first()!

        // Then
        XCTAssertEqual(categories.count, 4)
        XCTAssertEqual(categories.first?.movies.first?.title, "Cached Movie")
    }

    func testGetCategories_WhenCacheMiss_ShouldFetchFromRemote() throws {
        // Given
        mockLocalDataStore = MockMovieDataStoreForTests()
        mockRemoteDataStore = MockMovieDataStoreForTests()

        mockLocalDataStore.shouldReturnError = true // Simulate cache miss
        let movieDTO = MovieDTO(id: 2, title: "Remote Movie", overview: "Test", posterPath: nil, backdropPath: nil, voteAverage: 8.0, releaseDate: "2024-01-01")
        mockRemoteDataStore.mockMovieDTOs = [movieDTO]

        sut = MovieRepository(localDataStore: mockLocalDataStore, remoteDataStore: mockRemoteDataStore)

        // When
        let categories = try sut.getCategories().toBlocking().first()!

        // Then
        XCTAssertEqual(categories.count, 4)
        XCTAssertEqual(categories.first?.movies.first?.title, "Remote Movie")
    }

    func testGetMovieDetails_WhenCacheHit_ShouldReturnCachedDetails() throws {
        // Given
        mockLocalDataStore = MockMovieDataStoreForTests()
        mockRemoteDataStore = MockMovieDataStoreForTests()

        let movieDTO = MovieDTO(id: 123, title: "Cached Detail", overview: "Test", posterPath: nil, backdropPath: nil, voteAverage: 9.0, releaseDate: "2024-01-01")
        mockLocalDataStore.mockMovieDTO = movieDTO
        mockLocalDataStore.mockActorDTOs = []
        mockLocalDataStore.mockImages = []

        sut = MovieRepository(localDataStore: mockLocalDataStore, remoteDataStore: mockRemoteDataStore)

        // When
        let movie = try sut.getMovieDetails(movieId: 123).toBlocking().first()!

        // Then
        XCTAssertEqual(movie.title, "Cached Detail")
    }

    func testGetMovieDetails_WhenCacheMiss_ShouldFetchFromRemote() throws {
        // Given
        mockLocalDataStore = MockMovieDataStoreForTests()
        mockRemoteDataStore = MockMovieDataStoreForTests()

        mockLocalDataStore.shouldReturnError = true // Simulate cache miss

        let movieDTO = MovieDTO(id: 456, title: "Remote Detail", overview: "Test", posterPath: nil, backdropPath: nil, voteAverage: 8.5, releaseDate: "2024-01-01")
        mockRemoteDataStore.mockMovieDTO = movieDTO
        mockRemoteDataStore.mockActorDTOs = []
        mockRemoteDataStore.mockImages = []

        sut = MovieRepository(localDataStore: mockLocalDataStore, remoteDataStore: mockRemoteDataStore)

        // When
        let movie = try sut.getMovieDetails(movieId: 456).toBlocking().first()!

        // Then
        XCTAssertEqual(movie.title, "Remote Detail")
    }
}
