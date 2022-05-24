//
//  LoginData.swift
//  Urban Transport Sharing
//
//  Created by Magzhan Zhumaly on 03.03.2022.
//

import Foundation

struct LoginData: Codable {
    let message: String
    let id: Int
    let email: String
    let roles: [String]
    let statusCode: Int
    let type: StringLiteralType
    let token: String
    let username: String
}
