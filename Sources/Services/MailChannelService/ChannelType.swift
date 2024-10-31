//
//  ChannelType.swift
//  OdooRPC
//
//  Created by Peter on 31.10.2024.
//


public enum ChannelType: String, Codable {
    case chat = "chat"
    case channel = "channel"
    case group = "group"
    case livechat = "livechat"
}