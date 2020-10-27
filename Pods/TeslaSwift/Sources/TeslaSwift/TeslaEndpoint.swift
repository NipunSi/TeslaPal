//
//  TeslaEndpoint.swift
//  TeslaSwift
//
//  Created by Joao Nunes on 16/04/16.
//  Copyright © 2016 Joao Nunes. All rights reserved.
//

import Foundation

enum Endpoint {
	
	case authentication
	case revoke
	case vehicles
    case vehicleSummary(vehicleID: String)
	case mobileAccess(vehicleID: String)
	case allStates(vehicleID: String)
	case chargeState(vehicleID: String)
	case climateState(vehicleID: String)
	case driveState(vehicleID: String)
    case nearbyChargingSites(vehicleID: String)
	case guiSettings(vehicleID: String)
	case vehicleState(vehicleID: String)
	case vehicleConfig(vehicleID: String)
	case wakeUp(vehicleID: String)
	case command(vehicleID: String, command:VehicleCommand)
}

extension Endpoint {
	
	var path: String {
		switch self {
		case .authentication:
			return "/oauth/token"
		case .revoke:
			return "/oauth/revoke"
		case .vehicles:
			return "/api/1/vehicles"
        case .vehicleSummary(let vehicleID):
            return "/api/1/vehicles/\(vehicleID)"
		case .mobileAccess(let vehicleID):
			return "/api/1/vehicles/\(vehicleID)/mobile_enabled"
		case .allStates(let vehicleID):
			return "/api/1/vehicles/\(vehicleID)/vehicle_data"
		case .chargeState(let vehicleID):
			return "/api/1/vehicles/\(vehicleID)/data_request/charge_state"
		case .climateState(let vehicleID):
			return "/api/1/vehicles/\(vehicleID)/data_request/climate_state"
		case .driveState(let vehicleID):
			return "/api/1/vehicles/\(vehicleID)/data_request/drive_state"
		case .guiSettings(let vehicleID):
			return "/api/1/vehicles/\(vehicleID)/data_request/gui_settings"
        case .nearbyChargingSites(let vehicleID):
            return "/api/1/vehicles/\(vehicleID)/nearby_charging_sites"
		case .vehicleState(let vehicleID):
			return "/api/1/vehicles/\(vehicleID)/data_request/vehicle_state"
		case .vehicleConfig(let vehicleID):
			return "/api/1/vehicles/\(vehicleID)/data_request/vehicle_config"
		case .wakeUp(let vehicleID):
			return "/api/1/vehicles/\(vehicleID)/wake_up"
		case let .command(vehicleID, command):
			return "/api/1/vehicles/\(vehicleID)/\(command.path())"
		}
	}
	
	var method: String {
		switch self {
		case .authentication, .revoke, .wakeUp, .command:
			return "POST"
        case .vehicles, .vehicleSummary, .mobileAccess, .allStates, .chargeState, .climateState, .driveState, .guiSettings, .vehicleState, .vehicleConfig, .nearbyChargingSites:
			return "GET"
		}
	}

    func baseURL(_ useMockServer: Bool) -> String {
        if useMockServer {
            let mockUrl = UserDefaults.standard.string(forKey: "mock_base_url")
            if mockUrl != nil && mockUrl!.count > 0 {
                return mockUrl!
            } else {
                return "https://private-623898-modelsapi.apiary-mock.com"
            }
        } else {
            return "https://owner-api.teslamotors.com"
        }
    }
}
