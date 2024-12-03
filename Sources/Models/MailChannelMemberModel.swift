//
//  MailChannelMemberModel.swift
//  OdooRPC
//
//  Created by Peter on 31.10.2024.
//

import Foundation

public struct MailChannelMemberModel: Codable {
    let channelId: Int?
    let lastInterestDate: Date?
    let partnerId: Int?
    let guestId: Int?
    let customChannelName: String?
    let messageUnreadCounter: Int?
    let fetchedMessageId: Int?
    let seenMessageId: Int?
    let lastSeenDate: Date?
    
    // Свойственные ключи для маппинга JSON
    enum CodingKeys: String, CodingKey {
        case channelId = "channel_id"
        case lastInterestDate = "last_interest_dt"
        case partnerId = "partner_id"
        case guestId = "guest_id"
        case customChannelName = "custom_channel_name"
        case messageUnreadCounter = "message_unread_counter"
        case fetchedMessageId = "fetched_message_id"
        case seenMessageId = "seen_message_id"
        case lastSeenDate = "last_seen_dt"
    }
    
    // Инициализация из Decoder
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        channelId = try container.decodeIfPresent(Int.self, forKey: .channelId)
        
        if let lastInterestDtString = try container.decodeIfPresent(String.self, forKey: .lastInterestDate) {
            lastInterestDate = dateFormatter.date(from: lastInterestDtString)
        } else {
            lastInterestDate = nil
        }
        
        if let lastSeenDtString = try container.decodeIfPresent(String.self, forKey: .lastSeenDate) {
            lastSeenDate = dateFormatter.date(from: lastSeenDtString)
        } else {
            lastSeenDate = nil
        }
        
        partnerId = try container.decodeIfPresent(Int.self, forKey: .partnerId)
        guestId = try container.decodeIfPresent(Int.self, forKey: .guestId)
        customChannelName = try container.decodeIfPresent(String.self, forKey: .customChannelName)
        messageUnreadCounter = try container.decodeIfPresent(Int.self, forKey: .messageUnreadCounter)
        fetchedMessageId = try container.decodeIfPresent(Int.self, forKey: .fetchedMessageId)
        seenMessageId = try container.decodeIfPresent(Int.self, forKey: .seenMessageId)
    }
    
    // Инициализация вручную, если потребуется
    public init(channelId: Int?, lastInterestDate: Date?, partnerId: Int?, guestId: Int?, customChannelName: String?, messageUnreadCounter: Int?, fetchedMessageId: Int?, seenMessageId: Int?, lastSeenDate: Date?) {
        self.channelId = channelId
        self.lastInterestDate = lastInterestDate
        self.partnerId = partnerId
        self.guestId = guestId
        self.customChannelName = customChannelName
        self.messageUnreadCounter = messageUnreadCounter
        self.fetchedMessageId = fetchedMessageId
        self.seenMessageId = seenMessageId
        self.lastSeenDate = lastSeenDate
    }
}
