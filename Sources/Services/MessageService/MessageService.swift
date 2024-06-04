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
                    print("JSON Response: \(jsonResponse)")

                    if let jsonResponse = jsonResponse as? [String: Any], let errorData = jsonResponse["error"] as? [String: Any] {
                        let errorMessage = errorData["message"] as? String ?? "Unknown error"
                        let errorCode = errorData["code"] as? Int ?? -1
                        let error = NSError(domain: "OdooServerError", code: errorCode, userInfo: [NSLocalizedDescriptionKey: errorMessage])
                        completion(.failure(error))
                    } else {
                        let decoder = JSONDecoder()
                        do {
                            let response = try decoder.decode(OdooResponse<MessageResponseDataWithLength>.self, from: data)
                            completion(.success(response.result.records))
                        } catch {
                            let response = try decoder.decode(OdooResponse<MessageResponseDataWithoutLength>.self, from: data)
                            completion(.success(response.result.records))
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
    
    public func fetchModules(completion: @escaping (Result<[ModelOdoo], Error>) -> Void) {
        let endpoint = "/web/session/modules"
        let params: [String: Any] = [:]
        
        rpcClient.sendRPCRequest(endpoint: endpoint, method: .post, params: params) { result in
            switch result {
            case .success(let data):
                do {
                    let jsonResponse = try JSONSerialization.jsonObject(with: data, options: [])
                    print("JSON Response: \(jsonResponse)")
                    
                    if let moduleNames = jsonResponse as? [String] {
                        // Создаем модели для каждого имени модуля
                        let modules = moduleNames.map { ModelOdoo(name: $0) }
                        completion(.success(modules))
                    } else {
                        completion(.failure(NSError(domain: "InvalidResponse", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid response from server"])))
                    }
                } catch {
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    public func deleteMessages(messageIDs: [Int], type: MailboxOperation, completion: @escaping (Result<Bool, Error>) -> Void) {
           let endpoint = "/web/dataset/call_kw"
           let method = type == .bin ? "undelete" : "unlink_pro"
           let params: [String: Any] = [
               "model": "mail.message",
               "method": method,
               "args": [messageIDs],
               "kwargs": ["context": [Any]()]
           ]

           rpcClient.sendRPCRequest(endpoint: endpoint, method: .post, params: params) { result in
               switch result {
               case .success(let data):
                   do {
                       let jsonResponse = try JSONSerialization.jsonObject(with: data, options: [])
                       print("JSON Response: \(jsonResponse)")

                       if let jsonResponse = jsonResponse as? [String: Any], let errorData = jsonResponse["error"] as? [String: Any] {
                           let errorMessage = errorData["message"] as? String ?? "Unknown error"
                           let errorCode = errorData["code"] as? Int ?? -1
                           let error = NSError(domain: "OdooServerError", code: errorCode, userInfo: [NSLocalizedDescriptionKey: errorMessage])
                           completion(.failure(error))
                       } else {
                           completion(.success(true))
                       }
                   } catch {
                       completion(.failure(error))
                   }
               case .failure(let error):
                   completion(.failure(error))
               }
           }
       }
    
    public func archiveMessages(messageIDs: [Int], type: MailboxOperation, completion: @escaping (Result<Bool, Error>) -> Void) {
           let endpoint = "/web/dataset/call_kw"
           let params: [String: Any] = [
               "model": "mail.message",
               "method": "archive",
               "args": [messageIDs],
               "kwargs": ["context": [Any]()]
           ]

           rpcClient.sendRPCRequest(endpoint: endpoint, method: .post, params: params) { result in
               switch result {
               case .success(let data):
                   do {
                       let jsonResponse = try JSONSerialization.jsonObject(with: data, options: [])
                       print("JSON Response: \(jsonResponse)")

                       if let jsonResponse = jsonResponse as? [String: Any], let errorData = jsonResponse["error"] as? [String: Any] {
                           let errorMessage = errorData["message"] as? String ?? "Unknown error"
                           let errorCode = errorData["code"] as? Int ?? -1
                           let error = NSError(domain: "OdooServerError", code: errorCode, userInfo: [NSLocalizedDescriptionKey: errorMessage])
                           completion(.failure(error))
                       } else {
                           completion(.success(true))
                       }
                   } catch {
                       completion(.failure(error))
                   }
               case .failure(let error):
                   completion(.failure(error))
               }
           }
       }
    
    public func markReadMessages(messageIDs: [Int], type: MailboxOperation, completion: @escaping (Result<Bool, Error>) -> Void) {
           let endpoint = "/web/dataset/call_kw"
           let params: [String: Any] = [
               "model": "mail.message",
               "method": "mark_read_multi",
               "args": [messageIDs],
               "kwargs": ["context": [Any]()]
           ]

           rpcClient.sendRPCRequest(endpoint: endpoint, method: .post, params: params) { result in
               switch result {
               case .success(let data):
                   do {
                       let jsonResponse = try JSONSerialization.jsonObject(with: data, options: [])
                       print("JSON Response: \(jsonResponse)")

                       if let jsonResponse = jsonResponse as? [String: Any], let errorData = jsonResponse["error"] as? [String: Any] {
                           let errorMessage = errorData["message"] as? String ?? "Unknown error"
                           let errorCode = errorData["code"] as? Int ?? -1
                           let error = NSError(domain: "OdooServerError", code: errorCode, userInfo: [NSLocalizedDescriptionKey: errorMessage])
                           completion(.failure(error))
                       } else {
                           completion(.success(true))
                       }
                   } catch {
                       completion(.failure(error))
                   }
               case .failure(let error):
                   completion(.failure(error))
               }
           }
       }

    public func fetchExistingMessageIDs(localMessagesID: [Int], completion: @escaping (Result<[Int], Error>) -> Void) {
        let endpoint = "/web/dataset/search_read"
        let params: [String: Any] = [
            "model": "mail.message",
            "domain": [["id", "in", localMessagesID]],
            "fields": ["id"]
        ]

        rpcClient.sendRPCRequest(endpoint: endpoint, method: .post, params: params) { result in
            switch result {
            case .success(let data):
                do {
                    let jsonResponse = try JSONSerialization.jsonObject(with: data, options: [])
                    print("JSON Response: \(jsonResponse)")

                    if let jsonResponse = jsonResponse as? [String: Any], let errorData = jsonResponse["error"] as? [String: Any] {
                        let errorMessage = errorData["message"] as? String ?? "Unknown error"
                        let errorCode = errorData["code"] as? Int ?? -1
                        let error = NSError(domain: "OdooServerError", code: errorCode, userInfo: [NSLocalizedDescriptionKey: errorMessage])
                        completion(.failure(error))
                    } else if let jsonResponse = jsonResponse as? [String: Any],
                              let result = jsonResponse["result"] as? [String: Any],
                              let records = result["records"] as? [[String: Any]] {
                        let ids = records.compactMap { $0["id"] as? Int }
                        completion(.success(ids))
                    } else {
                        completion(.failure(NSError(domain: "InvalidResponse", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid response from server"])))
                    }
                } catch {
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
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
    var domain: [[Any]] = []
    
    let messageType: [Any] = ["message_type", "in", ["email", "comment"]]
    let idNotInLocalIds: [Any] = ["id", "not in", request.localMessagesID ?? []]
    
    domain.append(messageType)
    domain.append(idNotInLocalIds)
    
    if let isActive = request.isActive {
        domain.append(["active", "=", isActive])
    }
    
    if let isNotDeleted = request.isNotDeleted {
        domain.append(["delete_uid", "!=", isNotDeleted])
    }
    
    if let requestText = request.requestText, !requestText.isEmpty {
        switch request.selectFilter {
        case .subject:
            domain.append(["subject", "ilike", requestText])
        case .content:
            domain.append(["body", "ilike", requestText])
        case .author:
            domain.append(["author_id", "ilike", requestText])
        case .recipients:
            domain.append(["partner_ids", "ilike", requestText])
        case .none:
            break
        }
    }
    
    return domain
}

public enum MailboxOperation: String {
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
    case subtypeID = "subtype_id"
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
    public var selectFilter: FilterTypeMessage = .none
    public var isActive: Bool?
    public var isNotDeleted: Bool?
    
    public init(operation: MailboxOperation, messageId: Int, limit: Int, comparisonOperator: String, partnerUserId: Int? = nil, requestText: String? = nil, localMessagesID: [Int]? = nil, selectedFields: Set<MessageField>, language: String, timeZone: String, uid: Int, selectFilter: FilterTypeMessage = .none, isActive: Bool? = nil, isNotDeleted: Bool? = nil) {
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
        self.selectFilter = selectFilter
        self.isActive = isActive
        self.isNotDeleted = isNotDeleted
    }
}

// Models for decoding the response
public struct OdooResponse<T: Decodable>: Decodable {
    let jsonrpc: String
    let id: Int
    let result: T
}

public struct MessageResponseDataWithoutLength: Decodable {
    let records: [MessageModel]
}

public struct MessageResponseDataWithLength: Decodable {
    let length: Int
    let records: [MessageModel]
}

public enum FilterTypeMessage {
    case subject, content, author, recipients, none
}
