//
//  SetSunRoofCommandOptions.swift
//  TeslaSwift
//
//  Created by Joao Nunes on 10/11/2016.
//  Copyright © 2016 Joao Nunes. All rights reserved.
//

import Foundation

public enum RoofState: String, Codable {
    case close
    case vent
}

open class SetSunRoofCommandOptions: Encodable {

	open var state: RoofState
	open var percent: Int?
	init(state: RoofState, percent: Int?) {
		self.state = state
		self.percent = percent
	}
	
}
