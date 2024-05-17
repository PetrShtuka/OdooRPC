//
//  UserModel.swift
//  OdooRPC
//
//  Created by Peter on 20.04.2024.
//

import Foundation

// Decodable structure to decode user data from JSON response
public struct ResponseWrapper: Decodable {
    public var result: UserData
}

public struct UserData: Decodable {
    public var uid: Int?
    public var name: String?
    public var sessionToken: String?
    public var isSuperuser: Bool?
    public var language: String?
    public var timezone: String?
    public var partnerID: PartnerID?
    
    private enum CodingKeys: String, CodingKey {
        case uid
        case name
        case sessionToken = "session_id"
        case isSuperuser = "is_superuser"
        case language = "lang"
        case timezone = "tz"
        case partnerID = "partner_id"
    }
    
    public init(uid: Int?, name: String?, sessionToken: String?, isSuperuser: Bool?, language: String?, timezone: String?, partnerID: PartnerID?) {
        self.uid = uid
        self.name = name
        self.sessionToken = sessionToken
        self.isSuperuser = isSuperuser
        self.language = language
        self.timezone = timezone
        self.partnerID = partnerID
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        uid = try container.decodeIfPresent(Int.self, forKey: .uid)
        name = try container.decodeIfPresent(String.self, forKey: .name)
        sessionToken = try container.decodeIfPresent(String.self, forKey: .sessionToken)
        isSuperuser = try container.decodeIfPresent(Bool.self, forKey: .isSuperuser)
        language = try container.decodeIfPresent(String.self, forKey: .language)
        timezone = try container.decodeIfPresent(String.self, forKey: .timezone)
        partnerID = try container.decodeIfPresent(PartnerID.self, forKey: .partnerID)
    }
}

public struct PartnerID: Decodable {
    public var id: Int?
    public var name: String?

    public init(id: Int?, name: String?) {
        self.id = id
        self.name = name
    }

    public init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        id = try container.decodeIfPresent(Int.self)
        name = try container.decodeIfPresent(String.self)
    }
}
