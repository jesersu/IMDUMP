import Foundation
import IMDUMBPersistence

// MARK: - DTO to Domain Mapping Extensions
// Clean Architecture: Mapping between Data Layer (DTOs) and Domain Layer (Models)

extension MovieDTO {
    func toDomain(images: [String] = [], cast: [Actor] = []) -> Movie {
        return Movie(
            id: id,
            title: title,
            overview: overview,
            posterPath: posterPath,
            backdropPath: backdropPath,
            voteAverage: voteAverage,
            releaseDate: releaseDate ?? "",
            images: images,
            cast: cast
        )
    }
}

extension ActorDTO {
    func toDomain() -> Actor {
        return Actor(
            id: id,
            name: name,
            character: character,
            profilePath: profilePath
        )
    }
}
