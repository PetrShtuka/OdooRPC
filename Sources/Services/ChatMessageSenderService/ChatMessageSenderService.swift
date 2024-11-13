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
        requestId: Int,
        language: String = "en_US",
        timeZone: String = "Europe/Rome",
        userId: Int,
        threadId: Int,
        messageBody: String,
        attachmentIDs: [Int] = [],
        completion: @escaping (Result<Int, Error>) -> Void
    ) {
        let endpoint = "/mail/message/post"
        let params: [String: Any] = [
            "id": requestId,
            "jsonrpc": "2.0",
            "method": "call",
            "params": [
                "context": [
                    "lang": language,
                    "tz": timeZone,
                    "uid": userId
                ],
                "thread_model": "mail.channel",
                "thread_id": threadId,
                "body": messageBody,
                "message_type": "comment",
                "subtype_xmlid": "mail.mt_comment",
                "attachment_ids": attachmentIDs,
                "attachment_tokens": [],
                "partner_ids": []
            ]
        ]
        
        self.rpcClient.sendRPCRequest(endpoint: endpoint, method: .post, params: params) { result in
            switch result {
            case .success(let data):
                do {
                    if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                       let responseId = jsonResponse["result"] as? Int {
                        completion(.success(responseId))
                    } else {
                        completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid response ID received"])))
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
