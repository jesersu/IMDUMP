import Foundation

// MARK: - Movie Response DTOs
// Data Transfer Objects for API responses
public struct MovieDTO: Codable {
    public let id: Int
    public let title: String
    public let overview: String
    public let posterPath: String?
    public let backdropPath: String?
    public let voteAverage: Double
    public let releaseDate: String?

    public init(id: Int, title: String, overview: String, posterPath: String?, backdropPath: String?, voteAverage: Double, releaseDate: String?) {
        self.id = id
        self.title = title
        self.overview = overview
        self.posterPath = posterPath
        self.backdropPath = backdropPath
        self.voteAverage = voteAverage
        self.releaseDate = releaseDate
    }

    enum CodingKeys: String, CodingKey {
        case id, title, overview
        case posterPath = "poster_path"
        case backdropPath = "backdrop_path"
        case voteAverage = "vote_average"
        case releaseDate = "release_date"
    }
}

public struct MoviesResponse: Codable {
    public let results: [MovieDTO]

    public init(results: [MovieDTO]) {
        self.results = results
    }
}

public struct ActorDTO: Codable {
    public let id: Int
    public let name: String
    public let character: String
    public let profilePath: String?

    public init(id: Int, name: String, character: String, profilePath: String?) {
        self.id = id
        self.name = name
        self.character = character
        self.profilePath = profilePath
    }

    enum CodingKeys: String, CodingKey {
        case id, name, character
        case profilePath = "profile_path"
    }
}

public struct CreditsResponse: Codable {
    public let cast: [ActorDTO]

    public init(cast: [ActorDTO]) {
        self.cast = cast
    }
}

public struct ImagesResponse: Codable {
    public let backdrops: [ImageDTO]

    public init(backdrops: [ImageDTO]) {
        self.backdrops = backdrops
    }

    public struct ImageDTO: Codable {
        public let filePath: String

        public init(filePath: String) {
            self.filePath = filePath
        }

        enum CodingKeys: String, CodingKey {
            case filePath = "file_path"
        }
    }
}
