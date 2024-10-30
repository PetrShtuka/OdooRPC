//
//  UserModel.swift
//  OdooRPC
//
//  Created by Peter on 20.04.2024.
//

import Foundation

public struct ResponseWrapper: Decodable {
    public var result: UserData
}

public struct UserData: Equatable, Decodable {
    
    public static func == (lhs: UserData, rhs: UserData) -> Bool {
        return lhs.uid == rhs.uid &&
        lhs.name == rhs.name &&
        lhs.partnerID?.id == rhs.partnerID?.id
    }
    
    public var uid: Int?
    public var name: String?
    public var sessionToken: String?
    public var isSuperuser: Bool?
    public var language: String?
    public var timezone: String?
    public var avatar: String?
    public var partnerID: PartnerID?
    public var serverVersion: Int?
    
    private enum CodingKeys: String, CodingKey {
        case uid
        case name
        case sessionToken = "session_id"
        case isSuperuser = "is_superuser"
        case language = "lang"
        case timezone = "tz"
        case partnerID = "partner_id"
    }
    
    public init(uid: Int?, name: String?, sessionToken: String?, isSuperuser: Bool?, language: String?, timezone: String?, partnerID: PartnerID?, serverVersion: Int?) {
        self.uid = uid
        self.name = name
        self.sessionToken = sessionToken
        self.isSuperuser = isSuperuser
        self.language = language
        self.timezone = timezone
        self.partnerID = partnerID
        self.serverVersion = serverVersion
        
        self.avatar = serverVersion ?? 0 >= 15 ? "avatar_128" : "image_small"
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        uid = try container.decodeIfPresent(Int.self, forKey: .uid)
        name = try container.decodeIfPresent(String.self, forKey: .name)
        sessionToken = try container.decodeIfPresent(String.self, forKey: .sessionToken)
        isSuperuser = try container.decodeIfPresent(Bool.self, forKey: .isSuperuser)
        language = try container.decodeIfPresent(String.self, forKey: .language)
        timezone = try container.decodeIfPresent(String.self, forKey: .timezone)
        
        if let partnerIDArray = try? container.decodeIfPresent([AnyDecodable].self, forKey: .partnerID), let firstElement = partnerIDArray.first?.value as? Int {
            partnerID = PartnerID(id: firstElement, name: partnerIDArray.dropFirst().first?.value as? String)
        } else if let partnerIDInt = try? container.decodeIfPresent(Int.self, forKey: .partnerID) {
            partnerID = PartnerID(id: partnerIDInt, name: nil)
        } else {
            partnerID = nil
        }
        
        self.serverVersion = nil
        self.avatar = serverVersion ?? 0 >= 15 ? "avatar_128" : "image_small"
    }
}

public struct PartnerID: Decodable {
    public var id: Int?
    public var name: String?
    
    public init(id: Int?, name: String?) {
        self.id = id
        self.name = name
    }
}

// Helper struct for decoding heterogeneous arrays
public struct AnyDecodable: Decodable {
    public let value: Any
    
    public init(from decoder: Decoder) throws {
        if let int = try? decoder.singleValueContainer().decode(Int.self) {
            self.value = int
        } else if let string = try? decoder.singleValueContainer().decode(String.self) {
            self.value = string
        } else {
            throw DecodingError.typeMismatch(
                AnyDecodable.self,
                DecodingError.Context(
                    codingPath: decoder.codingPath,
                    debugDescription: "Not an int or string"
                )
            )
        }
    }
}
