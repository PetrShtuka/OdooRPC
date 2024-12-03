//
//  MailChannelService.swift
//  OdooRPC
//
//  Created by Peter on 30.10.2024.
//

import Foundation

public class MailChannelService {
    private var rpcClient: RPCClient
    
    // Initializer for MailChannelService, takes an RPCClient instance
    init(rpcClient: RPCClient) {
        self.rpcClient = rpcClient
    }
    
    // Method to fetch mail channels
    public func fetchChannels(limit: Int, language: String, timezone: String, uid: Int, completion: @escaping (Result<[MailChannelModel], Error>) -> Void) {
        let endpoint = "/web/dataset/search_read"
        let params: [String: Any] = [
            "model": "mail.channel",
            "fields": [
                "id", "write_date", "name", "description", "channel_type", "avatar_128", "channel_member_ids", "is_member"
            ],
            "domain": [["is_member", "!=", false]],
            "limit": limit,
            "sort": "id DESC",
            "context": [
                "lang": language as Any,
                "tz":  timezone as Any,
                "uid": uid as Any
            ]
        ]
        
        // Send the RPC request to fetch channels
        rpcClient.sendRPCRequest(endpoint: endpoint, method: .post, params: params) { result in
            switch result {
            case .success(let data):
                do {
                    let decoder = JSONDecoder()
                    let response = try decoder.decode(OdooResponse<MailChannelResponseData>.self, from: data)
                    completion(.success(response.result.records))
                } catch {
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // Method to fetch channel members
    public func fetchChannelMembers(forChannelID channelID: Int, language: String, timezone: String, uid: Int, completion: @escaping (Result<[MailChannelMemberModel], Error>) -> Void) {
        let endpoint = "/web/dataset/search_read"
        let params: [String: Any] = [
            "model": "mail.channel.member",
            "fields": [
                "channel_id", "last_interest_dt", "partner_id", "guest_id", "custom_channel_name", "message_unread_counter", "fetched_message_id", "seen_message_id", "last_seen_dt"
            ],
            "domain": [["channel_id", "=", channelID]],
            "sort": "last_interest_dt DESC",
            "context": [
                "lang": language as Any,
                "tz": timezone as Any,
                "uid": uid as Any
            ]
        ]
        
        rpcClient.sendRPCRequest(endpoint: endpoint, method: .post, params: params) { result in
            switch result {
            case .success(let data):
                do {
                    let decoder = JSONDecoder()
                    let response = try decoder.decode(OdooResponse<MailChannelMemberResponseData>.self, from: data)
                    completion(.success(response.result.records))
                } catch {
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    public func fetchGuests(language: String, timezone: String, uid: Int, completion: @escaping (Result<[MailGuestModel], Error>) -> Void) {
        let endpoint = "/web/dataset/search_read"
        let params: [String: Any] = [
            "model": "mail.guest",
            "fields": [
                "channel_ids", "name"
            ],
            "context": [
                "lang": language as Any,
                "tz": timezone as Any,
                "uid": uid as Any
            ]
        ]
        
        rpcClient.sendRPCRequest(endpoint: endpoint, method: .post, params: params) { result in
            switch result {
            case .success(let data):
                do {
                    let decoder = JSONDecoder()
                    let response = try decoder.decode(OdooResponse<MailGuestResponseData>.self, from: data)
                    completion(.success(response.result.records))
                } catch {
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // Method to load chats by channel ID
    public func loadChatsById(idChat: Int, comparison: String, language: String, timezone: String, uid: Int, completion: @escaping (Result<[MailChannelModel], Error>) -> Void) {
        let endpoint = "/web/dataset/search_read"
        let params: [String: Any] = [
            "model": "mail.channel",
            "fields": [
                "id", "write_date", "name", "description", "channel_type", "avatar_128", "channel_member_ids", "is_member"
            ],
            "domain": [["is_member", "!=", false], ["id", comparison, idChat]],
            "limit": 30,
            "sort": "id DESC",
            "context": [
                "lang": language as Any,
                "tz":  timezone as Any,
                "uid": uid as Any
            ]
        ]
        
        // Send the RPC request to load chats by channel ID
        rpcClient.sendRPCRequest(endpoint: endpoint, method: .post, params: params) { result in
            switch result {
            case .success(let data):
                do {
                    let decoder = JSONDecoder()
                    let response = try decoder.decode(OdooResponse<MailChannelResponseData>.self, from: data)
                    completion(.success(response.result.records))
                } catch {
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
