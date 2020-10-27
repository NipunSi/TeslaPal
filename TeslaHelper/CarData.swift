//
//  CarData.swift
//  TeslaHelper
//
//  Created by Nipun Singh on 10/23/20.
//

import Foundation
import TeslaSwift

class CarData: ObservableObject {
    @Published var data: [VehicleExtended]
    
    init() {
        self.data = []
    }
}

