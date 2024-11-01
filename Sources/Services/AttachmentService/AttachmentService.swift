//
//  AttachmentService.swift
//
//
//  Created by Peter on 06.09.2024.
//

import Foundation

public class AttachmentService {
    private var rpcClient: RPCClient

    // Initializer that accepts an RPCClient instance
    init(rpcClient: RPCClient) {
        self.rpcClient = rpcClient
    }

    // Fetch attachment based on the request type and user ID
    public func fetchAttachment(request: AttachmentRequestType, userID: Int, completion: @escaping (Result<[AttachmentModel], Error>) -> Void) {
        let (endpoint, params) = getEndpointAndParams(for: request, userID: userID)

        // Send the RPC request
        rpcClient.sendRPCRequest(endpoint: endpoint, method: .post, params: params) { result in
            switch result {
            case .success(let data):
                self.handleSuccessResponse(data, completion: completion)
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    // Determine the appropriate endpoint and parameters based on the request type
    private func getEndpointAndParams(for request: AttachmentRequestType, userID: Int) -> (String, [String: Any]) {
        let endpoint = "/web/dataset/call_kw"
        let params: [String: Any]
        
        switch request {
        case let .fetch(idAttachment, includeDates):
            params = buildParams(for: AttachmentsRequest(attachmentId: idAttachment, isIncludeDates: includeDates, userID: userID))
        case let .fetchArray(idAttachment, includeDates):
            params = buildParams(for: AttachmentsListRequest(attachmentIds: idAttachment, isIncludeDates: includeDates, userID: userID))
        case let .uploadAttachment(attachment: attachment, message: message):
            params = buildParams(for: CreateAttachmentRequest(filename: attachment.filename, fileData: attachment.data, model: message.models, resId: message.resId))
        case let .uploadAttachmentChat(attachment: attachment, message: message):
            params = buildParams(for: CreateAttachmentRequest(filename: attachment.filename, fileData: attachment.data, model: message.model, resId: message.resId))
        }
        
        return (endpoint, params)
    }

    // Handle a successful response from the server
    private func handleSuccessResponse(_ data: Data, completion: @escaping (Result<[AttachmentModel], Error>) -> Void) {
        do {
            let jsonResponse = try JSONSerialization.jsonObject(with: data, options: [])
            guard let jsonResponseDict = jsonResponse as? [String: Any] else {
                completion(.failure(NSError(domain: "JSONError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid JSON format"])))
                return
            }
            
            // Check for errors in the response
            if let errorData = jsonResponseDict["error"] as? [String: Any] {
                completion(.failure(createServerError(from: errorData)))
            } else if let resultValue = jsonResponseDict["result"] as? Int {
                handleSingleAttachment(resultValue, completion: completion)
            } else if let resultArray = jsonResponseDict["result"] as? [[String: Any]] {
                handleMultipleAttachments(resultArray, completion: completion)
            } else {
                completion(.failure(NSError(domain: "InvalidResponse", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid response format"])))
            }
        } catch {
            completion(.failure(error))
        }
    }

    // Create a server error from the error data
    private func createServerError(from errorData: [String: Any]) -> NSError {
        let errorMessage = errorData["message"] as? String ?? "Unknown error"
        let errorCode = errorData["code"] as? Int ?? -1
        return NSError(domain: "OdooServerError", code: errorCode, userInfo: [NSLocalizedDescriptionKey: errorMessage])
    }

    // Handle a single attachment response
    private func handleSingleAttachment(_ resultValue: Int, completion: @escaping (Result<[AttachmentModel], Error>) -> Void) {
        print("Uploaded attachment ID: \(resultValue)")
        let attachment = AttachmentModel(id: resultValue)
        completion(.success([attachment]))
    }

    // Handle multiple attachments response
    private func handleMultipleAttachments(_ resultArray: [[String: Any]], completion: @escaping (Result<[AttachmentModel], Error>) -> Void) {
        let attachments = resultArray.compactMap { AttachmentModel.from(json: $0) }
        completion(.success(attachments))
    }

    // Build parameters for fetching a single attachment
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

    // Build parameters for fetching multiple attachments
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

    // Build parameters for creating an attachment
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
            "kwargs": [:]
        ]
    }
}

// Define the request types for attachments
public enum AttachmentRequestType {
    case fetch(idAttachment: Int, includeDates: Bool)
    case fetchArray(idAttachment: [Int], includeDates: Bool)
    case uploadAttachment(attachment: AttachmentModel, message: MobileSentMessage)
    case uploadAttachmentChat(attachment: AttachmentModel, message: MessageConversation)
}

// Structs to represent different request types
public struct AttachmentsRequest {
    var attachmentId: Int?
    var isIncludeDates: Bool
    var userID: Int
    var includeDates = ["datas"]
    var excludeDates = ["name", "mimetype", "res_name", "datas"]
}

public struct AttachmentsListRequest {
    var attachmentIds: [Int]
    var isIncludeDates: Bool
    var userID: Int
    var includeDates = ["datas"]
    var excludeDates = ["name", "mimetype", "res_name", "datas"]
}

public struct CreateAttachmentRequest {
    var filename: String?
    var fileData: String?
    var model: String?
    var resId: Int?
}
