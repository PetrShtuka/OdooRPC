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
    public func fetchChannels(limit: Int, user: UserData, completion: @escaping (Result<[MailChannelModel], Error>) -> Void) {
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
                "lang": user.language as Any,
                "tz": user.timezone as Any,
                "uid": user.uid as Any
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
    public func fetchChannelMembers(channelID: [Int], user: UserData, completion: @escaping (Result<[MailChannelMemberModel], Error>) -> Void) {
        let endpoint = "/web/dataset/search_read"
        let params: [String: Any] = [
            "model": "mail.channel.member",
            "fields": [
                "last_interest_dt", "partner_id", "guest_id", "custom_channel_name", "message_unread_counter", "fetched_message_id", "seen_message_id", "last_seen_dt"
            ],
            "domain": [["channel_id", "in", channelID]],
            "sort": "id DESC",
            "context": [
                "lang": user.language as Any,
                "tz": user.timezone as Any,
                "uid": user.uid as Any
            ]
        ]
        
        // Send the RPC request to fetch channel members
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
    
    // Method to load chats by channel ID
    public func loadChatsById(idChat: Int, comparison: String, user: UserData, completion: @escaping (Result<[MailChannelModel], Error>) -> Void) {
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
                "lang": user.language as Any,
                "tz": user.timezone as Any,
                "uid": user.uid as Any
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
