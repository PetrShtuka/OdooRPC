//
//  UserModel.swift
//  OdooRPC
//
//  Created by Peter on 20.04.2024.
//

import Foundation

// Decodable structure to decode user data from JSON response
public struct ResponseWrapper: Decodable {
    var result: UserData
}

public struct UserData: Decodable {
    var uid: Int?
    var name: String?
    var sessionToken: String?
    var isSuperuser: Bool?
    var language: String?
    var timezone: String?
    var partnerID: Int?

    private enum CodingKeys: String, CodingKey {
        case uid
        case name
        case sessionToken = "session_id"
        case isSuperuser = "is_superuser"
        case language = "lang"
        case timezone = "tz"
        case partnerID = "partner_id"
    }
}
