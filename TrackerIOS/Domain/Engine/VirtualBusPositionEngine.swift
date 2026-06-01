import Foundation

/**
 * Domain service that infers approximate GPS positions for vehicles on a route.
 *
 * The TfL API provides `naptanId` (approaching stop) and `timeToStation` for
 * each vehicle, but no raw GPS coordinates. This engine joins BusArrival records
 * with RouteStop geometry, placing each vehicle at its next stop's coordinates.
 *
 * This is the "Virtual GPS" concept described in the assignment: combining
 * three independent datasets (journey planning, live arrivals, route geometry)
 * to derive inferred positions good enough for a live map view.
 *
 * Deduplication: a vehicle scheduled at multiple stops on the same line gets
 * one map pin placed at its soonest upcoming stop.
 *
 * Optional enhancement (not implemented): linearly interpolate between the
 * previous stop and next stop using (1 - timeToStation / stopInterval) as
 * a progress fraction for smoother positioning.
 */
final class VirtualBusPositionEngine {

    /**
     * - Parameters:
     *   - arrivals: Live arrival records for one bus line.
     *   - routeStops: Ordered stop sequence from the route geometry endpoint.
     * - Returns: One `BusPosition` per unique vehicle, placed at its next stop.
     *            Returns an empty array when `routeStops` is empty.
     */
    func derivePositions(arrivals: [BusArrival], routeStops: [RouteStop]) -> [BusPosition] {
        guard !routeStops.isEmpty else { return [] }

        let stopById = Dictionary(uniqueKeysWithValues: routeStops.map { ($0.id, $0) })

        // Reduce to one arrival per vehicle, keeping the soonest timeToStation.
        var soonestByVehicle: [String: BusArrival] = [:]
        for arrival in arrivals {
            if let existing = soonestByVehicle[arrival.vehicleId] {
                if arrival.timeToStation < existing.timeToStation {
                    soonestByVehicle[arrival.vehicleId] = arrival
                }
            } else {
                soonestByVehicle[arrival.vehicleId] = arrival
            }
        }

        return soonestByVehicle.values.compactMap { arrival in
            guard let stop = stopById[arrival.naptanId] else { return nil }
            return BusPosition(
                vehicleId: arrival.vehicleId,
                lat: stop.lat,
                lon: stop.lon,
                timeToStation: arrival.timeToStation,
                nextStopName: stop.name,
                nextNaptanId: stop.id
            )
        }
    }
}
