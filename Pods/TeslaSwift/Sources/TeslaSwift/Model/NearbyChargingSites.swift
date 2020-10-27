//
//  NearbyChargingSites.swift
//  TeslaSwift
//
//  Created by Jordan Owens on 7/4/19.
//  Copyright © 2019 Jordan Owens. All rights reserved.
//

import Foundation
import CoreLocation

open class NearbyChargingSites: Codable {

    open var congestionSyncTimeUTCSecs: Int?
    open var destinationChargers: [DestinationCharger]?
    open var superchargers: [Supercharger]?
    open var timestamp: Double?

    enum CodingKeys: String, CodingKey {
        case congestionSyncTimeUTCSecs = "congestion_sync_time_utc_secs"
        case destinationChargers = "destination_charging"
        case superchargers = "superchargers"
        case timestamp = "timestamp"
    }

    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        congestionSyncTimeUTCSecs = try? container.decode(Int.self, forKey: .congestionSyncTimeUTCSecs)
        destinationChargers = try? container.decode([DestinationCharger].self, forKey: .destinationChargers)
        superchargers = try? container.decode([Supercharger].self, forKey: .superchargers)
        timestamp = try? container.decode(Double.self, forKey: .timestamp)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(congestionSyncTimeUTCSecs, forKey: .congestionSyncTimeUTCSecs)
        try container.encodeIfPresent(destinationChargers, forKey: .destinationChargers)
        try container.encodeIfPresent(superchargers, forKey: .superchargers)
        try container.encodeIfPresent(timestamp, forKey: .timestamp)
    }

    public struct DestinationCharger: Codable {
        public var distance: Distance?
        public var location: ChargerLocation?
        public var name: String?
        public var type: String?

        enum CodingKeys: String, CodingKey {
            case distance = "distance_miles"
            case name = "name"
            case location = "location"
            case type  = "type"
        }
    }

    public struct Supercharger: Codable {
        public var availableStalls: Int?
        public var distance: Distance?
        public var location: ChargerLocation?
        public var name: String?
        public var siteClosed: Bool?
        public var totalStalls: Int?
        public var type: String?

        enum CodingKeys: String, CodingKey {
            case availableStalls = "available_stalls"
            case distance = "distance_miles"
            case location = "location"
            case name = "name"
            case siteClosed = "site_closed"
            case totalStalls = "total_stalls"
            case type  = "type"
        }
    }

    public struct ChargerLocation: Codable {
        public var latitude: CLLocationDegrees?
        public var longitude: CLLocationDegrees?

        enum CodingKeys: String, CodingKey {
            case latitude = "lat"
            case longitude = "long"
        }
    }
}
