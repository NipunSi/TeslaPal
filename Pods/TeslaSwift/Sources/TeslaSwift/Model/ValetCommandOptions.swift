//
//  ValetCommandOptions.swift
//  TeslaSwift
//
//  Created by Joao Nunes on 12/04/16.
//  Copyright © 2016 Joao Nunes. All rights reserved.
//

import Foundation

open class ValetCommandOptions: Codable {
	
	open var on: Bool = false
	open var password: String?
	
	init(valetActivated: Bool, pin: String?) {
		on = valetActivated
		password = pin
	}
	
	enum CodingKeys: String, CodingKey {
		case on			 = "on"
		case password	 = "password"
	}
}
