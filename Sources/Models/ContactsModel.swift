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
    public var countryId: CountryId?
    public var displayName: String?
    public var isCompany: Bool?
    public var parentId: ParentId?
    public var type: String?
    public var childIds: [Int]?
    public var comment: String?
    public var email: String?
    public var avatar: String?
    public var name: String?
    public var lastUpdate: String?

    public struct CountryId: Codable {
        public var id: Int
        public var name: String
    }

    public struct ParentId: Codable {
        public var id: Int
        public var name: String
    }

    public init(id: Int, street: String? = nil, street2: String? = nil, mobile: String? = nil, phone: String? = nil, zip: String? = nil, city: String? = nil, countryId: CountryId? = nil, displayName: String? = nil, isCompany: Bool? = nil, parentId: ParentId? = nil, type: String? = nil, childIds: [Int]? = nil, comment: String? = nil, email: String? = nil, avatar: String? = nil, name: String? = nil, lastUpdate: String? = nil) {
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

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        street = try container.decodeIfPresent(String.self, forKey: .street)
        
        // Custom decoding to handle different types for street2
        if let street2String = try? container.decodeIfPresent(String.self, forKey: .street2) {
            street2 = street2String
        } else if let street2Bool = try? container.decodeIfPresent(Bool.self, forKey: .street2) {
            street2 = street2Bool ? "true" : "false"
        } else {
            street2 = nil
        }
        
        mobile = try container.decodeIfPresent(String.self, forKey: .mobile)
        phone = try container.decodeIfPresent(String.self, forKey: .phone)
        zip = try container.decodeIfPresent(String.self, forKey: .zip)
        city = try container.decodeIfPresent(String.self, forKey: .city)
        
        if let countryArray = try container.decodeIfPresent([JSONAny].self, forKey: .countryId), countryArray.count == 2, let id = countryArray[0].value as? Int, let name = countryArray[1].value as? String {
            countryId = CountryId(id: id, name: name)
        } else {
            countryId = nil
        }
        
        displayName = try container.decodeIfPresent(String.self, forKey: .displayName)
        isCompany = try container.decodeIfPresent(Bool.self, forKey: .isCompany)
        
        if let parentArray = try container.decodeIfPresent([JSONAny].self, forKey: .parentId), parentArray.count == 2, let id = parentArray[0].value as? Int, let name = parentArray[1].value as? String {
            parentId = ParentId(id: id, name: name)
        } else {
            parentId = nil
        }
        
        type = try container.decodeIfPresent(String.self, forKey: .type)
        childIds = try container.decodeIfPresent([Int].self, forKey: .childIds)
        comment = try container.decodeIfPresent(String.self, forKey: .comment)
        email = try container.decodeIfPresent(String.self, forKey: .email)
        avatar = try container.decodeIfPresent(String.self, forKey: .avatar)
        name = try container.decodeIfPresent(String.self, forKey: .name)
        lastUpdate = try container.decodeIfPresent(String.self, forKey: .lastUpdate)
    }
}

struct JSONAny: Codable {
    let value: Any

    init(_ value: Any) {
        self.value = value
    }

    init(from decoder: Decoder) throws {
        if let container = try? decoder.singleValueContainer() {
            if let value = try? container.decode(Bool.self) {
                self.value = value
                return
            }
            if let value = try? container.decode(Int.self) {
                self.value = value
                return
            }
            if let value = try? container.decode(Double.self) {
                self.value = value
                return
            }
            if let value = try? container.decode(String.self) {
                self.value = value
                return
            }
            if let value = try? container.decodeNil() {
                self.value = value
                return
            }
        }
        throw DecodingError.typeMismatch(JSONAny.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Could not decode JSONAny"))
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        if let value = self.value as? Bool {
            try container.encode(value)
            return
        }
        if let value = self.value as? Int {
            try container.encode(value)
            return
        }
        if let value = self.value as? Double {
            try container.encode(value)
            return
        }
        if let value = self.value as? String {
            try container.encode(value)
            return
        }
        if let _ = self.value as? NSNull {
            try container.encodeNil()
            return
        }
        throw EncodingError.invalidValue(self.value, EncodingError.Context(codingPath: encoder.codingPath, debugDescription: "Could not encode JSONAny"))
    }
}
