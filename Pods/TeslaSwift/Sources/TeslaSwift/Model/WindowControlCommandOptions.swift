//
//  WindowControlCommandOptions.swift
//  TeslaSwift
//
//  Created by Joao Nunes on 19/10/2019.
//  Copyright © 2019 Joao Nunes. All rights reserved.
//

import Foundation
import CoreLocation

public enum WindowState: String, Codable {
    case close
    case vent
}

open class WindowControlCommandOptions: Encodable {
    
    open var latitude: CLLocationDegrees = 0
    open var longitude: CLLocationDegrees = 0
    open var command: WindowState
    
    init(command: WindowState) {
        self.command = command
    }
    
    enum CodingKeys: String, CodingKey {
        case latitude = "lat"
        case longitude = "lon"
        case command = "command"
    }
}
