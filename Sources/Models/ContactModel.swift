//
//  ContactModel.swift
//  OdooRPC
//
//  Created by Peter on 20.04.2024.
//

import Foundation

public struct ContactsModel: Codable {
    public var id: Int
    public var street: String?
    public var street2: String?
    public var mobile: String?
    public var phone: String?
    public var zip: String?
    public var city: String?
    public var countryId: [Int: String]?  // Assuming "country_id" is returned as a dictionary with an ID and name
    public var displayName: String?
    public var isCompany: Bool?
    public var parentId: Int?
    public var type: String?
    public var childIds: [Int]?
    public var comment: String?
    public var email: String?
    public var avatar: String?
    public var name: String?
    public var lastUpdate: String?  // "__last_update"

    init(id: Int, street: String? = nil, street2: String? = nil, mobile: String? = nil, phone: String? = nil, zip: String? = nil, city: String? = nil, countryId: [Int : String]? = nil, displayName: String? = nil, isCompany: Bool? = nil, parentId: Int? = nil, type: String? = nil, childIds: [Int]? = nil, comment: String? = nil, email: String? = nil, avatar: String? = nil, name: String? = nil, lastUpdate: String? = nil) {
        self.id = id
        self.street = street
        self.street2 = street2
        self.mobile = mobile
        self.phone = phone
        self.zip = zip
        self.city = city
        self.countryId = countryId
        self.displayName = displayName
        self.isCompany = isCompany
        self.parentId = parentId
        self.type = type
        self.childIds = childIds
        self.comment = comment
        self.email = email
        self.avatar = avatar
        self.name = name
        self.lastUpdate = lastUpdate
    }
    
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
