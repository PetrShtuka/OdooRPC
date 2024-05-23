//
//  MessagesModule.swift
//  OdooRPC
//
//  Created by Peter on 13.04.2024.
//

//
//  MessagesModule.swift
//  OdooRPC
//
//  Created by Peter on 13.04.2024.
//

//import Foundation
//
//public class MessagesServer {
//    private var rpcClient: RPCClient
//    
//    init(rpcClient: RPCClient) {
//        self.rpcClient = rpcClient
//    }
//    
//    public func fetchMessages(request: MessageFetchRequest, completion: @escaping (Result<[MessageModel], Error>) -> Void) {
//        let endpoint = "/web/dataset/search_read"
//        let params = buildParams(for: request)
//        
//        rpcClient.sendRPCRequest(endpoint: endpoint, method: .post, params: params) { result in
//            switch result {
//            case .success(let data):
//                do {
//                    let decoder = JSONDecoder()
//                    let response = try decoder.decode(OdooResponse<MessageResponse>.self, from: data)
//                    completion(.success(response.result.records))
//                } catch {
//                    completion(.failure(error))
//                }
//            case .failure(let error):
//                completion(.failure(error))
//            }
//        }
//    }
//    
//    private func buildParams(for request: MessageFetchRequest) -> [String: Any] {
//        let domain = createDomain(for: request)
//        let fields = request.selectedFields.map { $0.rawValue }
//        
//        return [
//            "model": "mail.message",
//            "domain": domain,
//            "fields": fields,
//            "limit": request.limit,
//            "sort": "id DESC",
//            "context": [
//                "lang": request.language,
//                "tz": request.timeZone,
//                "uid": request.uid,
//                "check_messages_access": true
//            ]
//        ]
//    }
//    
//    private func createDomain(for request: MessageFetchRequest) -> [[Any]] {
//        var domain: [[Any]] = [["message_type", "in", ["email", "comment"]]]
//        // Include domain logic based on the request type
//        return domain
//    }
//}
//
//public enum MailboxOperation {
//    case sharedInbox, search, archive, bin, outbox
//}
//
//public enum MessageField: String, CaseIterable {
//    case deleteUID = "delete_uid"
//    case active
//    case authorAvatar = "author_avatar"
//    case model
//    case resID = "res_id"
//    case needaction
//    case starred
//    case date
//    case authorID = "author_id"
//    case emailFrom = "email_from"
//    case partnerIDs = "partner_ids"
//    case recordName = "record_name"
//    case body
//    case parentID = "parent_id"
//    case displayName = "display_name"
//    case id
//    case subject
//    case authorDisplay = "author_display"
//}
//
//public struct MessageFetchRequest {
//    public var operation: MailboxOperation
//    public var messageId: Int
//    public var limit: Int
//    public var comparisonOperator: String = ">"
//    public var partnerUserId: Int?
//    public var requestText: String?
//    public var localMessagesID: [Int]?
//    public var selectedFields: Set<MessageField> = Set(MessageField.allCases)
//    public var language: String
//    public var timeZone: String
//    public var uid: Int
//    
//    public init(operation: MailboxOperation, messageId: Int, limit: Int, comparisonOperator: String, partnerUserId: Int? = nil, requestText: String? = nil, localMessagesID: [Int]? = nil, selectedFields: Set<MessageField>, language: String, timeZone: String, uid: Int) {
//        self.operation = operation
//        self.messageId = messageId
//        self.limit = limit
//        self.comparisonOperator = comparisonOperator
//        self.partnerUserId = partnerUserId
//        self.requestText = requestText
//        self.localMessagesID = localMessagesID
//        self.selectedFields = selectedFields
//        self.language = language
//        self.timeZone = timeZone
//        self.uid = uid
//    }
//}
//
//// Models for decoding the response
//public struct OdooResponse<T: Decodable>: Decodable {
//    let jsonrpc: String
//    let id: Int
//    let result: T
//}

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
                    let jsonResponse = try JSONSerialization.jsonObject(with: data, options: [])
                    
                    // Debug log for JSON response
                    print("JSON Response: \(jsonResponse)")
                    
                    if let jsonResponse = jsonResponse as? [String: Any], let errorData = jsonResponse["error"] as? [String: Any] {
                        // Handle the error structure
                        let errorMessage = errorData["message"] as? String ?? "Unknown error"
                        let errorCode = errorData["code"] as? Int ?? -1
                        let error = NSError(domain: "OdooServerError", code: errorCode, userInfo: [NSLocalizedDescriptionKey: errorMessage])
                        completion(.failure(error))
                    } else {
                        let decoder = JSONDecoder()
                        
                        // Decode the response with or without the length field
                        if let response = try? decoder.decode(OdooResponse.self, from: data) {
                            completion(.success(response.result.records))
                        } else {
                            completion(.failure(NSError(domain: "ParseError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Invalid JSON structure"])))
                        }
                    }
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
        let fields = request.selectedFields.map { $0.rawValue }.filter { $0 != "is_error" } // Исключаем недопустимое поле
        
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
        var domain: [[Any]] = [["message_type", "in", ["email", "comment"]]]
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
}

public struct MessageFetchRequest {
    public var operation: MailboxOperation
    public var messageId: Int
    public var limit: Int
    public var comparisonOperator: String = ">"
    public var partnerUserId: Int?
    public var requestText: String?
    public var localMessagesID: [Int]?
    public var selectedFields: Set<MessageField> = Set(MessageField.allCases)
    public var language: String
    public var timeZone: String
    public var uid: Int
    
    public init(operation: MailboxOperation, messageId: Int, limit: Int, comparisonOperator: String, partnerUserId: Int? = nil, requestText: String? = nil, localMessagesID: [Int]? = nil, selectedFields: Set<MessageField>, language: String, timeZone: String, uid: Int) {
        self.operation = operation
        self.messageId = messageId
        self.limit = limit
        self.comparisonOperator = comparisonOperator
        self.partnerUserId = partnerUserId
        self.requestText = requestText
        self.localMessagesID = localMessagesID
        self.selectedFields = selectedFields
        self.language = language
        self.timeZone = timeZone
        self.uid = uid
    }
}

public struct OdooResponse: Decodable {
    let jsonrpc: String
    let id: Int
    let result: MessageResponseData
}

public struct MessageResponseData: Decodable {
    let length: Int?
    let records: [MessageModel]
}
