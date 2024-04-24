//
//  UserModel.swift
//  OdooRPC
//
//  Created by Peter on 20.04.2024.
//

import Foundation

// Decodable structure to decode user data from JSON response
public struct UserData: Decodable {
    var uid: Int?
    var email: String?
    var language: String?
    var timezone: String?
    var partnerID: Int?
    var avatar: String?
    var name: String?
    var sessionToken: String?
    var isSuperuser: Bool?
    
    private enum CodingKeys: String, CodingKey {
        case uid = "user_id"
        case name
        case email
        case language = "lang"
        case timezone = "tz"
        case partnerID = "partner_id"
        case avatar = "avatar_128"
        case sessionToken = "session_id"
        case isSuperuser = "is_superuser"
    }
}
