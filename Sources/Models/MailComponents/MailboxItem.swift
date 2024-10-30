//
//  MailboxItem.swift
//  Oodo Messenger
//
//  Created by Peter on 04.10.2024.
//

import Foundation

public enum MailboxItem: String, CaseIterable {
    case messages = "Messages"
    case bin = "Bin"
    case archive = "Archive"
    case attachments = "Attachments"

    var section: MailboxSection {
        switch self {
        case .messages, .bin, .archive:
            return .messages
        case .attachments:
            return .other
        }
    }

    public var iconName: String {
        switch self {
        case .messages:
            return "envelope"
        case .bin:
            return "trash"
        case .archive:
            return "archivebox"
        case .attachments:
            return "paperclip"
        }
    }
}
