//
//  ClimateState.swift
//  TeslaSwift
//
//  Created by Joao Nunes on 14/03/16.
//  Copyright © 2016 Joao Nunes. All rights reserved.
//

import Foundation

open class ClimateState: Codable {
	
	open var batteryHeater: Bool?
	
	open var batteryHeaterNoPower: Bool?
	
	public struct Temperature: Codable {
		public var value: Measurement<UnitTemperature>
		
		public init(celsius: Double?) {
			let tempValue = celsius ?? 0.0
			value = Measurement<UnitTemperature>(value: tempValue, unit: .celsius)
		}
		public init(fahrenheit: Double) {
			value = Measurement<UnitTemperature>(value: fahrenheit, unit: .fahrenheit)
		}
		
		public init(from decoder: Decoder) throws {
			let container = try decoder.singleValueContainer()
			if let tempValue = try container.decode(Double?.self) {
				value = Measurement<UnitTemperature>(value: tempValue, unit: .celsius)
			} else {
				value = Measurement<UnitTemperature>(value: 0, unit: .celsius)
			}
		}
		
		public func encode(to encoder: Encoder) throws {
			
			var container = encoder.singleValueContainer()
			try container.encode(value.converted(to: .celsius).value)
			
		}
		
		public var celsius: Double { return value.converted(to: .celsius).value }
		public var fahrenheit: Double { return value.converted(to: .fahrenheit).value }
	}
	
	open var driverTemperatureSetting: Temperature?
	/*
	* Fan speed 0-6 or nil
	*/
	open var fanStatus: Int?
	
	open var insideTemperature: Temperature?
	
	open var isAutoConditioningOn: Bool?
	open var isClimateOn: Bool?
	open var isFrontDefrosterOn: Bool?
	open var isRearDefrosterOn: Bool?
	
	open var isPreconditioning: Bool?
	
	open var leftTemperatureDirection: Int?
	
	open var maxAvailableTemperature: Temperature?
	open var minAvailableTemperature: Temperature?
	
	open var outsideTemperature: Temperature?
	
	open var passengerTemperatureSetting: Temperature?
	
	open var remoteHeaterControlEnabled: Bool?
	/*
	* Temp directions 0 at least 583...
	*/
	open var rightTemperatureDirection: Int?
	
	
    open var seatHeaterLeft: Int?
	open var seatHeaterRearCenter: Int?
	open var seatHeaterRearLeft: Int?
	open var seatHeaterRearLeftBack: Int?
	open var seatHeaterRearRight: Int?
	open var seatHeaterRearRightBack: Int?
	open var seatHeaterRight: Int?
	
	open var sideMirrorHeaters: Bool?
	open var steeringWheelHeater: Bool?
	open var wiperBladeHeater: Bool?
	
	open var smartPreconditioning: Bool?
	
	open var timeStamp: Double?
	
	enum CodingKeys: String, CodingKey {
		
		case batteryHeater   = "battery_heater"
		case batteryHeaterNoPower = "battery_heater_no_power"
		
		case driverTemperatureSetting	= "driver_temp_setting"
		case fanStatus					 = "fan_status"
		
		case insideTemperature			= "inside_temp"
		
		case isAutoConditioningOn		 = "is_auto_conditioning_on"
		case isClimateOn	             = "is_climate_on"
		case isFrontDefrosterOn			 = "is_front_defroster_on"
		case isRearDefrosterOn			 = "is_rear_defroster_on"
		
		case isPreconditioning		= "is_preconditioning"
		
		case leftTemperatureDirection	 = "left_temp_direction"
		
		case maxAvailableTemperature     = "max_avail_temp"
		case minAvailableTemperature     = "min_avail_temp"
		
		case outsideTemperature			= "outside_temp"
		
		case passengerTemperatureSetting = "passenger_temp_setting"
		
		case remoteHeaterControlEnabled = "remote_heater_control_enabled"
		
		case rightTemperatureDirection	 = "right_temp_direction"
		
		
        case seatHeaterLeft				 = "seat_heater_left"
		case seatHeaterRearCenter		 = "seat_heater_rear_center"
		case seatHeaterRearLeft			 = "seat_heater_rear_left"
		case seatHeaterRearLeftBack		 = "seat_heater_rear_left_back"
		case seatHeaterRearRight			 = "seat_heater_rear_right"
		case seatHeaterRearRightBack		 = "seat_heater_rear_right_back"
		case seatHeaterRight				 = "seat_heater_right"
		
		case sideMirrorHeaters				= "side_mirror_heaters"
		case steeringWheelHeater			= "steering_wheel_heater"
		case wiperBladeHeater				= "wiper_blade_heater"
		
        case smartPreconditioning		 = "smart_preconditioning"
		
		case timeStamp					= "timestamp"
        
	}
	
	required public init(from decoder: Decoder) throws {
		
		let container = try decoder.container(keyedBy: CodingKeys.self)
		
		batteryHeater = try? container.decode(Bool.self, forKey: .batteryHeater)
		
		batteryHeaterNoPower = try? container.decode(Bool.self, forKey: .batteryHeaterNoPower)
		
		driverTemperatureSetting = try? container.decode(Temperature.self, forKey: .driverTemperatureSetting)
	
		fanStatus = try? container.decode(Int.self, forKey: .fanStatus)
		
		insideTemperature  = try? container.decode(Temperature.self, forKey: .insideTemperature)
		
		isAutoConditioningOn  = try? container.decode(Bool.self, forKey: .isAutoConditioningOn)
		isClimateOn  = try? container.decode(Bool.self, forKey: .isClimateOn)
		isFrontDefrosterOn  = try? container.decode(Bool.self, forKey: .isFrontDefrosterOn)
		isRearDefrosterOn  = try? container.decode(Bool.self, forKey: .isRearDefrosterOn)
		
		isPreconditioning  = try? container.decode(Bool.self, forKey: .isPreconditioning)
		
		leftTemperatureDirection  = try? container.decode(Int.self, forKey: .leftTemperatureDirection)
		
		maxAvailableTemperature  = try? container.decode(Temperature.self, forKey: .maxAvailableTemperature)
		minAvailableTemperature  = try? container.decode(Temperature.self, forKey: .minAvailableTemperature)
		
		outsideTemperature  = try? container.decode(Temperature.self, forKey: .outsideTemperature)
		
		passengerTemperatureSetting  = try? container.decode(Temperature.self, forKey: .passengerTemperatureSetting)
		
		remoteHeaterControlEnabled = try? container.decode(Bool.self, forKey: .remoteHeaterControlEnabled)

		rightTemperatureDirection  = try? container.decode(Int.self, forKey: .rightTemperatureDirection)
		
		
		seatHeaterLeft  = try? container.decode(Int.self, forKey: .seatHeaterLeft)
		seatHeaterRearCenter  = try? container.decode(Int.self, forKey: .seatHeaterRearCenter)
		seatHeaterRearLeft  = try? container.decode(Int.self, forKey: .seatHeaterRearLeft)
		seatHeaterRearLeftBack  = try? container.decode(Int.self, forKey: .seatHeaterRearLeftBack)
		seatHeaterRearRight  = try? container.decode(Int.self, forKey: .seatHeaterRearRight)
		seatHeaterRearRightBack  = try? container.decode(Int.self, forKey: .seatHeaterRearRightBack)
		seatHeaterRight  = try? container.decode(Int.self, forKey: .seatHeaterRight)
		
		sideMirrorHeaters  = try? container.decode(Bool.self, forKey: .sideMirrorHeaters)
		steeringWheelHeater  = try? container.decode(Bool.self, forKey: .steeringWheelHeater)
		wiperBladeHeater  = try? container.decode(Bool.self, forKey: .wiperBladeHeater)
		
		smartPreconditioning  = try? container.decode(Bool.self, forKey: .smartPreconditioning)
		
		timeStamp  = try? container.decode(Double.self, forKey: .timeStamp)
		
	}
	
	public func encode(to encoder: Encoder) throws {
		
		var container = encoder.container(keyedBy: CodingKeys.self)
		
		try container.encodeIfPresent(batteryHeater, forKey: .batteryHeater)
		
		
		try container.encodeIfPresent(batteryHeaterNoPower, forKey: .batteryHeaterNoPower)
		
		try container.encodeIfPresent(driverTemperatureSetting, forKey: .driverTemperatureSetting)
		
		try container.encodeIfPresent(fanStatus, forKey: .fanStatus)
		
		try container.encodeIfPresent(insideTemperature, forKey: .insideTemperature)

		try container.encodeIfPresent(isAutoConditioningOn, forKey: .isAutoConditioningOn)
		try container.encodeIfPresent(isClimateOn, forKey: .isClimateOn)
		try container.encodeIfPresent(isFrontDefrosterOn, forKey: .isFrontDefrosterOn)
		try container.encodeIfPresent(isRearDefrosterOn, forKey: .isRearDefrosterOn)
		try container.encodeIfPresent(isPreconditioning, forKey: .isPreconditioning)
		try container.encodeIfPresent(leftTemperatureDirection, forKey: .leftTemperatureDirection)
		try container.encodeIfPresent(maxAvailableTemperature, forKey: .maxAvailableTemperature)
		try container.encodeIfPresent(minAvailableTemperature, forKey: .minAvailableTemperature)
		
		try container.encodeIfPresent(outsideTemperature, forKey: .outsideTemperature)
		
		try container.encodeIfPresent(passengerTemperatureSetting, forKey: .passengerTemperatureSetting)
		
		try container.encodeIfPresent(remoteHeaterControlEnabled, forKey: .remoteHeaterControlEnabled)
		
		try container.encodeIfPresent(rightTemperatureDirection, forKey: .rightTemperatureDirection)
		
		try container.encodeIfPresent(seatHeaterLeft, forKey: .seatHeaterLeft)
		try container.encodeIfPresent(seatHeaterRearCenter, forKey: .seatHeaterRearCenter)
		try container.encodeIfPresent(seatHeaterRearLeft, forKey: .seatHeaterRearLeft)

		try container.encodeIfPresent(seatHeaterRearLeftBack, forKey: .seatHeaterRearLeftBack)
		try container.encodeIfPresent(seatHeaterRearRight, forKey: .seatHeaterRearRight)
		try container.encodeIfPresent(seatHeaterRearRightBack, forKey: .seatHeaterRearRightBack)
		try container.encodeIfPresent(seatHeaterRight, forKey: .seatHeaterRight)
		try container.encodeIfPresent(sideMirrorHeaters, forKey: .sideMirrorHeaters)
		try container.encodeIfPresent(steeringWheelHeater, forKey: .steeringWheelHeater)
		try container.encodeIfPresent(wiperBladeHeater, forKey: .wiperBladeHeater)
		
		try container.encodeIfPresent(smartPreconditioning, forKey: .smartPreconditioning)
		
		try container.encodeIfPresent(timeStamp, forKey: .timeStamp)
	}
}
