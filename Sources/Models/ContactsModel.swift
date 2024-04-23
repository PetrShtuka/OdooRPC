//
//  ContactsModel.swift
//  OdooRPC
//
//  Created by Peter on 13.04.2024.
//

import Foundation

struct PartnerModel: Decodable {
    let id: Int
    let avatar: String?
    let displayName: String
    let email: String?
    let country: String?
    let street: String?
    let zip: Int?
    let city: String?
    let mobile: String?
    let phone: String?
    let updateDate: String?
    let localUserId: Int?
    let isCompany: Bool
    let parentId: Int?
    let childIds: [Int]?
    let note: String?
    let name: String
    let type: String?
    let street2: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case avatar = "avatar_128" // Assuming the key from the server is 'avatar_128'
        case displayName = "display_name"
        case email = "email"
        case country = "country_id" // Adjust if the server sends an object or ID
        case street = "street"
        case zip = "zip"
        case city = "city"
        case mobile = "mobile"
        case phone = "phone"
        case updateDate = "__last_update"
        case localUserId = "local_user_id"
        case isCompany = "is_company"
        case parentId = "parent_id"
        case childIds = "child_ids"
        case note = "comment"
        case name = "name"
        case type = "type"
        case street2 = "street2"
    }
}
