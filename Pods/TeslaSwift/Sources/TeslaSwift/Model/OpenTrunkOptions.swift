//
//  OpenTrunkOptions.swift
//  TeslaSwift
//
//  Created by Joao Nunes on 16/04/16.
//  Copyright © 2016 Joao Nunes. All rights reserved.
//

import Foundation

public enum OpenTrunkOptions: String, Codable {
	
	case rear
	case front
	
	enum CodingKeys: String, CodingKey {
		typealias RawValue = String
		
		case whichTrunk	= "which_trunk"
	}
	
	public init(from decoder: Decoder) throws {
		let values = try decoder.container(keyedBy: CodingKeys.self)
		
		if let trunk = try? values.decode(String.self, forKey: .whichTrunk),
			trunk == "front" {
			self = .front
		} else {
			self = .rear
		}
	}
	
	public func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		
		switch self {
		case .rear:
			try container.encode("rear", forKey: .whichTrunk)
		case .front:
			try container.encode("front", forKey: .whichTrunk)
		}
	}
}
