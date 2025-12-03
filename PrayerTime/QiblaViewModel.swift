//
//  QiblaViewModel.swift
//  PrayerTime
//
//  Created by asma  on 11/06/1447 AH.
//

import Foundation
import CoreLocation
import Combine

class QiblaViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var qiblaAngle: Double = 0

    private let locationManager = CLLocationManager()
    private var lastLocation: CLLocation?

    private let kaabaLocation = CLLocation(latitude: 21.4225, longitude: 39.8262)

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest

        if CLLocationManager.headingAvailable() {
            locationManager.headingFilter = kCLHeadingFilterNone
        }

        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()

        if CLLocationManager.headingAvailable() {
            locationManager.startUpdatingHeading()
        }
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            locationManager.startUpdatingLocation()
            if CLLocationManager.headingAvailable() {
                locationManager.startUpdatingHeading()
            }
        default:
            break
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        lastLocation = location
        updateQiblaAngle()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        updateQiblaAngle(deviceHeading: newHeading.magneticHeading)
    }

    private func updateQiblaAngle(deviceHeading: Double? = nil) {
        guard let userLocation = lastLocation else { return }

        let heading = deviceHeading ?? locationManager.heading?.magneticHeading ?? 0
        let bearingToQibla = bearing(from: userLocation, to: kaabaLocation)
        let angle = bearingToQibla - heading

        DispatchQueue.main.async {
            self.qiblaAngle = self.normalizeAngle(angle)
        }
    }

    private func bearing(from: CLLocation, to: CLLocation) -> Double {
        let lat1 = from.coordinate.latitude.degreesToRadians
        let lon1 = from.coordinate.longitude.degreesToRadians
        let lat2 = to.coordinate.latitude.degreesToRadians
        let lon2 = to.coordinate.longitude.degreesToRadians

        let dLon = lon2 - lon1

        let y = sin(dLon) * cos(lat2)
        let x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon)

        let radiansBearing = atan2(y, x)
        var degreesBearing = radiansBearing.radiansToDegrees

        if degreesBearing < 0 {
            degreesBearing += 360
        }

        return degreesBearing
    }

    private func normalizeAngle(_ angle: Double) -> Double {
        var result = angle.truncatingRemainder(dividingBy: 360)
        if result < 0 { result += 360 }
        return result
    }
}

extension Double {
    var degreesToRadians: Double { self * .pi / 180 }
    var radiansToDegrees: Double { self * 180 / .pi }
}
