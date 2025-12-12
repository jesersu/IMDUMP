import Foundation

public struct CachedMoviesDTO: Codable {
    public  let movies: [MovieDTO]
    let timestamp: Date
}

public struct CachedMovieDetailsDTO: Codable {
    public let movie: MovieDTO
    public let actors: [ActorDTO]
    public let images: [String]
    public let timestamp: Date
}
