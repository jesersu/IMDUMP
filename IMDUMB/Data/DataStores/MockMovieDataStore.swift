import Foundation
import IMDUMBPersistence
import RxSwift

// MARK: - Mock Movie Data Store
// For testing and development without API calls
// SOLID: Liskov Substitution Principle - Can substitute RemoteMovieDataStore without breaking functionality
class MockMovieDataStore: MovieDataStoreProtocol {

    func fetchMovies(endpoint: String) -> Single<[MovieDTO]> {
        return Single.create { observer in
            // Simulate network delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                let mockMovies = self.generateMockMovies()
                observer(.success(mockMovies))
            }
            return Disposables.create()
        }
    }

    func fetchMovieDetails(movieId: Int) -> Single<MovieDTO> {
        return Single.create { observer in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                let mockMovie = self.generateMockMovies().first!
                observer(.success(mockMovie))
            }
            return Disposables.create()
        }
    }

    func fetchMovieCredits(movieId: Int) -> Single<[ActorDTO]> {
        return Single.create { observer in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                let mockActors = self.generateMockActors()
                observer(.success(mockActors))
            }
            return Disposables.create()
        }
    }

    func fetchMovieImages(movieId: Int) -> Single<[String]> {
        return Single.create { observer in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                let mockImages = [
                    "/tmU7GeKVybMWFButWEGl2M4GeiP.jpg",
                    "/9BBTo63ANSmhC4e6r62OJFuK2GL.jpg",
                    "/cPFoD8xvdJxWGNvFOcjfGnJGDi2.jpg"
                ]
                observer(.success(mockImages))
            }
            return Disposables.create()
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
