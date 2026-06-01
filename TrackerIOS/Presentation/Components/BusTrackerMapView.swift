import SwiftUI
import MapKit

struct BusTrackerMapView: UIViewRepresentable {
    let stops: [RouteStop]
    let positions: [BusPosition]

    func makeCoordinator() -> Coordinator { Coordinator() }

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.showsUserLocation = false
        mapView.mapType = .standard
        return mapView
    }

    func updateUIView(_ mapView: MKMapView, context: Context) {
        mapView.removeOverlays(mapView.overlays)
        mapView.removeAnnotations(mapView.annotations)

        guard !stops.isEmpty else { return }

        addRoutePolyline(to: mapView)
        addStopAnnotations(to: mapView)
        addBusAnnotations(to: mapView)
        fitCamera(in: mapView)
    }

    // MARK: - Map building

    private func addRoutePolyline(to mapView: MKMapView) {
        let coords = stops.map { CLLocationCoordinate2D(latitude: $0.lat, longitude: $0.lon) }
        let polyline = MKPolyline(coordinates: coords, count: coords.count)
        mapView.addOverlay(polyline)
    }

    private func addStopAnnotations(to mapView: MKMapView) {
        for (index, stop) in stops.enumerated() {
            let annotation = BusStopAnnotation(
                coordinate: CLLocationCoordinate2D(latitude: stop.lat, longitude: stop.lon),
                title: stop.name,
                kind: index == 0 ? .start : (index == stops.count - 1 ? .end : .intermediate)
            )
            mapView.addAnnotation(annotation)
        }
    }

    private func addBusAnnotations(to mapView: MKMapView) {
        for position in positions {
            let annotation = BusPositionAnnotation(
                coordinate: CLLocationCoordinate2D(latitude: position.lat, longitude: position.lon),
                vehicleId: position.vehicleId,
                nextStop: position.nextStopName
            )
            mapView.addAnnotation(annotation)
        }
    }

    private func fitCamera(in mapView: MKMapView) {
        var coords = stops.map { CLLocationCoordinate2D(latitude: $0.lat, longitude: $0.lon) }
        coords += positions.map { CLLocationCoordinate2D(latitude: $0.lat, longitude: $0.lon) }
        guard !coords.isEmpty else { return }

        var minLat = coords[0].latitude, maxLat = coords[0].latitude
        var minLon = coords[0].longitude, maxLon = coords[0].longitude
        for c in coords {
            minLat = min(minLat, c.latitude); maxLat = max(maxLat, c.latitude)
            minLon = min(minLon, c.longitude); maxLon = max(maxLon, c.longitude)
        }

        let center = CLLocationCoordinate2D(latitude: (minLat + maxLat) / 2,
                                             longitude: (minLon + maxLon) / 2)
        let span = MKCoordinateSpan(
            latitudeDelta: max((maxLat - minLat) * 1.3, 0.01),
            longitudeDelta: max((maxLon - minLon) * 1.3, 0.01)
        )
        mapView.setRegion(MKCoordinateRegion(center: center, span: span), animated: true)
    }

    // MARK: - Coordinator

    final class Coordinator: NSObject, MKMapViewDelegate {
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if let polyline = overlay as? MKPolyline {
                let renderer = MKPolylineRenderer(polyline: polyline)
                renderer.strokeColor = UIColor(AppTheme.Colors.routeLine)
                renderer.lineWidth = 4
                return renderer
            }
            return MKOverlayRenderer(overlay: overlay)
        }

        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            if annotation is MKUserLocation { return nil }

            if let busAnnotation = annotation as? BusPositionAnnotation {
                let id = "bus"
                let view = mapView.dequeueReusableAnnotationView(withIdentifier: id)
                    ?? MKAnnotationView(annotation: annotation, reuseIdentifier: id)
                view.annotation = busAnnotation
                view.canShowCallout = true
                view.image = circleImage(color: UIColor(AppTheme.Colors.secondary), size: 20)
                return view
            }

            if let stopAnnotation = annotation as? BusStopAnnotation {
                let id = "stop-\(stopAnnotation.kind)"
                let view = mapView.dequeueReusableAnnotationView(withIdentifier: id)
                    ?? MKAnnotationView(annotation: annotation, reuseIdentifier: id)
                view.annotation = stopAnnotation
                view.canShowCallout = true
                let color: UIColor
                switch stopAnnotation.kind {
                case .start: color = UIColor(AppTheme.Colors.busStart)
                case .end:   color = UIColor(AppTheme.Colors.busEnd)
                case .intermediate: color = UIColor(AppTheme.Colors.primary).withAlphaComponent(0.6)
                }
                view.image = circleImage(color: color, size: stopAnnotation.kind == .intermediate ? 8 : 14)
                return view
            }

            return nil
        }

        private func circleImage(color: UIColor, size: CGFloat) -> UIImage {
            UIGraphicsImageRenderer(size: CGSize(width: size, height: size)).image { ctx in
                color.setFill()
                ctx.cgContext.fillEllipse(in: CGRect(x: 0, y: 0, width: size, height: size))
            }
        }
    }
}

// MARK: - Annotation types

final class BusStopAnnotation: NSObject, MKAnnotation {
    enum Kind { case start, intermediate, end }
    let coordinate: CLLocationCoordinate2D
    let title: String?
    let kind: Kind

    init(coordinate: CLLocationCoordinate2D, title: String, kind: Kind) {
        self.coordinate = coordinate
        self.title = title
        self.kind = kind
    }
}

final class BusPositionAnnotation: NSObject, MKAnnotation {
    let coordinate: CLLocationCoordinate2D
    let title: String?
    let subtitle: String?

    init(coordinate: CLLocationCoordinate2D, vehicleId: String, nextStop: String) {
        self.coordinate = coordinate
        self.title = "Bus \(vehicleId)"
        self.subtitle = "Next: \(nextStop)"
    }
}
