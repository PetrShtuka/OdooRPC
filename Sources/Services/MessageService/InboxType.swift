//
//  InboxType.swift
//  OdooRPC
//
//  Created by Peter on 28.10.2024.
//

public enum InboxType {
    case active
    case archive
    case bin
    case shared
    case sent(odooPartnerUserId: Int)

    var domain: [[Any]] {
        switch self {
        case .active:
            return [
                ["active", "=", false],
                ["delete_uid", "=", false]
            ]
        case .archive:
            return [
                ["active", "=", false],
                ["delete_uid", "=", false]
            ]
        case .bin:
            return [
                ["active", "=", false],
                ["delete_uid", "!=", false]
            ]
        case .shared:
            return [
                ["shared_inbox", "=", true]
            ]
        case .sent(let odooPartnerUserId):
            return [
                ["author_id", "=", odooPartnerUserId]
            ]
        }
    }
}
