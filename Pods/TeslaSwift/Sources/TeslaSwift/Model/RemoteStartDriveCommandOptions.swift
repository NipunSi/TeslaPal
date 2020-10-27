//
//  RemoteStartDriveCommandOptions.swift
//  TeslaSwift
//
//  Created by Joao Nunes on 10/11/2016.
//  Copyright © 2016 Joao Nunes. All rights reserved.
//

import Foundation

open class RemoteStartDriveCommandOptions: Encodable {

	open var password: String?
	init(password: String) {
		self.password = password
	}
	
	enum CodingKeys: String, CodingKey {
		case password		 = "password"
	}
}
