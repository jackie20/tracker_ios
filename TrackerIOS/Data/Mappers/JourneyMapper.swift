import Foundation

final class JourneyMapper {
    func map(dto: JourneyDTO) -> Journey? {
        let busLegs = (dto.legs ?? []).compactMap { mapLeg(dto: $0) }
        guard !busLegs.isEmpty else { return nil }
        return Journey(
            duration: dto.duration ?? 0,
            legs: busLegs
        )
    }

    func mapList(dtos: [JourneyDTO]) -> [Journey] {
        dtos.compactMap { map(dto: $0) }
    }

    private func mapLeg(dto: LegDTO) -> JourneyLeg? {
        guard dto.mode?.id == "bus" else { return nil }
        let routeOption = dto.routeOptions?.first
        let lineId = routeOption?.lineIdentifier?.id ?? ""
        let lineName = routeOption?.name ?? lineId
        return JourneyLeg(
            lineId: lineId,
            lineName: lineName,
            fromName: dto.departurePoint?.commonName ?? "",
            toName: dto.arrivalPoint?.commonName ?? "",
            duration: dto.duration ?? 0,
            summary: dto.instruction?.summary ?? ""
        )
    }
}
