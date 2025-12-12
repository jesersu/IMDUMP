import Foundation
import CoreData

extension CachedActor {

    // MARK: - DTO Conversion

    /// Converts CachedActor entity to ActorDTO
    func toDTO() -> ActorDTO {
        return ActorDTO(
            id: Int(id),
            name: name,
            character: character,
            profilePath: profilePath
        )
    }

    /// Creates or updates CachedActor from ActorDTO
    /// - Parameters:
    ///   - dto: The ActorDTO to convert
    ///   - context: The managed object context
    /// - Returns: CachedActor entity
    static func from(dto: ActorDTO, context: NSManagedObjectContext) -> CachedActor {
        let request: NSFetchRequest<CachedActor> = CachedActor.fetchRequest()
        request.predicate = NSPredicate(format: "id == %d", dto.id)

        // Try to find existing actor
        let existing = try? context.fetch(request).first
        let actor = existing ?? CachedActor(context: context)

        // Update properties
        actor.id = Int64(dto.id)
        actor.name = dto.name
        actor.character = dto.character
        actor.profilePath = dto.profilePath

        return actor
    }

    /// Converts array of CachedActor to array of ActorDTO
    static func toDTOArray(_ actors: [CachedActor]) -> [ActorDTO] {
        return actors.map { $0.toDTO() }
    }

    /// Converts array of ActorDTO to array of CachedActor
    static func fromDTOArray(_ dtos: [ActorDTO], context: NSManagedObjectContext) -> [CachedActor] {
        return dtos.map { from(dto: $0, context: context) }
    }
}
