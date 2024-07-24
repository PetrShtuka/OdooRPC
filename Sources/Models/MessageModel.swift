//
//  MessageModel.swift
//  OdooRPC
//
//  Created by Peter on 13.04.2024.
//

import Foundation

public struct IDNamePair: Decodable {
    public let id: Int
    public var name: String

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

public struct MessageModel: Decodable, Equatable {
    public var id: Int
    public var authorDisplay: String
    public var authorID: IDNamePair?
    public var date: String
    public var resID: Int
    public var needaction: Bool
    public var active: Bool
    public var subject: String?
    public var partnerIDs: [Int]
    public var parentID: IDNamePair?
    public var body: String
    public var recordName: String?
    public var emailFrom: String
    public var displayName: String
    public var deleteUID: Bool
    public var model: String
    public var authorAvatar: String?
    public var starred: Bool
    public var attachmentIDs: [Int]
    public var refPartnerIDs: [Int]
    public var subtypeID: (Int, String)?
    public var isAuthorIDBool: Bool
    public var truncatedBody: String

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
        self.truncatedBody = MessageModel.truncateText(MessageModel.removeHTMLTags(from: body), maxLength: 100)
    }

    public static func == (lhs: MessageModel, rhs: MessageModel) -> Bool {
        return lhs.id == rhs.id
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        authorDisplay = try container.decode(String.self, forKey: .authorDisplay)
        date = try container.decode(String.self, forKey: .date)
        resID = try container.decode(Int.self, forKey: .resID)
        needaction = try container.decode(Bool.self, forKey: .needaction)
        active = try container.decode(Bool.self, forKey: .active)
        
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
        
        // Handle recordName as String or Bool
        do {
            recordName = try container.decodeIfPresent(String.self, forKey: .recordName)
        } catch DecodingError.typeMismatch {
            _ = try container.decodeIfPresent(Bool.self, forKey: .recordName)
            recordName = nil
        }
        
        emailFrom = try container.decode(String.self, forKey: .emailFrom)
        displayName = try container.decode(String.self, forKey: .displayName)
        model = try container.decode(String.self, forKey: .model)
        
        // Handle authorAvatar as String or Bool
        do {
            authorAvatar = try container.decodeIfPresent(String.self, forKey: .authorAvatar)
        } catch DecodingError.typeMismatch {
            _ = try container.decodeIfPresent(Bool.self, forKey: .authorAvatar)
            authorAvatar = nil
        }
        
        starred = try container.decode(Bool.self, forKey: .starred)
        attachmentIDs = try container.decodeIfPresent([Int].self, forKey: .attachmentIDs) ?? []
        refPartnerIDs = try container.decodeIfPresent([Int].self, forKey: .refPartnerIDs) ?? []

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

        do {
            authorID = try container.decode(IDNamePair.self, forKey: .authorID)
            isAuthorIDBool = false
        } catch DecodingError.typeMismatch {
            isAuthorIDBool = (try container.decodeIfPresent(Bool.self, forKey: .authorID)) ?? false
            authorID = nil
        }

        do {
            deleteUID = try container.decode(Bool.self, forKey: .deleteUID)
        } catch DecodingError.typeMismatch {
            if let array = try? container.decode([AnyDecodable].self, forKey: .deleteUID) {
                // If it's an array, consider the message as deleted
                deleteUID = true
            } else {
                deleteUID = false
            }
        }

        self.truncatedBody = MessageModel.truncateText(MessageModel.removeHTMLTags(from: body), maxLength: 100)
    }

    // Метод для удаления HTML-тегов
    private static func removeHTMLTags(from htmlString: String) -> String {
        let regex = try! NSRegularExpression(pattern: "<.*?>", options: [])
        let range = NSRange(location: 0, length: htmlString.utf16.count)
        return regex.stringByReplacingMatches(in: htmlString, options: [], range: range, withTemplate: "")
    }

    // Метод для обрезки текста до указанного количества символов
    private static func truncateText(_ text: String, maxLength: Int) -> String {
        if text.count <= maxLength {
            return text
        }
        let endIndex = text.index(text.startIndex, offsetBy: maxLength)
        return String(text[..<endIndex]) + "..."
    }
}
