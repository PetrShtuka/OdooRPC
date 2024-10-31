//
//  MailChannelMemberModel.swift
//  OdooRPC
//
//  Created by Peter on 31.10.2024.
//


public struct MailChannelMemberModel: Codable {
    let last_interest_dt: String?
    let partner_id: Int?
    let guest_id: Int?
    let custom_channel_name: String?
    let message_unread_counter: Int?
    let fetched_message_id: Int?
    let seen_message_id: Int?
    let last_seen_dt: String?
}