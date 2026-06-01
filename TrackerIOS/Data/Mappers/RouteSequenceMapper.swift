import Foundation

final class RouteSequenceMapper {
    func map(dto: RouteSequenceDTO) -> [RouteStop] {
        guard let firstBranch = dto.stopPointSequences?.first,
              let stops = firstBranch.stopPoint else { return [] }
        return stops
            .compactMap { mapStop(dto: $0) }
            .sorted { $0.sequenceNumber < $1.sequenceNumber }
    }

    private func mapStop(dto: RouteStopDTO) -> RouteStop? {
        guard let id = dto.id else { return nil }
        return RouteStop(
            id: id,
            name: dto.name ?? "",
            lat: dto.lat ?? 0,
            lon: dto.lon ?? 0,
            sequenceNumber: dto.sequenceNumber ?? 0
        )
    }
}
