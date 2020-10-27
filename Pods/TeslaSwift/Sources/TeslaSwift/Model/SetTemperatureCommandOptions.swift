//
//  SetTemperatureCommandOptions.swift
//  TeslaSwift
//
//  Created by Joao Nunes on 10/11/2016.
//  Copyright © 2016 Joao Nunes. All rights reserved.
//

import Foundation

open class SetTemperatureCommandOptions: Encodable {

	open var driverTemp: Double?
	open var passengerTemp: Double?
	init(driverTemperature: Double, passengerTemperature: Double) {
		driverTemp = driverTemperature
		passengerTemp = passengerTemperature
	}
	
	enum CodingKeys: String, CodingKey {
		case driverTemp		 = "driver_temp"
		case passengerTemp	 = "passenger_temp"
	}
}
