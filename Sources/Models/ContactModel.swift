//
//  ContactModel.swift
//  OdooRPC
//
//  Created by Peter on 20.04.2024.
//

import Foundation

struct ContactsModel: Codable {
    var id: Int
    var street: String?
    var street2: String?
    var mobile: String?
    var phone: String?
    var zip: String?
    var city: String?
    var countryId: [Int: String]?  // Assuming "country_id" is returned as a dictionary with an ID and name
    var displayName: String?
    var isCompany: Bool?
    var parentId: Int?
    var type: String?
    var childIds: [Int]?
    var comment: String?
    var email: String?
    var avatar: String?
    var name: String?
    var lastUpdate: String?  // "__last_update"

    enum CodingKeys: String, CodingKey {
        case id, street, street2, mobile, phone, zip, city, email, name, comment, type
        case countryId = "country_id"
        case displayName = "display_name"
        case isCompany = "is_company"
        case parentId = "parent_id"
        case childIds = "child_ids"
        case avatar = "avatar_128"
        case lastUpdate = "__last_update"
    }
}
