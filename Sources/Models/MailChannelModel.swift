//
//  MailChannelModel.swift
//  OdooRPC
//
//  Created by Peter on 31.10.2024.
//

import Foundation

public struct MailChannelModel: Codable {
    public let id: Int?
    public var writeDate: Date?
    public var name: String?
    public var description: String?
    public let channelType: ChannelType?
    public var avatar128: String?
    public var channelMemberIds: [Int]?
    public var isMember: Bool?
    public var lastInterestDt: Date?
    public var partnerId: Int?
    public var questId: Int?
    public var customChannelName: String?
    public var messageUnreadCounter: Int?
    public var fetchedMessageId: Int?
    public var seenMessageId: Int?
    public var lastSeenDt: Date?
    public var messages: [ChatMessageModel]?
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case writeDate = "write_date"
        case name
        case description
        case channelType = "channel_type"
        case avatar128 = "avatar_128"
        case channelMemberIds = "channel_member_ids"
        case isMember = "is_member"
        case lastInterestDt = "last_interest_dt"
        case partnerId = "partner_id"
        case questId = "quest_id"
        case customChannelName = "custom_channel_name"
        case messageUnreadCounter = "message_unread_counter"
        case fetchedMessageId = "fetched_message_id"
        case seenMessageId = "seen_message_id"
        case lastSeenDt = "last_seen_dt"
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try? container.decode(Int.self, forKey: .id)
        writeDate = try? container.decode(Date.self, forKey: .writeDate)
        name = try? container.decode(String.self, forKey: .name)
        description = try? container.decode(String.self, forKey: .description)
        channelType = try? container.decode(ChannelType.self, forKey: .channelType)
        avatar128 = try? container.decode(String.self, forKey: .avatar128)
        channelMemberIds = try? container.decode([Int].self, forKey: .channelMemberIds)
        isMember = try? container.decode(Bool.self, forKey: .isMember)
        lastInterestDt = try? container.decode(Date.self, forKey: .lastInterestDt)
        partnerId = try? container.decode(Int.self, forKey: .partnerId)
        questId = try? container.decode(Int.self, forKey: .questId)
        customChannelName = try? container.decode(String.self, forKey: .customChannelName)
        messageUnreadCounter = try? container.decode(Int.self, forKey: .messageUnreadCounter)
        fetchedMessageId = try? container.decode(Int.self, forKey: .fetchedMessageId)
        seenMessageId = try? container.decode(Int.self, forKey: .seenMessageId)
        lastSeenDt = try? container.decode(Date.self, forKey: .lastSeenDt)
    }
    
    public init(id: Int?, writeDate: Date?, name: String?, description: String?, channelType: ChannelType?, avatar128: String?, channelMemberIds: [Int]?, isMember: Bool?, lastInterestDt: Date?, partnerId: Int?, questId: Int?, customChannelName: String?, messageUnreadCounter: Int?, fetchedMessageId: Int?, seenMessageId: Int?, lastSeenDt: Date?, messages: [ChatMessageModel]?) {
        self.id = id
        self.writeDate = writeDate
        self.name = name
        self.description = description
        self.channelType = channelType
        self.avatar128 = avatar128
        self.channelMemberIds = channelMemberIds
        self.isMember = isMember
        self.lastInterestDt = lastInterestDt
        self.partnerId = partnerId
        self.questId = questId
        self.customChannelName = customChannelName
        self.messageUnreadCounter = messageUnreadCounter
        self.fetchedMessageId = fetchedMessageId
        self.seenMessageId = seenMessageId
        self.lastSeenDt = lastSeenDt
        self.messages = messages
    }
}
