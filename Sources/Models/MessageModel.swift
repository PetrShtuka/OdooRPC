//
//  MessageModel.swift
//  OdooRPC
//
//  Created by Peter on 13.04.2024.
//

import Foundation

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
    public var subtypeID: (Int, String)?
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

    public init(id: Int, authorDisplay: String, authorID: IDNamePair?, date: String, resID: Int, needaction: Bool, active: Bool, subject: String?, partnerIDs: [Int], parentID: IDNamePair?, body: String, recordName: String?, emailFrom: String, displayName: String, deleteUID: Bool, model: String, authorAvatar: String?, starred: Bool, attachmentIDs: [Int], refPartnerIDs: [Int], subtypeID: (Int, String)?, isAuthorIDBool: Bool) {
        self.id = id
        self.authorDisplay = authorDisplay
        self.authorID = authorID
        self.date = date
        self.resID = resID
        self.needaction = needaction
        self.active = active
        self.subject = subject
        self.partnerIDs = partnerIDs
        self.parentID = parentID
        self.body = body
        self.recordName = recordName
        self.emailFrom = emailFrom
        self.displayName = displayName
        self.deleteUID = deleteUID
        self.model = model
        self.authorAvatar = authorAvatar
        self.starred = starred
        self.attachmentIDs = attachmentIDs
        self.refPartnerIDs = refPartnerIDs
        self.subtypeID = subtypeID
        self.isAuthorIDBool = isAuthorIDBool
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        authorDisplay = try container.decode(String.self, forKey: .authorDisplay)
        date = try container.decode(String.self, forKey: .date)
        resID = try container.decode(Int.self, forKey: .resID)
        needaction = try container.decode(Bool.self, forKey: .needaction)
        active = try container.decode(Bool.self, forKey: .active)
        
        // Декодирование поля subject с обработкой типа Bool
        if let stringSubject = try? container.decode(String.self, forKey: .subject) {
            subject = stringSubject
        } else if let boolSubject = try? container.decode(Bool.self, forKey: .subject) {
            subject = boolSubject ? "true" : "false"
        } else {
            subject = nil
        }
        
        partnerIDs = try container.decode([Int].self, forKey: .partnerIDs)
        parentID = try? container.decode(IDNamePair.self, forKey: .parentID)
        body = try container.decode(String.self, forKey: .body)
        recordName = try container.decodeIfPresent(String.self, forKey: .recordName)
        emailFrom = try container.decode(String.self, forKey: .emailFrom)
        displayName = try container.decode(String.self, forKey: .displayName)
        deleteUID = try container.decode(Bool.self, forKey: .deleteUID)
        model = try container.decode(String.self, forKey: .model)
        authorAvatar = try container.decodeIfPresent(String.self, forKey: .authorAvatar)
        starred = try container.decode(Bool.self, forKey: .starred)
        attachmentIDs = try container.decodeIfPresent([Int].self, forKey: .attachmentIDs) ?? []
        refPartnerIDs = try container.decodeIfPresent([Int].self, forKey: .refPartnerIDs) ?? []

        // Декодирование subtypeID с учетом отсутствия или неправильного формата
        if var subtypeIDContainer = try? container.nestedUnkeyedContainer(forKey: .subtypeID) {
            let id = try? subtypeIDContainer.decode(Int.self)
            let name = try? subtypeIDContainer.decode(String.self)
            if let id = id, let name = name {
                subtypeID = (id, name)
            } else {
                subtypeID = nil
            }
        } else {
            subtypeID = nil
        }

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
