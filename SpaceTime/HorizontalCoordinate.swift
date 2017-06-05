//
//  HorizontalCoordinate.swift
//  SpaceTime
//
//  Created by Sihao Lu on 1/3/17.
//  Copyright © 2017 Ben Lu. All rights reserved.
//

import CoreLocation
import MathUtil

public struct HorizontalCoordinate: ExpressibleByDictionaryLiteral {
    let altitude: Double
    let azimuth: Double
    let distance: Double

    public init(azimuth: Double, altitude: Double, distance: Double = 1) {
        self.azimuth = azimuth
        self.altitude = altitude
        self.distance = distance
    }

    public init(equatorialCoordinate eqCoord: EquatorialCoordinate, observerInfo info: LocationAndTime) {
        let radianLat = radians(degrees: Double(info.location.coordinate.latitude))
        let hourAngle = info.localSiderealTimeAngle - eqCoord.rightAscension
        let sinAlt = sin(eqCoord.declination) * sin(radianLat) + cos(eqCoord.declination) * cos(radianLat) * cos(hourAngle)
        altitude = asin(sinAlt)
        let cosAzimuth = (sin(eqCoord.declination) - sinAlt * sin(radianLat)) / (cos(altitude) * cos(radianLat))
        let a = acos(cosAzimuth)
        azimuth = sin(hourAngle) < 0 ? a : Double(2 * Double.pi) - a
        distance = 1
    }

    public init(dictionary: [String: Double]) {
        if let altDeg = dictionary["altDeg"], let aziDeg = dictionary["aziDeg"] {
            self.init(azimuth: radians(degrees: aziDeg), altitude: radians(degrees: altDeg))
        } else if let alt = dictionary["alt"], let azi = dictionary["azi"] {
            self.init(azimuth: azi, altitude: alt)
        } else {
            fatalError("Supply (aziDeg, altDeg) or (azi, alt) as keys when initializing HorizontalCoordinate")
        }
    }

    public init(dictionaryLiteral elements: (String, Double)...) {
        var dict = [String: Double]()
        elements.forEach { dict[$0.0] = $0.1 }
        self.init(dictionary: dict)
    }
}

public extension EquatorialCoordinate {
    public init(horizontalCoordinate coord: HorizontalCoordinate, observerInfo info: LocationAndTime) {
        let latitude = radians(degrees: info.location.coordinate.latitude)
        let sinDec = sin(coord.altitude) * sin(latitude) + cos(coord.altitude) * cos(latitude) * cos(coord.azimuth)
        let dec = asin(sinDec)
        let sinLha = -sin(coord.azimuth) * cos(coord.altitude) / cos(dec)
        let cosLha = (sin(coord.altitude) - sin(latitude) * sin(dec)) / (cos(dec) * cos(latitude))
        let lha = atan2(sinLha, cosLha)
        let ra = info.localSiderealTimeAngle - lha
        self.init(rightAscension: ra, declination: dec, distance: 1)
    }
}
