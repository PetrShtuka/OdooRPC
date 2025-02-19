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
    public var partnerID: PartnerID?
    public var serverVersion: Int?

    public var avatar: String?

    private enum CodingKeys: String, CodingKey {
        case uid
        case id = "id"
        case name
        case sessionToken = "session_id"
        case isSuperuser = "is_superuser"
        case language = "lang"
        case timezone = "tz"
        case partnerID = "partner_id"
        case serverVersion
        case avatar = "avatar_128"
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        uid = try container.decodeIfPresent(Int.self, forKey: .uid) ??
              container.decodeIfPresent(Int.self, forKey: .id)

        name = try container.decodeIfPresent(String.self, forKey: .name)
        sessionToken = try container.decodeIfPresent(String.self, forKey: .sessionToken)
        isSuperuser = try container.decodeIfPresent(Bool.self, forKey: .isSuperuser)
        language = try container.decodeIfPresent(String.self, forKey: .language)
        timezone = try container.decodeIfPresent(String.self, forKey: .timezone)
        serverVersion = try container.decodeIfPresent(Int.self, forKey: .serverVersion)
        avatar = try container.decodeIfPresent(String.self, forKey: .avatar) ?? ""
        
        if let partnerIDArray = try? container.decodeIfPresent([AnyDecodable].self, forKey: .partnerID),
           let firstElement = partnerIDArray.first?.value as? Int {
            partnerID = PartnerID(id: firstElement, name: partnerIDArray.dropFirst().first?.value as? String)
        } else if let partnerIDInt = try? container.decodeIfPresent(Int.self, forKey: .partnerID) {
            partnerID = PartnerID(id: partnerIDInt, name: nil)
        } else {
            partnerID = nil
        }
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
