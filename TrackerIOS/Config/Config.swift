import Foundation

enum Config {
    static var tflApiKey: String {
        Bundle.main.object(forInfoDictionaryKey: "TFL_API_KEY") as? String ?? ""
    }
    static var mapsApiKey: String {
        Bundle.main.object(forInfoDictionaryKey: "MAPS_API_KEY") as? String ?? ""
    }
}
