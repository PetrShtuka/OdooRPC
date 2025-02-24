import Foundation

public class MessagesServer {
    private var rpcClient: RPCClient
    
    // Initializer for MessagesServer, takes an RPCClient instance
    init(rpcClient: RPCClient) {
        self.rpcClient = rpcClient
    }
    
    // Method to fetch messages based on the provided request
    public func fetchMessages(request: MessageFetchRequest, completion: @escaping (Result<[MessageModel], Error>) -> Void) {
        let endpoint = "/web/dataset/search_read"
        let params = buildParams(for: request)
        
        // Send the RPC request to fetch messages
        rpcClient.sendRPCRequest(endpoint: endpoint, method: .post, params: params) { result in
            switch result {
            case .success(let data):
                do {
                    let jsonResponse = try JSONSerialization.jsonObject(with: data, options: [])
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
                            let responseWithoutLength = try decoder.decode(OdooResponse<MessageResponseDataWithoutLength>.self, from: data)
                            completion(.success(responseWithoutLength.result.records))
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
    
    // Method to search for messages, effectively calls fetchMessages
    public func searchMessages(request: MessageFetchRequest, completion: @escaping (Result<[MessageModel], Error>) -> Void) {
        fetchMessages(request: request, completion: completion)
    }
    
    // Method to fetch available modules
    public func fetchModules(completion: @escaping (Result<[ModelOdoo], Error>) -> Void) {
        let endpoint = "/web/session/modules"
        let params: [String: Any] = [:]
        
        // Send the RPC request to fetch modules
        rpcClient.sendRPCRequest(endpoint: endpoint, method: .post, params: params) { result in
            switch result {
            case .success(let data):
                do {
                    _ = try JSONSerialization.jsonObject(with: data, options: [])
                    
                    if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                       let moduleNames = jsonResponse["result"] as? [String] {
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
    
    // Method to delete messages by their IDs
    public func deleteMessages(messageIDs: [Int], type: MailboxOperation, completion: @escaping (Result<Bool, Error>) -> Void) {
        let endpoint = "/web/dataset/call_kw"
        let method = type == .bin ? "undelete" : "unlink_pro"
        let params: [String: Any] = [
            "model": "mail.message",
            "method": method,
            "args": [messageIDs],
            "kwargs": ["context": [Any]()]
        ]
        
        // Send the RPC request to delete messages by IDs
        rpcClient.sendRPCRequest(endpoint: endpoint, method: .post, params: params) { result in
            switch result {
            case .success(let data):
                do {
                    let jsonResponse = try JSONSerialization.jsonObject(with: data, options: [])
                    
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
    
    // Method to archive messages by their IDs
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
    
    // Method to mark messages as read by their IDs
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
    
    // Method to fetch existing message IDs based on local message IDs
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
    
    private func buildParams(for request: MessageFetchRequest) -> [String: Any] {
        let domain = createDomain(for: request)
        let fields = request.selectedFields.map { $0.rawValue }.filter { $0 != "is_error" }
        
        var context: [String: Any] = [
            "lang": request.language,
            "tz": request.timeZone,
            "uid": request.uid
//            "check_messages_access": true
        ]
        
        // Add "active_test": 0 to context if the inbox type is archive or bin
        if request.inboxType == .archive || request.inboxType == .bin {
            context["active_test"] = 0
        }
        
        return [
            "model": "mail.message",
            "domain": domain,
            "fields": fields,
            "limit": request.limit,
            "sort": "id DESC",
            "context": context
        ]
    }
    
    private func createDomain(for request: MessageFetchRequest) -> [[Any]] {
        var domain: [[Any]] = request.operation.domain(for: request.uid)
        
        if !request.comparisonOperator.isEmpty && request.messageId != 0 {
            domain.append(["id", request.comparisonOperator, request.messageId])
        }
        
        domain.append(["message_type",
                       "in",
                       ["email", "comment"]])
        
        domain.append(["message_type", "!=", "notification"])
        
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
}
