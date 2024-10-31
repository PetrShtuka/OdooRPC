//
//  MailChannelMessageAction.swift
//  OdooRPC
//
//  Created by Peter on 31.10.2024.
//


enum MailChannelMessageAction {
    case fetchChannelMessages(channelID: Int, limit: Int)
    case fetchChannelNewMessages(channelID: Int, limit: Int, messagesID: Int, comparisonOperator: String, userPartnerID: Int, isChat: Bool)
    case fetchCheckOutMessages(channelID: Int, messagesIDs: [Int])
}
