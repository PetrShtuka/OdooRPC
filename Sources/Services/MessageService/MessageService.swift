//
//  MessagesModule.swift
//  OdooRPC
//
//  Created by Peter on 13.04.2024.
//

import Foundation

public class MessagesServer {
    private var rpcClient: RPCClient
    
    init(rpcClient: RPCClient) {
        self.rpcClient = rpcClient
    }
    
    public func fetchMessages(request: MessageFetchRequest, completion: @escaping (Result<[MessageModel], Error>) -> Void) {
        let endpoint = "/web/dataset/search_read"
        let params = buildParams(for: request)
        
        rpcClient.sendRPCRequest(endpoint: endpoint, method: .post, params: params) { result in
            switch result {
            case .success(let data):
                do {
                    let decoder = JSONDecoder()
                    let messageResponse = try decoder.decode(MessageResponse.self, from: data)
                    completion(.success(messageResponse.records))
                } catch {
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    private func buildParams(for request: MessageFetchRequest) -> [String: Any] {
        let domain = createDomain(for: request)
        let fields = request.selectedFields.map { $0.rawValue }
        
        return [
            "model": "mail.message",
            "domain": domain,
            "fields": fields,
            "limit": request.limit,
            "sort": "id DESC",
            "context": [
                "lang": request.language,
                "tz": request.timeZone,
                "uid": request.uid,
                "check_messages_access": true
            ]
        ]
    }
    
    private func createDomain(for request: MessageFetchRequest) -> [[Any]] {
        let domain: [[Any]] = [["message_type", "in", ["email", "comment"]]]
        // Include domain logic based on the request type
        return domain
    }
}

public enum MailboxOperation {
    case sharedInbox, search, archive, bin, outbox
}

public enum MessageField: String, CaseIterable {
    case deleteUID = "delete_uid"
    case active
    case authorAvatar = "author_avatar"
    case model
    case resID = "res_id"
    case needaction
    case starred
    case date
    case authorID = "author_id"
    case emailFrom = "email_from"
    case partnerIDs = "partner_ids"
    case recordName = "record_name"
    case body
    case parentID = "parent_id"
    case displayName = "display_name"
    case id
    case subject
    case authorDisplay = "author_display"
    case isError = "is_error"
    case mailMailIDInt = "mail_mail_id_int"
}

public struct MessageFetchRequest {
    var operation: MailboxOperation
    var messageId: Int
    var limit: Int
    var comparisonOperator: String = ">"
    var partnerUserId: Int?
    var requestText: String?
    var localMessagesID: [Int]?
    var selectedFields: Set<MessageField> = Set(MessageField.allCases)
    var language: String
    var timeZone: String
    var uid: Int
}
