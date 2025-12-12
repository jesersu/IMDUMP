import XCTest
@testable import IMDUMB

class CacheServiceTests: XCTestCase {

    var sut: CacheService!
    let testKey = "test.cache.key"

    override func setUp() {
        super.setUp()
        sut = CacheService.shared
        sut.clearAll()
    }

    override func tearDown() {
        sut.clearAll()
        sut = nil
        super.tearDown()
    }

    // MARK: - Test Save and Load

    func testSave_WithValidCodableObject_ShouldSucceed() {
        // Given
        let testMovies = [
            MovieDTO(id: 1, title: "Test Movie", overview: "Test", posterPath: nil, backdropPath: nil, voteAverage: 7.0, releaseDate: "2024-01-01")
        ]

        // When
        XCTAssertNoThrow(try sut.save(testMovies, forKey: testKey))

        // Then
        let loaded: [MovieDTO]? = sut.load(forKey: testKey)
        XCTAssertNotNil(loaded)
        XCTAssertEqual(loaded?.count, 1)
        XCTAssertEqual(loaded?.first?.id, 1)
        XCTAssertEqual(loaded?.first?.title, "Test Movie")
    }

    func testLoad_WithNonExistentKey_ShouldReturnNil() {
        // When
        let loaded: [MovieDTO]? = sut.load(forKey: "nonexistent.key")

        // Then
        XCTAssertNil(loaded)
    }

    func testSave_WithMultipleSaves_ShouldOverwritePreviousValue() {
        // Given
        let movies1 = [MovieDTO(id: 1, title: "Movie 1", overview: "Test", posterPath: nil, backdropPath: nil, voteAverage: 7.0, releaseDate: "2024-01-01")]
        let movies2 = [MovieDTO(id: 2, title: "Movie 2", overview: "Test", posterPath: nil, backdropPath: nil, voteAverage: 8.0, releaseDate: "2024-01-02")]

        // When
        try? sut.save(movies1, forKey: testKey)
        try? sut.save(movies2, forKey: testKey)

        // Then
        let loaded: [MovieDTO]? = sut.load(forKey: testKey)
        XCTAssertEqual(loaded?.count, 1)
        XCTAssertEqual(loaded?.first?.id, 2)
        XCTAssertEqual(loaded?.first?.title, "Movie 2")
    }

    // MARK: - Test Expiration

    func testIsExpired_WithFreshData_ShouldReturnFalse() {
        // Given
        let testMovies = [MovieDTO(id: 1, title: "Test", overview: "Test", posterPath: nil, backdropPath: nil, voteAverage: 7.0, releaseDate: "2024-01-01")]
        try? sut.save(testMovies, forKey: testKey)

        // When
        let isExpired = sut.isExpired(forKey: testKey, expirationInterval: 60)

        // Then
        XCTAssertFalse(isExpired)
    }

    func testIsExpired_WithNonExistentKey_ShouldReturnTrue() {
        // When
        let isExpired = sut.isExpired(forKey: "nonexistent.key", expirationInterval: 60)

        // Then
        XCTAssertTrue(isExpired)
    }

    func testIsExpired_WithExpiredData_ShouldReturnTrue() {
        // Given
        let testMovies = [MovieDTO(id: 1, title: "Test", overview: "Test", posterPath: nil, backdropPath: nil, voteAverage: 7.0, releaseDate: "2024-01-01")]
        try? sut.save(testMovies, forKey: testKey)

        // When
        let isExpired = sut.isExpired(forKey: testKey, expirationInterval: -1)

        // Then
        XCTAssertTrue(isExpired, "Data should be expired with negative expiration interval")
    }

    // MARK: - Test Remove

    func testRemove_WithExistingKey_ShouldRemoveData() {
        // Given
        let testMovies = [MovieDTO(id: 1, title: "Test", overview: "Test", posterPath: nil, backdropPath: nil, voteAverage: 7.0, releaseDate: "2024-01-01")]
        try? sut.save(testMovies, forKey: testKey)

        // When
        sut.remove(forKey: testKey)

        // Then
        let loaded: [MovieDTO]? = sut.load(forKey: testKey)
        XCTAssertNil(loaded)
    }

    func testRemove_WithNonExistentKey_ShouldNotCrash() {
        // When/Then
        XCTAssertNoThrow(sut.remove(forKey: "nonexistent.key"))
    }

    // MARK: - Test Clear All

    func testClearAll_WithMultipleKeys_ShouldRemoveAllCachedData() {
        // Given
        let movies1 = [MovieDTO(id: 1, title: "Movie 1", overview: "Test", posterPath: nil, backdropPath: nil, voteAverage: 7.0, releaseDate: "2024-01-01")]
        let movies2 = [MovieDTO(id: 2, title: "Movie 2", overview: "Test", posterPath: nil, backdropPath: nil, voteAverage: 8.0, releaseDate: "2024-01-02")]

        try? sut.save(movies1, forKey: "cache.key1")
        try? sut.save(movies2, forKey: "cache.key2")

        // When
        sut.clearAll()

        // Then
        let loaded1: [MovieDTO]? = sut.load(forKey: "cache.key1")
        let loaded2: [MovieDTO]? = sut.load(forKey: "cache.key2")

        XCTAssertNil(loaded1)
        XCTAssertNil(loaded2)
    }

    // MARK: - Test Different Data Types

    func testSave_WithCachedMoviesDTO_ShouldSucceed() {
        // Given
        let movies = [MovieDTO(id: 1, title: "Test", overview: "Test", posterPath: nil, backdropPath: nil, voteAverage: 7.0, releaseDate: "2024-01-01")]
        let cachedDTO = CachedMoviesDTO(movies: movies, timestamp: Date())

        // When
        try? sut.save(cachedDTO, forKey: testKey)

        // Then
        let loaded: CachedMoviesDTO? = sut.load(forKey: testKey)
        XCTAssertNotNil(loaded)
        XCTAssertEqual(loaded?.movies.count, 1)
        XCTAssertEqual(loaded?.movies.first?.id, 1)
    }

    func testSave_WithCachedMovieDetailsDTO_ShouldSucceed() {
        // Given
        let movie = MovieDTO(id: 1, title: "Test", overview: "Test", posterPath: nil, backdropPath: nil, voteAverage: 7.0, releaseDate: "2024-01-01")
        let actors = [ActorDTO(id: 1, name: "Actor", character: "Hero", profilePath: nil)]
        let images = ["/image1.jpg", "/image2.jpg"]
        let cachedDTO = CachedMovieDetailsDTO(movie: movie, actors: actors, images: images, timestamp: Date())

        // When
        try? sut.save(cachedDTO, forKey: testKey)

        // Then
        let loaded: CachedMovieDetailsDTO? = sut.load(forKey: testKey)
        XCTAssertNotNil(loaded)
        XCTAssertEqual(loaded?.movie.id, 1)
        XCTAssertEqual(loaded?.actors.count, 1)
        XCTAssertEqual(loaded?.images.count, 2)
    }

    // MARK: - Test Cache Keys

    func testCacheKey_Category_ShouldGenerateCorrectKey() {
        // When
        let key = CacheKey.category("popular")

        // Then
        XCTAssertEqual(key, "cache.category.popular")
    }

    func testCacheKey_MovieDetails_ShouldGenerateCorrectKey() {
        // When
        let key = CacheKey.movieDetails(123)

        // Then
        XCTAssertEqual(key, "cache.movie.123")
    }

    func testCacheKey_Timestamp_ShouldGenerateCorrectKey() {
        // When
        let key = CacheKey.timestamp(for: "cache.category.popular")

        // Then
        XCTAssertEqual(key, "cache.category.popular.timestamp")
    }
}
