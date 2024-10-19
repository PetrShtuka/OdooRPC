//
//  AttachmentService.swift
//
//
//  Created by Peter on 06.09.2024.
//

import Foundation

public class AttachmentService {
    
    private var rpcClient: RPCClient
    
    init(rpcClient: RPCClient) {
        self.rpcClient = rpcClient
    }
    
    public func fetchAttachment(request: AttachmentRequestType, userID: String, completion: @escaping (Result<[AttachmentModel], Error>) -> Void) {
        let endpoint: String
        let params: [String: Any]
        
        switch request {
        case let .fetch(idAttachment, includeDates):
            endpoint = "/web/dataset/call_kw"
            params = buildParams(for: AttachmentsRequest(attachmentId: idAttachment, isIncludeDates: includeDates, userID: userID))
            
        case let .fetchArray(idAttachment, includeDates):
            endpoint = "/web/dataset/call_kw"
            params = buildParams(for: AttachmentsListRequest(attachmentIds: idAttachment, isIncludeDates: includeDates, userID: userID))
        case let .uploadAttachment(attachment: attachment, message: message):
            endpoint = "/web/dataset/call_kw"
            params = buildParams(for: CreateAttachmentRequest(filename: attachment.filename, fileData: attachment.data, model: message.models, resId: message.resId))
        case let .uploadAttachmentChat(attachment: attachment, message: message):
            endpoint = "/web/dataset/call_kw"
            params = buildParams(for: CreateAttachmentRequest(filename: attachment.filename, fileData: attachment.data, model: message.model, resId: message.resId))
        }
        
        rpcClient.sendRPCRequest(endpoint: endpoint, method: .post, params: params) { result in
                switch result {
                case .success(let data):
                    do {
                        let jsonResponse = try JSONSerialization.jsonObject(with: data, options: [])
                        if let jsonResponseDict = jsonResponse as? [String: Any] {
                            // Если есть ошибки в ответе
                            if let errorData = jsonResponseDict["error"] as? [String: Any] {
                                let errorMessage = errorData["message"] as? String ?? "Unknown error"
                                let errorCode = errorData["code"] as? Int ?? -1
                                let error = NSError(domain: "OdooServerError", code: errorCode, userInfo: [NSLocalizedDescriptionKey: errorMessage])
                                completion(.failure(error))
                            }
                            // Парсинг поля "result", если он есть
                            else if let resultArray = jsonResponseDict["result"] as? [[String: Any]] {
                                let attachments = resultArray.compactMap { AttachmentModel.from(json: $0) }
                                completion(.success(attachments))
                            }
                            // Дополнительный парсинг по полям "jsonrpc" и "id"
                            else if let jsonrpc = jsonResponseDict["jsonrpc"] as? String,
                                    let id = jsonResponseDict["id"] as? Int,
                                    let resultValue = jsonResponseDict["result"] {
                                print("JSON-RPC Version: \(jsonrpc), Request ID: \(id), Result: \(resultValue)")
                                // Здесь вы можете добавить дополнительную обработку поля resultValue
                                completion(.success([]))  // Заглушка для примера
                            } else {
                                completion(.failure(NSError(domain: "InvalidResponse", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid response format"])))
                            }
                        } else {
                            completion(.failure(NSError(domain: "JSONError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid JSON format"])))
                        }
                    } catch {
                        completion(.failure(error))
                    }
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
        
    
    private func buildParams(for request: AttachmentsRequest) -> [String: Any] {
        return [
            "model": "ir.attachment",
            "method": "read",
            "args": [[request.attachmentId]],
            "kwargs": [
                "context": [
                    "lang": "en_US",
                    "tz": "Europe/Rome",
                    "uid": request.userID,
                    "allowed_company_ids": [1],
                    "bin_size": !request.isIncludeDates
                ]
            ]
        ]
    }
    
    private func buildParams(for request: AttachmentsListRequest) -> [String: Any] {
        return [
            "model": "ir.attachment",
            "method": "search_read",
            "args": [
                [["id", "in", request.attachmentIds]],
                request.isIncludeDates ? request.includeDates : request.excludeDates
            ],
            "kwargs": [
                "context": [
                    "bin_size": !request.isIncludeDates
                ]
            ]
        ]
    }
    
    private func buildParams(for request: CreateAttachmentRequest) -> [String: Any] {
        return [
            "model": "ir.attachment",
            "method": "create",
            "args": [
                [
                    "name": request.filename ?? "",
                    "datas": request.fileData ?? "",
                    "res_model": request.model ?? "",
                    "res_id": request.resId ?? 0
                ]
            ],
            "kwargs": [:]  // Добавляем пустой kwargs
        ]
    }
    
}

public enum AttachmentRequestType {
    case fetch(idAttachment: Int, includeDates: Bool)
    case fetchArray(idAttachment: [Int], includeDates: Bool)
    case uploadAttachment(attachment: AttachmentModel, message: MobileSentMessage)
    case uploadAttachmentChat(attachment: AttachmentModel, message: MessageConversation)
}

// Structs for requests
public struct AttachmentsRequest  {
    var attachmentId: Int?
    var isIncludeDates: Bool
    var userID: String
    var includeDates = ["datas"]
    var excludeDates = ["name", "mimetype", "res_name", "datas"]
}

public struct AttachmentsListRequest {
    var attachmentIds: [Int]
    var isIncludeDates: Bool
    var userID: String
    var includeDates = ["datas"]
    var excludeDates = ["name", "mimetype", "res_name", "datas"]
}

public struct CreateAttachmentRequest {
    var filename: String?
    var fileData: String?
    var model: String?
    var resId: Int?
}
