//
//  DatabaseService.swift
//  OdooRPC
//
//  Created by Peter on 20.04.2024.
//

import Foundation

final class DatabaseService {
    private let rpcClient: RPCClient

    init(rpcClient: RPCClient) {
        self.rpcClient = rpcClient
    }
    
    func listDatabases(completion: @escaping (Result<[String], Error>) -> Void) {
        let params: [String: Any] = [
            "service": "db",
            "method": "list",
            "args": []
        ]

        rpcClient.sendRPCRequest(endpoint: "/jsonrpc", method: .post, params: params) { result in
            switch result {
            case .success(let data):
                do {
                    if let jsonData = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                       let result = jsonData["result"] as? [String] {
                        completion(.success(result))
                    } else {
                        completion(.failure(NSError(domain: "ParseError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Invalid JSON structure"])))
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
