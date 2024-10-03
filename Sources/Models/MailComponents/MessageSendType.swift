//
//  MailboxSection.swift
//  Oodo Messenger
//
//  Created by Peter on 04.10.2024.
//

import Foundation

public enum MessageSendType {
    case email
    case odoo
    
    public var identifier: String {
        switch self {
        case .odoo:
            return "odoo"
        case .email:
            return "email"
        }
    }
}

