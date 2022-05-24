//
//  LoginData.swift
//  Urban Transport Sharing
//
//  Created by Magzhan Zhumaly on 03.03.2022.
//

import Foundation

struct TransportData: Codable {
    let id: Int
    var latitude: String
    var longitude: String
    var type: Int
    var brand: String
}
