//
//  MessageModel.swift
//  OdooRPC
//
//  Created by Peter on 13.04.2024.
//

import Foundation

public struct MessageModel: Decodable, Hashable {
    let messageId: Int
    let authorId: Int
    let authorName: String
    let partnerIds: [Int]
    let subject: String
    let body: String
    let needaction: Bool
    let starred: Bool
    let authorDisplay: String
    let models: String
    let recordName: String
    let active: Bool
    let displayName: String
    let time: String
    let previewBody: String
    let avatarData: String? // Handle as String URL or base64 string
    let categories: String
    let resId: Int
    let isRead: Bool
    let isError: Bool
    let parentId: Int?
    let mailMailIds: [Int]
    let userId: Int
    let attachmentsId: [Int]
    let deleteUid: Bool
    let subtypeIDs: [Int: String]
    
    enum CodingKeys: String, CodingKey {
        case messageId = "id"
        case authorId = "author_id"
        case authorName
        case partnerIds = "partner_ids"
        case subject
        case body
        case needaction
        case starred
        case authorDisplay = "author_display"
        case models = "model"
        case recordName = "record_name"
        case active
        case displayName = "display_name"
        case time = "date"
        case previewBody
        case avatarData = "avatar"
        case categories
        case resId = "res_id"
        case isRead = "is_read"
        case isError = "is_error"
        case parentId = "parent_id"
        case mailMailIds = "mail_mail_ids"
        case userId
        case attachmentsId = "attachment_ids"
        case deleteUid = "delete_uid"
        case subtypeIDs = "subtype_id"
    }
}
