//
//  MessageField.swift
//  OdooRPC
//
//  Created by Peter on 28.10.2024.
//

public enum MessageField: String, CaseIterable {
    case deleteUID = "delete_uid"
    case active
    case authorAvatar = "author_avatar"
    case model
    case resID = "res_id"
    case needaction
    case starred
    case date
    case authorID = "author_id"
    case emailFrom = "email_from"
    case partnerIDs = "partner_ids"
    case recordName = "record_name"
    case body
    case parentID = "parent_id"
    case displayName = "display_name"
    case id
    case subject
    case authorDisplay = "author_display"
    case subtypeID = "subtype_id"
    case attachmentIDs = "attachment_ids"
}
