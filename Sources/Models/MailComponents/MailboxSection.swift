//
//  MailboxSection.swift
//  Oodo Messenger
//
//  Created by Peter on 04.10.2024.
//

import Foundation

public enum MailboxSection: Int, CaseIterable {
    case messages
    case other

    public var title: String {
        switch self {
        case .messages:
            return "Mailboxes"
        case .other:
            return "Other"
        }
    }
}
