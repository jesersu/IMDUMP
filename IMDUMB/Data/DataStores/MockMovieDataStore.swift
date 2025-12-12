import Foundation
import IMDUMBPersistence

// MARK: - Mock Movie Data Store
// For testing and development without API calls
// SOLID: Liskov Substitution Principle - Can substitute RemoteMovieDataStore without breaking functionality
class MockMovieDataStore: MovieDataStoreProtocol {

    func fetchMovies(endpoint: String, completion: @escaping (Result<[MovieDTO], Error>) -> Void) {
        // Simulate network delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            let mockMovies = self.generateMockMovies()
            completion(.success(mockMovies))
        }
    }

    func fetchMovieDetails(movieId: Int, completion: @escaping (Result<MovieDTO, Error>) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            let mockMovie = self.generateMockMovies().first!
            completion(.success(mockMovie))
        }
    }

    func fetchMovieCredits(movieId: Int, completion: @escaping (Result<[ActorDTO], Error>) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            let mockActors = self.generateMockActors()
            completion(.success(mockActors))
        }
    }

    func fetchMovieImages(movieId: Int, completion: @escaping (Result<[String], Error>) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            let mockImages = [
                "/tmU7GeKVybMWFButWEGl2M4GeiP.jpg",
                "/9BBTo63ANSmhC4e6r62OJFuK2GL.jpg",
                "/cPFoD8xvdJxWGNvFOcjfGnJGDi2.jpg"
            ]
            completion(.success(mockImages))
        }
    }

    // MARK: - Mock Data Generators

    private func generateMockMovies() -> [MovieDTO] {
        return [
            MovieDTO(
                id: 1,
                title: "The Matrix",
                overview: "A computer hacker learns from mysterious rebels about the true nature of his reality and his role in the war against its controllers.",
                posterPath: "/f89U3ADr1oiB1s9GkdPOEpXUk5H.jpg",
                backdropPath: "/fNG7i7RqMErkcqhohV2a6cV1Ehy.jpg",
                voteAverage: 8.7,
                releaseDate: "1999-03-30"
            ),
            MovieDTO(
                id: 2,
                title: "Inception",
                overview: "A thief who steals corporate secrets through the use of dream-sharing technology is given the inverse task of planting an idea.",
                posterPath: "/9gk7adHYeDvHkCSEqAvQNLV5Uge.jpg",
                backdropPath: "/s3TBrRGB1iav7gFOCNx3H31MoES.jpg",
                voteAverage: 8.8,
                releaseDate: "2010-07-15"
            ),
            MovieDTO(
                id: 3,
                title: "Interstellar",
                overview: "A team of explorers travel through a wormhole in space in an attempt to ensure humanity's survival.",
                posterPath: "/gEU2QniE6E77NI6lCU6MxlNBvIx.jpg",
                backdropPath: "/xu9zaAevzQ5nnrsXN6JcahLnG4i.jpg",
                voteAverage: 8.6,
                releaseDate: "2014-11-05"
            )
        ]
    }

    private func generateMockActors() -> [ActorDTO] {
        return [
            ActorDTO(id: 1, name: "Keanu Reeves", character: "Neo", profilePath: "/4D0PpNI0kmP58hgrwGC3wCjxhnm.jpg"),
            ActorDTO(id: 2, name: "Laurence Fishburne", character: "Morpheus", profilePath: "/8suOhUmPbfKqDQ17bX9kXP8kmNt.jpg"),
            ActorDTO(id: 3, name: "Carrie-Anne Moss", character: "Trinity", profilePath: "/8iATAc5z5XOKFFARLsvaawa8MTY.jpg")
        ]
    }
}
