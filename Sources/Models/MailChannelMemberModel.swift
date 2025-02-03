//
//  MailChannelMemberModel.swift
//  OdooRPC
//
//  Created by Peter on 31.10.2024.
//

import Foundation

public struct MailChannelMemberModel: Codable {
    public let channelId: Int?
    public let partnerId: Int?
    public let guestId: Int?
    public let customChannelName: String?
    public let messageUnreadCounter: Int?
    public let fetchedMessageId: Int?
    public let seenMessageId: Int?
    public let lastInterestDate: Date?
    public let lastSeenDate: Date?

    // Ключи для маппинга JSON
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
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        channelId = try container.decodeIfPresent(Int.self, forKey: .channelId)
        partnerId = try container.decodeIfPresent(Int.self, forKey: .partnerId)
        guestId = try container.decodeIfPresent(Int.self, forKey: .guestId)
        customChannelName = try container.decodeIfPresent(String.self, forKey: .customChannelName)
        messageUnreadCounter = try container.decodeIfPresent(Int.self, forKey: .messageUnreadCounter)
        fetchedMessageId = try container.decodeIfPresent(Int.self, forKey: .fetchedMessageId)
        seenMessageId = try container.decodeIfPresent(Int.self, forKey: .seenMessageId)
        
        // Форматирование дат
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
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
    }
    
    // Ручная инициализация
    public init(channelId: Int?,
                lastInterestDate: Date?,
                partnerId: Int?,
                guestId: Int?,
                customChannelName: String?,
                messageUnreadCounter: Int?,
                fetchedMessageId: Int?,
                seenMessageId: Int?,
                lastSeenDate: Date?) {
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
