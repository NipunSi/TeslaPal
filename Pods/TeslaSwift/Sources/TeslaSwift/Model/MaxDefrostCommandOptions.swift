//
//  MaxDefrostCommandOptions.swift
//  TeslaSwift
//
//  Created by Joao Nunes on 19/10/2019.
//  Copyright © 2019 Joao Nunes. All rights reserved.
//

import Foundation


open class MaxDefrostCommandOptions: Encodable {
    
    open var on: Bool
    
    init(state: Bool) {
        on = state
    }
    
    enum CodingKeys: String, CodingKey {
        case on             = "on"
    }
}
