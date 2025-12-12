import Foundation

public struct CachedMoviesDTO: Codable {
    let movies: [MovieDTO]
    let timestamp: Date
}

public struct CachedMovieDetailsDTO: Codable {
    let movie: MovieDTO
    let actors: [ActorDTO]
    let images: [String]
    let timestamp: Date
}
