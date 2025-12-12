import Foundation

// MARK: - Movie Response DTOs
// Data Transfer Objects for API responses
struct MovieDTO: Codable {
    let id: Int
    let title: String
    let overview: String
    let posterPath: String?
    let backdropPath: String?
    let voteAverage: Double
    let releaseDate: String?

    enum CodingKeys: String, CodingKey {
        case id, title, overview
        case posterPath = "poster_path"
        case backdropPath = "backdrop_path"
        case voteAverage = "vote_average"
        case releaseDate = "release_date"
    }

//    func toDomain(images: [String] = [], cast: [Actor] = []) -> Movie {
//        return Movie(
//            id: id,
//            title: title,
//            overview: overview,
//            posterPath: posterPath,
//            backdropPath: backdropPath,
//            voteAverage: voteAverage,
//            releaseDate: releaseDate ?? "",
//            images: images,
//            cast: cast
//        )
//    }
}

struct MoviesResponse: Codable {
    let results: [MovieDTO]
}

struct ActorDTO: Codable {
    let id: Int
    let name: String
    let character: String
    let profilePath: String?

    enum CodingKeys: String, CodingKey {
        case id, name, character
        case profilePath = "profile_path"
    }

//    func toDomain() -> Actor {
//        return Actor(
//            id: id,
//            name: name,
//            character: character,
//            profilePath: profilePath
//        )
//    }
}

struct CreditsResponse: Codable {
    let cast: [ActorDTO]
}

struct ImagesResponse: Codable {
    let backdrops: [ImageDTO]

    struct ImageDTO: Codable {
        let filePath: String

        enum CodingKeys: String, CodingKey {
            case filePath = "file_path"
        }
    }
}
