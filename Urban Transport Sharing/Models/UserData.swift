//
//  RegistrationData.swift
//  Urban Transport Sharing
//
//  Created by Magzhan Zhumaly on 03.03.2022.
//

import Foundation

struct UserData: Codable {
    let id: Int
    var balance: Int
    var username: String
    var email: String
}
