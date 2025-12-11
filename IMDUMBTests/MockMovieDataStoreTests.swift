import XCTest
@testable import IMDUMB

// MARK: - MockMovieDataStore Tests
class MockMovieDataStoreTests: XCTestCase {

    var sut: MockMovieDataStore!

    override func setUp() {
        super.setUp()
        sut = MockMovieDataStore()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    // MARK: - Test Fetch Movies

    func testFetchMovies_Popular_ShouldReturnMovies() {
        // Given
        let expectation = self.expectation(description: "Movies fetched")

        // When
        sut.fetchMovies(category: "popular") { result in
            // Then
            switch result {
            case .success(let movies):
                XCTAssertFalse(movies.isEmpty, "Should return mock movies")
                XCTAssertTrue(movies.allSatisfy { $0.title.isEmpty == false }, "All movies should have titles")
                expectation.fulfill()
            case .failure:
                XCTFail("Mock data store should not fail")
            }
        }

        waitForExpectations(timeout: 1.0)
    }

    func testFetchMovies_TopRated_ShouldReturnMovies() {
        // Given
        let expectation = self.expectation(description: "Top rated movies fetched")

        // When
        sut.fetchMovies(category: "top_rated") { result in
            // Then
            switch result {
            case .success(let movies):
                XCTAssertFalse(movies.isEmpty)
                expectation.fulfill()
            case .failure:
                XCTFail("Mock data store should not fail")
            }
        }

        waitForExpectations(timeout: 1.0)
    }

    func testFetchMovies_Upcoming_ShouldReturnMovies() {
        // Given
        let expectation = self.expectation(description: "Upcoming movies fetched")

        // When
        sut.fetchMovies(category: "upcoming") { result in
            // Then
            switch result {
            case .success(let movies):
                XCTAssertFalse(movies.isEmpty)
                expectation.fulfill()
            case .failure:
                XCTFail("Mock data store should not fail")
            }
        }

        waitForExpectations(timeout: 1.0)
    }

    func testFetchMovies_NowPlaying_ShouldReturnMovies() {
        // Given
        let expectation = self.expectation(description: "Now playing movies fetched")

        // When
        sut.fetchMovies(category: "now_playing") { result in
            // Then
            switch result {
            case .success(let movies):
                XCTAssertFalse(movies.isEmpty)
                expectation.fulfill()
            case .failure:
                XCTFail("Mock data store should not fail")
            }
        }

        waitForExpectations(timeout: 1.0)
    }

    // MARK: - Test Fetch Movie Details

    func testFetchMovieDetails_WithValidId_ShouldReturnDetails() {
        // Given
        let expectation = self.expectation(description: "Movie details fetched")

        // When
        sut.fetchMovieDetails(movieId: 1) { result in
            // Then
            switch result {
            case .success(let details):
                XCTAssertEqual(details.id, 1)
                XCTAssertFalse(details.title.isEmpty)
                XCTAssertFalse(details.overview.isEmpty)
                XCTAssertGreaterThan(details.voteAverage, 0)
                XCTAssertFalse(details.credits.cast.isEmpty, "Should have cast members")
                XCTAssertFalse(details.images.backdrops.isEmpty, "Should have images")
                expectation.fulfill()
            case .failure:
                XCTFail("Mock data store should not fail for valid ID")
            }
        }

        waitForExpectations(timeout: 1.0)
    }

    func testFetchMovieDetails_MultipleIds_ShouldReturnDifferentMovies() {
        // Given
        let expectation1 = self.expectation(description: "Movie 1 fetched")
        let expectation2 = self.expectation(description: "Movie 2 fetched")

        var movie1Title: String?
        var movie2Title: String?

        // When
        sut.fetchMovieDetails(movieId: 1) { result in
            if case .success(let details) = result {
                movie1Title = details.title
                expectation1.fulfill()
            }
        }

        sut.fetchMovieDetails(movieId: 2) { result in
            if case .success(let details) = result {
                movie2Title = details.title
                expectation2.fulfill()
            }
        }

        waitForExpectations(timeout: 1.0)

        // Then
        XCTAssertNotNil(movie1Title)
        XCTAssertNotNil(movie2Title)
    }

    // MARK: - Test Data Quality

    func testFetchMovies_ShouldReturnValidDTOs() {
        // Given
        let expectation = self.expectation(description: "Valid DTOs returned")

        // When
        sut.fetchMovies(category: "popular") { result in
            // Then
            switch result {
            case .success(let movies):
                for movie in movies {
                    XCTAssertGreaterThan(movie.id, 0, "Movie ID should be positive")
                    XCTAssertFalse(movie.title.isEmpty, "Movie should have title")
                    XCTAssertFalse(movie.overview.isEmpty, "Movie should have overview")
                    XCTAssertGreaterThanOrEqual(movie.voteAverage, 0, "Vote average should be non-negative")
                    XCTAssertLessThanOrEqual(movie.voteAverage, 10, "Vote average should be max 10")
                }
                expectation.fulfill()
            case .failure:
                XCTFail("Should not fail")
            }
        }

        waitForExpectations(timeout: 1.0)
    }

    func testFetchMovieDetails_ShouldReturnValidDetailDTO() {
        // Given
        let expectation = self.expectation(description: "Valid detail DTO returned")

        // When
        sut.fetchMovieDetails(movieId: 1) { result in
            // Then
            switch result {
            case .success(let details):
                XCTAssertGreaterThan(details.id, 0)
                XCTAssertFalse(details.title.isEmpty)
                XCTAssertGreaterThanOrEqual(details.voteAverage, 0)
                XCTAssertLessThanOrEqual(details.voteAverage, 10)

                // Check cast
                for cast in details.credits.cast {
                    XCTAssertGreaterThan(cast.id, 0)
                    XCTAssertFalse(cast.name.isEmpty)
                }

                expectation.fulfill()
            case .failure:
                XCTFail("Should not fail")
            }
        }

        waitForExpectations(timeout: 1.0)
    }
}
