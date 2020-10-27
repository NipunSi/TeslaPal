//
//  HomeLinkCommandOptions.swift
//  TeslaSwift
//
//  Created by Joao Nunes on 19/10/2019.
//  Copyright © 2019 Joao Nunes. All rights reserved.
//

import Foundation
import CoreLocation

open class HomeLinkCommandOptions: Encodable {
    
    open var latitude: CLLocationDegrees
    open var longitude: CLLocationDegrees
    
    init(coordinates: CLLocation) {
        self.latitude = coordinates.coordinate.latitude
        self.longitude = coordinates.coordinate.longitude
    }
    
    enum CodingKeys: String, CodingKey {
        case latitude = "lat"
        case longitude = "lon"
    }
}
