//
//  ContactsModel.swift
//  OdooRPC
//
//  Created by Peter on 13.04.2024.
//

import Foundation

public struct PartnerModel: Decodable {
   public let id: Int
   public let avatar: String?
   public let displayName: String
   public let email: String?
   public let country: String?
   public let street: String?
   public let zip: Int?
   public let city: String?
   public let mobile: String?
   public let phone: String?
   public let updateDate: String?
   public let localUserId: Int?
   public let isCompany: Bool
   public let parentId: Int?
   public let childIds: [Int]?
   public let note: String?
   public let name: String
   public let type: String?
   public let street2: String?
    
    public enum CodingKeys: String, CodingKey {
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
