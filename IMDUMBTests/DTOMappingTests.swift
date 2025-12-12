import XCTest
import IMDUMBPersistence
@testable import IMDUMB

class DTOMappingTests: XCTestCase {

    // MARK: - MovieDTO Mapping Tests

    func testMovieDTOToDomain_WithAllFields_ShouldMapCorrectly() {
        // Given
        let movieDTO = IMDUMB.MovieDTO(
            id: 123,
            title: "Test Movie",
            overview: "This is a test overview",
            posterPath: "/poster.jpg",
            backdropPath: "/backdrop.jpg",
            voteAverage: 8.5,
            releaseDate: "2024-01-15"
        )
        let images = ["/image1.jpg", "/image2.jpg"]
        let actors = [
            Actor(id: 1, name: "Actor 1", character: "Character 1", profilePath: "/actor1.jpg"),
            Actor(id: 2, name: "Actor 2", character: "Character 2", profilePath: "/actor2.jpg")
        ]

        // When
        let movie = movieDTO.toDomain(images: images, cast: actors)

        // Then
        XCTAssertEqual(movie.id, 123)
        XCTAssertEqual(movie.title, "Test Movie")
        XCTAssertEqual(movie.overview, "This is a test overview")
        XCTAssertEqual(movie.posterPath, "/poster.jpg")
        XCTAssertEqual(movie.backdropPath, "/backdrop.jpg")
        XCTAssertEqual(movie.voteAverage, 8.5)
        XCTAssertEqual(movie.releaseDate, "2024-01-15")
        XCTAssertEqual(movie.images.count, 2)
        XCTAssertEqual(movie.cast.count, 2)
    }

    func testMovieDTOToDomain_WithNilOptionalFields_ShouldMapCorrectly() {
        // Given
        let movieDTO = IMDUMB.MovieDTO(
            id: 456,
            title: "Minimal Movie",
            overview: "Simple overview",
            posterPath: nil,
            backdropPath: nil,
            voteAverage: 6.0,
            releaseDate: nil
        )

        // When
        let movie = movieDTO.toDomain()

        // Then
        XCTAssertEqual(movie.id, 456)
        XCTAssertEqual(movie.title, "Minimal Movie")
        XCTAssertNil(movie.posterPath)
        XCTAssertNil(movie.backdropPath)
        XCTAssertEqual(movie.releaseDate, "") // nil becomes empty string
        XCTAssertTrue(movie.images.isEmpty)
        XCTAssertTrue(movie.cast.isEmpty)
    }

    func testMovieDTOToDomain_WithEmptyCollections_ShouldMapCorrectly() {
        // Given
        let movieDTO = IMDUMB.MovieDTO(
            id: 789,
            title: "Movie Without Extras",
            overview: "No images or cast",
            posterPath: "/poster.jpg",
            backdropPath: "/backdrop.jpg",
            voteAverage: 7.5,
            releaseDate: "2024-06-01"
        )

        // When
        let movie = movieDTO.toDomain(images: [], cast: [])

        // Then
        XCTAssertEqual(movie.id, 789)
        XCTAssertTrue(movie.images.isEmpty)
        XCTAssertTrue(movie.cast.isEmpty)
    }

    // MARK: - ActorDTO Mapping Tests

    func testActorDTOToDomain_WithAllFields_ShouldMapCorrectly() {
        // Given
        let actorDTO = IMDUMB.ActorDTO(
            id: 101,
            name: "Famous Actor",
            character: "Main Character",
            profilePath: "/profile.jpg"
        )

        // When
        let actor = actorDTO.toDomain()

        // Then
        XCTAssertEqual(actor.id, 101)
        XCTAssertEqual(actor.name, "Famous Actor")
        XCTAssertEqual(actor.character, "Main Character")
        XCTAssertEqual(actor.profilePath, "/profile.jpg")
    }

    func testActorDTOToDomain_WithNilProfilePath_ShouldMapCorrectly() {
        // Given
        let actorDTO = IMDUMB.ActorDTO(
            id: 202,
            name: "Unknown Actor",
            character: "Side Character",
            profilePath: nil
        )

        // When
        let actor = actorDTO.toDomain()

        // Then
        XCTAssertEqual(actor.id, 202)
        XCTAssertEqual(actor.name, "Unknown Actor")
        XCTAssertEqual(actor.character, "Side Character")
        XCTAssertNil(actor.profilePath)
    }

    // MARK: - Collection Mapping Tests

    func testMultipleActorDTOsToDomain_ShouldMapAllCorrectly() {
        // Given
        let actorDTOs = [
            IMDUMB.ActorDTO(id: 1, name: "Actor 1", character: "Hero", profilePath: "/hero.jpg"),
            IMDUMB.ActorDTO(id: 2, name: "Actor 2", character: "Villain", profilePath: "/villain.jpg"),
            IMDUMB.ActorDTO(id: 3, name: "Actor 3", character: "Sidekick", profilePath: nil)
        ]

        // When
        let actors = actorDTOs.map { $0.toDomain() }

        // Then
        XCTAssertEqual(actors.count, 3)
        XCTAssertEqual(actors[0].name, "Actor 1")
        XCTAssertEqual(actors[1].character, "Villain")
        XCTAssertNil(actors[2].profilePath)
    }

    // MARK: - Edge Cases

    func testMovieDTOToDomain_WithLargeImageCollection_ShouldMapAllImages() {
        // Given
        let movieDTO = IMDUMB.MovieDTO(
            id: 999,
            title: "Movie with Many Images",
            overview: "Test",
            posterPath: nil,
            backdropPath: nil,
            voteAverage: 5.0,
            releaseDate: nil
        )
        let images = (1...20).map { "/image\($0).jpg" }

        // When
        let movie = movieDTO.toDomain(images: images)

        // Then
        XCTAssertEqual(movie.images.count, 20)
        XCTAssertEqual(movie.images.first, "/image1.jpg")
        XCTAssertEqual(movie.images.last, "/image20.jpg")
    }

    func testMovieDTOToDomain_WithSpecialCharacters_ShouldPreserveData() {
        // Given
        let movieDTO = IMDUMB.MovieDTO(
            id: 888,
            title: "Título Español & Special!",
            overview: "Overview with <HTML> & special characters: émojis 🎬",
            posterPath: "/special-poster_123.jpg",
            backdropPath: nil,
            voteAverage: 9.9,
            releaseDate: "2024-12-25"
        )

        // When
        let movie = movieDTO.toDomain()

        // Then
        XCTAssertEqual(movie.title, "Título Español & Special!")
        XCTAssertTrue(movie.overview.contains("🎬"))
        XCTAssertTrue(movie.overview.contains("<HTML>"))
    }
}
