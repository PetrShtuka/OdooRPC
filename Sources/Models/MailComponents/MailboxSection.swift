//
//  MailboxSection.swift
//  Oodo Messenger
//
//  Created by Peter on 04.10.2024.
//

import Foundation

enum MailboxSection: Int, CaseIterable {
    case messages
    case other

    var title: String {
        switch self {
        case .messages:
            return "Mailboxes"
        case .other:
            return "Other"
        }
    }
}
