//
//  DrivingPosition.swift
//  TeslaSwift
//
//  Created by Joao Nunes on 14/03/16.
//  Copyright © 2016 Joao Nunes. All rights reserved.
//

import Foundation
import CoreLocation

open class DriveState: Codable {
	
	open var shiftState: String?
	
	open var speed: CLLocationSpeed?
	open var latitude: CLLocationDegrees?
	open var longitude: CLLocationDegrees?
	open var heading: CLLocationDirection?
	open var nativeLatitude: CLLocationDegrees?
	open var nativeLongitude: CLLocationDegrees?
	private var nativeLocationSupportedBool: Int?
	open var nativeLocationSupported: Bool { return nativeLocationSupportedBool == 1 }
	open var nativeType: String?
	
	open var date: Date?
	open var timeStamp: Double?
	open var power: Int?
	
	
	open var position: CLLocation? {
		if let latitude = latitude,
			let longitude = longitude,
			let heading = heading,
			let date = date {
				let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
				return CLLocation(coordinate: coordinate,
					altitude: 0.0, horizontalAccuracy: 0.0, verticalAccuracy: 0.0,
					course: heading,
					speed: speed ?? 0,
					timestamp: date)
				
		}
		return nil
	}
	
	enum CodingKeys: String, CodingKey {
		case shiftState	 = "shift_state"
		case speed		 = "speed"
		case latitude	 = "latitude"
		case longitude	 = "longitude"
		case power
		case heading	= "heading"
		case date		= "gps_as_of"
		case timeStamp	= "timestamp"
		case nativeLatitude = "native_latitude"
		case nativeLongitude = "native_longitude"
		case nativeLocationSupportedBool = "native_location_supported"
		case nativeType = "native_type"
	}

	required public init(from decoder: Decoder) throws {
		
		let container = try decoder.container(keyedBy: CodingKeys.self)

		
		shiftState = try? container.decode(String.self, forKey: .shiftState)
		
		speed = try? container.decode(CLLocationSpeed.self, forKey: .speed)
		latitude = try? container.decode(CLLocationDegrees.self, forKey: .latitude)
		longitude = try? container.decode(CLLocationDegrees.self, forKey: .longitude)
		heading = try? container.decode(CLLocationDirection.self, forKey: .heading)
		nativeLatitude = try? container.decode(CLLocationDegrees.self, forKey: .nativeLatitude)
		nativeLongitude = try? container.decode(CLLocationDegrees.self, forKey: .nativeLongitude)
		nativeLocationSupportedBool = try? container.decode(Int.self, forKey: .nativeLocationSupportedBool)

		nativeType = try? container.decode(String.self, forKey: .nativeType)
		
		date = try? container.decode(Date.self, forKey: .date)
		timeStamp = try? container.decode(Double.self, forKey: .timeStamp)
		power = try? container.decode(Int.self, forKey: .power)
		
	}
	
	public func encode(to encoder: Encoder) throws {
		
		var container = encoder.container(keyedBy: CodingKeys.self)
		
		
		try container.encodeIfPresent(shiftState, forKey: .shiftState)
		
		try container.encodeIfPresent(speed, forKey: .speed)
		try container.encodeIfPresent(latitude, forKey: .latitude)
		try container.encodeIfPresent(longitude, forKey: .longitude)
		try container.encodeIfPresent(heading, forKey: .heading)
		try container.encodeIfPresent(nativeLatitude, forKey: .nativeLatitude)
		try container.encodeIfPresent(nativeLongitude, forKey: .nativeLongitude)
		try container.encodeIfPresent(nativeLocationSupportedBool, forKey: .nativeLocationSupportedBool)

		try container.encodeIfPresent(nativeType, forKey: .nativeType)
		
		try container.encodeIfPresent(date, forKey: .date)
		try container.encodeIfPresent(timeStamp, forKey: .timeStamp)
		try container.encodeIfPresent(power, forKey: .power)
	}
	
}
