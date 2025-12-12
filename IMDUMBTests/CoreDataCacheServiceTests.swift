import XCTest
import CoreData
@testable import IMDUMB

class CoreDataCacheServiceTests: XCTestCase {

    var sut: CoreDataCacheService!
    var testContext: NSManagedObjectContext!

    override func setUp() {
        super.setUp()
        testContext = TestCoreDataStack.testContainer.viewContext
        sut = CoreDataCacheService(context: testContext)
        TestCoreDataStack.reset()
    }

    override func tearDown() {
        sut = nil
        testContext = nil
        TestCoreDataStack.reset()
        super.tearDown()
    }

    // MARK: - Save and Load Movies Tests

    func testSaveMovies_CreatesCategory() throws {
        // Given
        let movies = createTestMovies(count: 3)
        let cachedMovies = CachedMoviesDTO(movies: movies, timestamp: Date())
        let key = "cache.category.popular"

        // When
        try sut.save(cachedMovies, forKey: key)

        // Then
        let request: NSFetchRequest<CachedCategory> = CachedCategory.fetchRequest()
        let categories = try testContext.fetch(request)

        XCTAssertEqual(categories.count, 1)
        XCTAssertEqual(categories.first?.id, "popular")
        XCTAssertEqual((categories.first?.movies as? Set<CachedMovie>)?.count, 3)
    }

    func testLoadMovies_ReturnsNilWhenNoData() {
        // Given
        let key = "cache.category.popular"

        // When
        let result: CachedMoviesDTO? = sut.load(forKey: key)

        // Then
        XCTAssertNil(result)
    }

    func testLoadMovies_ReturnsMoviesWhenDataExists() throws {
        // Given
        let movies = createTestMovies(count: 2)
        let cachedMovies = CachedMoviesDTO(movies: movies, timestamp: Date())
        let key = "cache.category.top_rated"

        try sut.save(cachedMovies, forKey: key)

        // When
        let result: CachedMoviesDTO? = sut.load(forKey: key)

        // Then
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.movies.count, 2)
        XCTAssertEqual(result?.movies.first?.title, "Test Movie 0")
    }

    // MARK: - Save and Load Movie Details Tests

    func testSaveMovieDetails_CreatesMovieWithActorsAndImages() throws {
        // Given
        let movie = createTestMovie(id: 1)
        let actors = createTestActors(count: 2)
        let images = ["image1.jpg", "image2.jpg"]
        let cachedDetails = CachedMovieDetailsDTO(
            movie: movie,
            actors: actors,
            images: images,
            timestamp: Date()
        )
        let key = "cache.movie.1"

        // When
        try sut.save(cachedDetails, forKey: key)

        // Then
        let request: NSFetchRequest<CachedMovie> = CachedMovie.fetchRequest()
        request.predicate = NSPredicate(format: "id == %d", 1)
        let movies = try testContext.fetch(request)

        XCTAssertEqual(movies.count, 1)
        XCTAssertEqual((movies.first?.actors as? Set<CachedActor>)?.count, 2)
        XCTAssertEqual((movies.first?.images as? Set<CachedImage>)?.count, 2)
    }

    func testLoadMovieDetails_ReturnsDetailsWhenExists() throws {
        // Given
        let movie = createTestMovie(id: 42)
        let actors = createTestActors(count: 3)
        let images = ["backdrop.jpg"]
        let cachedDetails = CachedMovieDetailsDTO(
            movie: movie,
            actors: actors,
            images: images,
            timestamp: Date()
        )
        let key = "cache.movie.42"

        try sut.save(cachedDetails, forKey: key)

        // When
        let result: CachedMovieDetailsDTO? = sut.load(forKey: key)

        // Then
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.movie.id, 42)
        XCTAssertEqual(result?.actors.count, 3)
        XCTAssertEqual(result?.images.count, 1)
    }

    // MARK: - Expiration Tests

    func testIsExpired_ReturnsTrueWhenNoData() {
        // Given
        let key = "cache.category.popular"
        let expirationInterval: TimeInterval = 24 * 60 * 60

        // When
        let isExpired = sut.isExpired(forKey: key, expirationInterval: expirationInterval)

        // Then
        XCTAssertTrue(isExpired)
    }

    func testIsExpired_ReturnsFalseWhenDataIsFresh() throws {
        // Given
        let movies = createTestMovies(count: 1)
        let cachedMovies = CachedMoviesDTO(movies: movies, timestamp: Date())
        let key = "cache.category.upcoming"
        let expirationInterval: TimeInterval = 24 * 60 * 60

        try sut.save(cachedMovies, forKey: key)

        // When
        let isExpired = sut.isExpired(forKey: key, expirationInterval: expirationInterval)

        // Then
        XCTAssertFalse(isExpired)
    }

    func testIsExpired_ReturnsTrueWhenDataIsOld() throws {
        // Given
        let oldTimestamp = Date().addingTimeInterval(-25 * 60 * 60) // 25 hours ago
        let movies = createTestMovies(count: 1)
        let cachedMovies = CachedMoviesDTO(movies: movies, timestamp: oldTimestamp)
        let key = "cache.category.now_playing"
        let expirationInterval: TimeInterval = 24 * 60 * 60

        try sut.save(cachedMovies, forKey: key)

        // When
        let isExpired = sut.isExpired(forKey: key, expirationInterval: expirationInterval)

        // Then
        XCTAssertTrue(isExpired)
    }

    // MARK: - Remove Tests

    func testRemove_DeletesCategory() throws {
        // Given
        let movies = createTestMovies(count: 2)
        let cachedMovies = CachedMoviesDTO(movies: movies, timestamp: Date())
        let key = "cache.category.popular"

        try sut.save(cachedMovies, forKey: key)

        // When
        sut.remove(forKey: key)

        // Then
        let result: CachedMoviesDTO? = sut.load(forKey: key)
        XCTAssertNil(result)
    }

    func testRemove_DeletesMovieDetails() throws {
        // Given
        let movie = createTestMovie(id: 99)
        let cachedDetails = CachedMovieDetailsDTO(
            movie: movie,
            actors: [],
            images: [],
            timestamp: Date()
        )
        let key = "cache.movie.99"

        try sut.save(cachedDetails, forKey: key)

        // When
        sut.remove(forKey: key)

        // Then
        let result: CachedMovieDetailsDTO? = sut.load(forKey: key)
        XCTAssertNil(result)
    }

    // MARK: - Clear All Tests

    func testClearAll_RemovesAllData() throws {
        // Given
        let movies1 = createTestMovies(count: 2)
        let movies2 = createTestMovies(count: 1)

        try sut.save(CachedMoviesDTO(movies: movies1, timestamp: Date()), forKey: "cache.category.popular")
        try sut.save(CachedMoviesDTO(movies: movies2, timestamp: Date()), forKey: "cache.category.top_rated")

        // When
        sut.clearAll()

        // Then
        let result1: CachedMoviesDTO? = sut.load(forKey: "cache.category.popular")
        let result2: CachedMoviesDTO? = sut.load(forKey: "cache.category.top_rated")

        XCTAssertNil(result1)
        XCTAssertNil(result2)

        // Verify all entities are empty
        let categoryRequest: NSFetchRequest<CachedCategory> = CachedCategory.fetchRequest()
        let categories = try testContext.fetch(categoryRequest)
        XCTAssertEqual(categories.count, 0)
    }

    // MARK: - Helper Methods

    private func createTestMovies(count: Int) -> [MovieDTO] {
        return (0..<count).map { index in
            createTestMovie(id: index)
        }
    }

    private func createTestMovie(id: Int) -> MovieDTO {
        return MovieDTO(
            id: id,
            title: "Test Movie \(id)",
            overview: "Test overview for movie \(id)",
            posterPath: "/poster\(id).jpg",
            backdropPath: "/backdrop\(id).jpg",
            voteAverage: 7.5,
            releaseDate: "2024-01-01"
        )
    }

    private func createTestActors(count: Int) -> [ActorDTO] {
        return (0..<count).map { index in
            ActorDTO(
                id: index,
                name: "Actor \(index)",
                character: "Character \(index)",
                profilePath: "/profile\(index).jpg"
            )
        }
    }
}
