import Foundation

final class ArrivalMapper {
    func map(dto: ArrivalDTO) -> BusArrival? {
        guard let vehicleId = dto.vehicleId, !vehicleId.isEmpty,
              let naptanId = dto.naptanId, !naptanId.isEmpty else { return nil }
        return BusArrival(
            vehicleId: vehicleId,
            naptanId: naptanId,
            stationName: dto.stationName ?? "",
            lineId: dto.lineId ?? "",
            timeToStation: dto.timeToStation ?? 0,
            towards: dto.towards ?? dto.destinationName ?? "",
            direction: dto.direction ?? ""
        )
    }

    func mapList(dtos: [ArrivalDTO]) -> [BusArrival] {
        dtos.compactMap { map(dto: $0) }
    }
}
