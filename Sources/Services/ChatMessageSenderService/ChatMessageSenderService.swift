//
//  ChatMessageSenderService.swift
//  OdooRPC
//
//  Created by Peter on 13.11.2024.
//

import Foundation

public class ChatMessageSenderService {
    private let rpcClient: RPCClient
    
    init(rpcClient: RPCClient) {
        self.rpcClient = rpcClient
    }
    
    public func sendMessage(
        message: ChatMessageModel,
        lang: String,
        timeZone: String,
        uid: Int,
        completion: @escaping (Result<Int, Error>) -> Void
    ) {
        let endpoint = "/web/dataset/call_kw"
        
        // Create the parameters from the ChatMessageModel
        let params: [String: Any] = [
            "model": "mail.compose.message",
            "method": "create",
            "args": [[
                "body": message.body ?? "",
                "parent_id": message.parentId as Any,
                "model": "mail.channel",
                "wizard_type": "comment",
                "partner_ids": message.partnerIds ?? [],
                "subject": message.authorName as Any,
                "res_id": message.resId as Any,
                "author_id": message.authorId as Any,
                "partner_cc_ids": [],
                "partner_bcc_ids": [],
                "attachment_ids": message.attachmentIds ?? []
            ]],
            "kwargs": [
                "context": [
                    "lang": lang,
                    "tz": timeZone,
                    "uid": uid
                ]
            ]
        ]
        
        // Send the request
        self.rpcClient.sendRPCRequest(endpoint: endpoint, method: .post, params: params) { result in
            switch result {
            case .success(let data):
                do {
                    if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                       let messageId = jsonResponse["result"] as? Int {
                        completion(.success(messageId))
                    } else {
                        completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid message ID received"])))
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
