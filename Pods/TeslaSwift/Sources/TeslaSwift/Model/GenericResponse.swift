//
//  GenericResponse.swift
//  TeslaSwift
//
//  Created by Joao Nunes on 24/06/16.
//  Copyright © 2016 Joao Nunes. All rights reserved.
//

import Foundation

open class Response<T: Decodable>: Decodable {
	
	open var response: T
	
	public init(response: T) {
		self.response = response
	}
	
	// MARK: Codable protocol
	
	enum CodingKeys: String, CodingKey {
		case response
	}
	
}

open class ArrayResponse<T: Decodable>: Decodable {
	
	open var response: [T] = []
	
	// MARK: Codable protocol
	
	enum CodingKeys: String, CodingKey {
		case response
	}
	
}


open class BoolResponse: Decodable {
	
	open var response: Bool
	
	public init(response: Bool) {
		self.response = response
	}
	
	// MARK: Codable protocol
	
	enum CodingKeys: String, CodingKey {
		case response = "response"
	}
	
}
