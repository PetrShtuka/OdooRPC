//
//  MailboxOperation.swift
//  OdooRPC
//
//  Created by Peter on 28.10.2024.
//

public enum MailboxOperation: Equatable {
    case sharedInbox
    case privateInbox
    case sent(odooPartnerUserId: Int)
    case archive
    case bin
    case allInboxes(userPartnerID: Int)

    func domain(for userID: Int) -> [[Any]] {
        switch self {
        case .sharedInbox:
            return [["shared_inbox", "=", true], ["active", "=", true], ["delete_uid", "=", false]]
        case .privateInbox:
            return [["partner_ids", "in", [userID]], ["active", "=", true], ["delete_uid", "=", false]]
        case .sent(let odooPartnerUserId):
            return [["author_id", "=", odooPartnerUserId], ["active", "=", true], ["delete_uid", "=", false]]
        case .archive:
            return [["active", "=", "false"], ["delete_uid", "=", "false"]]
        case .bin:
            return [["active", "=", "false"], ["delete_uid", "!=", "false"]]
        case .allInboxes(let userPartnerID):
            return [
                ["|", ["shared_inbox", "=", true], ["partner_ids", "in", [userPartnerID]]],
                ["active", "=", true],
                ["delete_uid", "=", false]
            ]
        }
        
    }

    public static func == (lhs: MailboxOperation, rhs: MailboxOperation) -> Bool {
        switch (lhs, rhs) {
        case (.sharedInbox, .sharedInbox),
             (.privateInbox, .privateInbox),
             (.archive, .archive),
             (.bin, .bin):
            return true
        case (.sent(let lhsUserId), .sent(let rhsUserId)):
            return lhsUserId == rhsUserId
        default:
            return false
        }
    }

}
