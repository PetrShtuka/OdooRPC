//
//  MessageModel.swift
//  OdooRPC
//
//  Created by Peter on 13.04.2024.
//

import Foundation

public struct MessageModel: Decodable {
    public let id: Int
    public let authorDisplay: String
    public let authorID: IDNamePair?
    public let date: String
    public let resID: Int
    public let needaction: Bool
    public let active: Bool
    public let subject: String?
    public let partnerIDs: [Int]
    public let parentID: IDNamePair?
    public let body: String
    public let recordName: String?
    public let emailFrom: String
    public let displayName: String
    public let deleteUID: Bool
    public let model: String
    public let authorAvatar: String?
    public let starred: Bool
    public var attachmentIDs: [Int]
    public var refPartnerIDs: [Int]
    public var subtypeID: [Int?]
    
    // Новое поле для хранения информации о типе authorID
    public let isAuthorIDBool: Bool
    
    enum CodingKeys: String, CodingKey {
        case id
        case authorDisplay = "author_display"
        case authorID = "author_id"
        case date
        case resID = "res_id"
        case needaction
        case active
        case subject
        case partnerIDs = "partner_ids"
        case parentID = "parent_id"
        case body
        case recordName = "record_name"
        case emailFrom = "email_from"
        case displayName = "display_name"
        case deleteUID = "delete_uid"
        case model
        case authorAvatar = "author_avatar"
        case starred
        case attachmentIDs = "attachment_ids"
        case refPartnerIDs = "ref_partner_ids"
        case subtypeID = "subtype_id"
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        authorDisplay = try container.decode(String.self, forKey: .authorDisplay)
        date = try container.decode(String.self, forKey: .date)
        resID = try container.decode(Int.self, forKey: .resID)
        needaction = try container.decode(Bool.self, forKey: .needaction)
        active = try container.decode(Bool.self, forKey: .active)
        
        // Попытка декодирования subject
        do {
            subject = try container.decodeIfPresent(String.self, forKey: .subject)
        } catch DecodingError.typeMismatch {
            subject = nil
        }
        
        partnerIDs = try container.decode([Int].self, forKey: .partnerIDs)
        
        // Попытка декодирования parentID
        do {
            if var parentArrayContainer = try? container.nestedUnkeyedContainer(forKey: .parentID) {
                let id = try parentArrayContainer.decode(Int.self)
                let name = try parentArrayContainer.decode(String.self)
                parentID = IDNamePair(id: id, name: name)
            } else {
                parentID = nil
            }
        } catch {
            parentID = nil
        }
        
        body = try container.decode(String.self, forKey: .body)
        
        // Попытка декодирования recordName
        do {
            recordName = try container.decodeIfPresent(String.self, forKey: .recordName)
        } catch DecodingError.typeMismatch {
            recordName = nil
        }
        
        emailFrom = try container.decode(String.self, forKey: .emailFrom)
        displayName = try container.decode(String.self, forKey: .displayName)
        deleteUID = try container.decode(Bool.self, forKey: .deleteUID)
        model = try container.decode(String.self, forKey: .model)
        
        // Попытка декодирования authorAvatar
        do {
            authorAvatar = try container.decodeIfPresent(String.self, forKey: .authorAvatar)
        } catch DecodingError.typeMismatch {
            authorAvatar = nil
        }
        
        starred = try container.decode(Bool.self, forKey: .starred)
        attachmentIDs = try container.decodeIfPresent([Int].self, forKey: .attachmentIDs) ?? []
        refPartnerIDs = try container.decodeIfPresent([Int].self, forKey: .refPartnerIDs) ?? []
        subtypeID = try container.decodeIfPresent([Int?].self, forKey: .subtypeID) ?? []
        
        // Попытка декодирования authorID с учетом возможного типа Bool
        do {
            authorID = try container.decode(IDNamePair.self, forKey: .authorID)
            isAuthorIDBool = false
        } catch DecodingError.typeMismatch {
            isAuthorIDBool = (try container.decodeIfPresent(Bool.self, forKey: .authorID)) ?? false
            authorID = nil
        }
    }
}

public struct IDNamePair: Decodable {
    public let id: Int
    public let name: String
    
    public init(id: Int, name: String) {
        self.id = id
        self.name = name
    }
    
    public init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        id = try container.decode(Int.self)
        name = try container.decode(String.self)
    }
}
