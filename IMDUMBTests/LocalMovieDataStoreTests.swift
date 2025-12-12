import XCTest
import CoreData
@testable import IMDUMB

class LocalMovieDataStoreTests: XCTestCase {

    var sut: LocalMovieDataStore!
    var cacheService: CoreDataCacheService!
    var testContext: NSManagedObjectContext!

    override func setUp() {
        super.setUp()
        testContext = TestCoreDataStack.testContainer.viewContext
        cacheService = CoreDataCacheService(context: testContext)
        sut = LocalMovieDataStore(cacheService: cacheService)
        TestCoreDataStack.reset()
    }

    override func tearDown() {
        sut = nil
        cacheService = nil
        testContext = nil
        TestCoreDataStack.reset()
        super.tearDown()
    }

    // MARK: - Test Fetch Movies

    func testFetchMovies_WhenCacheHit_ShouldReturnMovies() throws {
        // Given
        let movies = [MovieDTO(id: 1, title: "Test", overview: "Test", posterPath: nil, backdropPath: nil, voteAverage: 7.0, releaseDate: "2024-01-01")]
        let cachedMovies = CachedMoviesDTO(movies: movies, timestamp: Date())
        try cacheService.save(cachedMovies, forKey: "cache.category.popular")

        let expectation = self.expectation(description: "Movies fetched")

        // When
        sut.fetchMovies(endpoint: "/movie/popular") { result in
            // Then
            switch result {
            case .success(let fetchedMovies):
                XCTAssertEqual(fetchedMovies.count, 1)
                XCTAssertEqual(fetchedMovies.first?.id, 1)
                XCTAssertEqual(fetchedMovies.first?.title, "Test")
                expectation.fulfill()
            case .failure:
                XCTFail("Expected success but got failure")
            }
        }

        waitForExpectations(timeout: 1.0)
    }

    func testFetchMovies_WhenCacheMiss_ShouldReturnError() {
        // Given - no data saved to cache

        let expectation = self.expectation(description: "Error returned")

        // When
        sut.fetchMovies(endpoint: "/movie/popular") { result in
            // Then
            switch result {
            case .success:
                XCTFail("Expected failure but got success")
            case .failure(let error):
                XCTAssertTrue(error is CacheError)
                expectation.fulfill()
            }
        }

        waitForExpectations(timeout: 1.0)
    }

    func testFetchMovies_WhenCacheExpired_ShouldReturnExpiredError() throws {
        // Given - save data with old timestamp
        let oldTimestamp = Date().addingTimeInterval(-25 * 60 * 60) // 25 hours ago
        let movies = [MovieDTO(id: 1, title: "Test", overview: "Test", posterPath: nil, backdropPath: nil, voteAverage: 7.0, releaseDate: "2024-01-01")]
        let cachedMovies = CachedMoviesDTO(movies: movies, timestamp: oldTimestamp)
        try cacheService.save(cachedMovies, forKey: "cache.category.top_rated")

        let expectation = self.expectation(description: "Expired error returned")

        // When
        sut.fetchMovies(endpoint: "/movie/top_rated") { result in
            // Then
            switch result {
            case .success:
                XCTFail("Expected failure but got success")
            case .failure(let error):
                XCTAssertEqual(error as? CacheError, CacheError.expired)
                expectation.fulfill()
            }
        }

        waitForExpectations(timeout: 1.0)
    }

    // MARK: - Test Fetch Movie Details

    func testFetchMovieDetails_WhenCacheHit_ShouldReturnMovieDTO() throws {
        // Given
        let movie = MovieDTO(id: 123, title: "Test Movie", overview: "Test", posterPath: nil, backdropPath: nil, voteAverage: 8.0, releaseDate: "2024-01-01")
        let cachedDetails = CachedMovieDetailsDTO(movie: movie, actors: [], images: [], timestamp: Date())
        try cacheService.save(cachedDetails, forKey: "cache.movie.123")

        let expectation = self.expectation(description: "Movie details fetched")

        // When
        sut.fetchMovieDetails(movieId: 123) { result in
            // Then
            switch result {
            case .success(let fetchedMovie):
                XCTAssertEqual(fetchedMovie.id, 123)
                XCTAssertEqual(fetchedMovie.title, "Test Movie")
                expectation.fulfill()
            case .failure:
                XCTFail("Expected success but got failure")
            }
        }

        waitForExpectations(timeout: 1.0)
    }

    func testFetchMovieDetails_WhenCacheExpired_ShouldReturnError() throws {
        // Given - save data with old timestamp
        let oldTimestamp = Date().addingTimeInterval(-25 * 60 * 60)
        let movie = MovieDTO(id: 123, title: "Test Movie", overview: "Test", posterPath: nil, backdropPath: nil, voteAverage: 8.0, releaseDate: "2024-01-01")
        let cachedDetails = CachedMovieDetailsDTO(movie: movie, actors: [], images: [], timestamp: oldTimestamp)
        try cacheService.save(cachedDetails, forKey: "cache.movie.123")

        let expectation = self.expectation(description: "Error returned")

        // When
        sut.fetchMovieDetails(movieId: 123) { result in
            // Then
            switch result {
            case .success:
                XCTFail("Expected failure but got success")
            case .failure(let error):
                XCTAssertEqual(error as? CacheError, CacheError.expired)
                expectation.fulfill()
            }
        }

        waitForExpectations(timeout: 1.0)
    }

    // MARK: - Test Fetch Movie Credits

    func testFetchMovieCredits_WhenCacheHit_ShouldReturnActors() throws {
        // Given
        let movie = MovieDTO(id: 123, title: "Test", overview: "Test", posterPath: nil, backdropPath: nil, voteAverage: 7.0, releaseDate: "2024-01-01")
        let actors = [ActorDTO(id: 1, name: "John Doe", character: "Hero", profilePath: nil)]
        let cachedDetails = CachedMovieDetailsDTO(movie: movie, actors: actors, images: [], timestamp: Date())
        try cacheService.save(cachedDetails, forKey: "cache.movie.123")

        let expectation = self.expectation(description: "Credits fetched")

        // When
        sut.fetchMovieCredits(movieId: 123) { result in
            // Then
            switch result {
            case .success(let fetchedActors):
                XCTAssertEqual(fetchedActors.count, 1)
                XCTAssertEqual(fetchedActors.first?.name, "John Doe")
                expectation.fulfill()
            case .failure:
                XCTFail("Expected success but got failure")
            }
        }

        waitForExpectations(timeout: 1.0)
    }

    // MARK: - Test Fetch Movie Images

    func testFetchMovieImages_WhenCacheHit_ShouldReturnImages() throws {
        // Given
        let movie = MovieDTO(id: 123, title: "Test", overview: "Test", posterPath: nil, backdropPath: nil, voteAverage: 7.0, releaseDate: "2024-01-01")
        let images = ["/image1.jpg", "/image2.jpg"]
        let cachedDetails = CachedMovieDetailsDTO(movie: movie, actors: [], images: images, timestamp: Date())
        try cacheService.save(cachedDetails, forKey: "cache.movie.123")

        let expectation = self.expectation(description: "Images fetched")

        // When
        sut.fetchMovieImages(movieId: 123) { result in
            // Then
            switch result {
            case .success(let fetchedImages):
                XCTAssertEqual(fetchedImages.count, 2)
                XCTAssertEqual(fetchedImages.first, "/image1.jpg")
                expectation.fulfill()
            case .failure:
                XCTFail("Expected success but got failure")
            }
        }

        waitForExpectations(timeout: 1.0)
    }

    // MARK: - Test Save Operations

    func testSaveMovies_ShouldSaveToCache() throws {
        // Given
        let movies = [MovieDTO(id: 1, title: "Test", overview: "Test", posterPath: nil, backdropPath: nil, voteAverage: 7.0, releaseDate: "2024-01-01")]

        // When
        XCTAssertNoThrow(try sut.saveMovies(movies, forEndpoint: "/movie/popular"))

        // Then - verify data was saved by trying to load it
        let loaded: CachedMoviesDTO? = cacheService.load(forKey: "cache.category.popular")
        XCTAssertNotNil(loaded)
        XCTAssertEqual(loaded?.movies.count, 1)
        XCTAssertEqual(loaded?.movies.first?.id, 1)
    }

    func testSaveMovieDetails_ShouldSaveToCache() throws {
        // Given
        let movie = MovieDTO(id: 123, title: "Test", overview: "Test", posterPath: nil, backdropPath: nil, voteAverage: 7.0, releaseDate: "2024-01-01")
        let actors = [ActorDTO(id: 1, name: "Actor", character: "Hero", profilePath: nil)]
        let images = ["/image1.jpg"]

        // When
        XCTAssertNoThrow(try sut.saveMovieDetails(movie, actors: actors, images: images, movieId: 123))

        // Then - verify data was saved by trying to load it
        let loaded: CachedMovieDetailsDTO? = cacheService.load(forKey: "cache.movie.123")
        XCTAssertNotNil(loaded)
        XCTAssertEqual(loaded?.movie.id, 123)
        XCTAssertEqual(loaded?.actors.count, 1)
        XCTAssertEqual(loaded?.images.count, 1)
    }
}
