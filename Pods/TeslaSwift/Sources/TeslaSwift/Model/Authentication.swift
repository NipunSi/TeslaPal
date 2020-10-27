//
//  AuthToken.swift
//  TeslaSwift
//
//  Created by Joao Nunes on 04/03/16.
//  Copyright © 2016 Joao Nunes. All rights reserved.
//

import Foundation

open class AuthToken: Codable {
	
	open var accessToken: String?
	open var tokenType: String?
	open var createdAt: Date? = Date()
	open var expiresIn: TimeInterval?
	open var refreshToken: String?
	
	open var isValid: Bool {
		if let createdAt = createdAt, let expiresIn = expiresIn {
			return -createdAt.timeIntervalSinceNow < expiresIn
		} else {
			return false
		}
	}
	
	public init(accessToken: String) {
		self.accessToken = accessToken
	}
	
	// MARK: Codable protocol
	
	enum CodingKeys: String, CodingKey {
		case accessToken = "access_token"
		case tokenType = "token_type"
		case createdAt = "created_at"
		case expiresIn = "expires_in"
		case refreshToken  = "refresh_token"
	}
}

class AuthTokenRequest: Encodable {
	
    enum GrantType: String, Encodable {
        case password
        case refreshToken = "refresh_token"
    }
    
    var grantType: GrantType
	var clientID: String = "81527cff06843c8634fdc09e8ac0abefb46ac849f38fe1e431c2ef2106796384"
	var clientSecret: String = "c7257eb71a564034f9419ee651c7d0e5f7aa6bfbd18bafb5c5c033b093bb2fa3"
	var email: String?
	var password: String?
    var refreshToken: String?
	
    init(email: String? = nil, password: String? = nil, grantType: GrantType = .password, refreshToken: String? = nil) {
		self.email = email
		self.password = password
		self.grantType = grantType
        self.refreshToken = refreshToken
	}
	
	// MARK: Codable protocol
	
	enum CodingKeys: String, CodingKey {
		typealias RawValue = String
		
		case grantType = "grant_type"
		case clientID = "client_id"
		case clientSecret = "client_secret"
		case email = "email"
		case password = "password"
        case refreshToken = "refresh_token"
	}
}
