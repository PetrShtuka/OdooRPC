//
//  MessageModel.swift
//  OdooRPC
//
//  Created by Peter on 13.04.2024.
//

import Foundation

public struct MessageResponse: Decodable {
    let records: [MessageModel]
}

public struct MessageModel: Decodable {
    public let authorDisplay: String
    public let needaction: Bool
    public let active: Bool
    public let parentID: ParentID?
    public let subject: String?
    public let emailFrom: String
    public let authorID: [AuthorID]
    public let id: Int
    public let date: String
    public let deleteUID: Bool
    public let authorAvatar: String?
    public let starred: Bool
    public let body: String
    public let attachmentIDs: [Int]
    public let model: String
    public let partnerIDs: [Int]
    public let refPartnerIDs: [Int]
    public let displayName: String
    public let subtypeID: [Int?]
    public let recordName: String
    public let resID: Int

    enum CodingKeys: String, CodingKey {
        case authorDisplay = "author_display"
        case needaction
        case active
        case parentID = "parent_id"
        case subject
        case emailFrom = "email_from"
        case authorID = "author_id"
        case id
        case date
        case deleteUID = "delete_uid"
        case authorAvatar = "author_avatar"
        case starred
        case body
        case attachmentIDs = "attachment_ids"
        case model
        case partnerIDs = "partner_ids"
        case refPartnerIDs = "ref_partner_ids"
        case displayName = "display_name"
        case subtypeID = "subtype_id"
        case recordName = "record_name"
        case resID = "res_id"
    }
}

public struct ParentID: Decodable {
    public let id: Int?
    public let name: String?

    enum CodingKeys: String, CodingKey {
        case id
        case name
    }
}

public struct AuthorID: Decodable {
    public let id: Int
    public let name: String

    enum CodingKeys: String, CodingKey {
        case id
        case name
    }
}
