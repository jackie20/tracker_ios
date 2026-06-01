import Foundation

struct Journey: Identifiable, Equatable {
    let id: UUID
    let duration: Int
    let legs: [JourneyLeg]

    init(duration: Int, legs: [JourneyLeg]) {
        self.id = UUID()
        self.duration = duration
        self.legs = legs
    }
}

struct JourneyLeg: Identifiable, Equatable {
    let id: UUID
    let lineId: String
    let lineName: String
    let fromName: String
    let toName: String
    let duration: Int
    let summary: String

    init(lineId: String, lineName: String, fromName: String,
         toName: String, duration: Int, summary: String) {
        self.id = UUID()
        self.lineId = lineId
        self.lineName = lineName
        self.fromName = fromName
        self.toName = toName
        self.duration = duration
        self.summary = summary
    }
}
