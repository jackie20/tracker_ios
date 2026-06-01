import Foundation

final class StopPointMapper {
    func map(dto: StopPointMatchDTO) -> StopPoint {
        StopPoint(
            id: dto.id,
            name: dto.name,
            lat: dto.lat ?? 0,
            lon: dto.lon ?? 0
        )
    }

    func mapList(dtos: [StopPointMatchDTO]) -> [StopPoint] {
        dtos.map { map(dto: $0) }
    }

    func mapDisambiguationOption(dto: DisambiguationOptionDTO) -> StopPoint? {
        guard let place = dto.place,
              let id = place.id ?? dto.parameterValue,
              let name = place.commonName else { return nil }
        return StopPoint(
            id: id,
            name: name,
            lat: place.lat ?? 0,
            lon: place.lon ?? 0
        )
    }

    func mapDisambiguationOptions(dtos: [DisambiguationOptionDTO]) -> [StopPoint] {
        dtos.compactMap { mapDisambiguationOption(dto: $0) }
    }
}
