//
//  MailChannelResponseData.swift
//  OdooRPC
//
//  Created by Peter on 31.10.2024.
//


struct MailChannelResponseData: Codable {
    let records: [MailChannelModel]
}

struct MailChannelMemberResponseData: Codable {
    let records: [MailChannelMemberModel]
}