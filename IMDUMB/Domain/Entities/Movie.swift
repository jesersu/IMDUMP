import Foundation

// MARK: - Movie Entity
// Domain layer entity representing a movie
// SOLID: Single Responsibility Principle - This struct only represents movie data
struct Movie {
    let id: Int
    let title: String
    let overview: String
    let posterPath: String?
    let backdropPath: String?
    let voteAverage: Double
    let releaseDate: String
    let images: [String]
    let cast: [Actor]

    var posterURL: URL? {
        guard let posterPath = posterPath else { return nil }
        return URL(string: "https://image.tmdb.org/t/p/w500\(posterPath)")
    }

    var backdropURL: URL? {
        guard let backdropPath = backdropPath else { return nil }
        return URL(string: "https://image.tmdb.org/t/p/w780\(backdropPath)")
    }
}

// MARK: - Actor Entity
struct Actor {
    let id: Int
    let name: String
    let character: String
    let profilePath: String?

    var profileURL: URL? {
        guard let profilePath = profilePath else { return nil }
        return URL(string: "https://image.tmdb.org/t/p/w185\(profilePath)")
    }
}

// MARK: - Category Entity
struct Category {
    let id: String
    let name: String
    let movies: [Movie]
}
