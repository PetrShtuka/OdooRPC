//
//  DatabaseService.swift
//  OdooRPC
//
//  Created by Peter on 20.04.2024.
//

import Foundation

public class DatabaseService {
    private let rpcClient: RPCClient

    // Initializer for DatabaseService, takes an RPCClient instance
    init(rpcClient: RPCClient) {
        self.rpcClient = rpcClient
    }

    // Method to list all databases
    public func listDatabases(completion: @escaping (Result<[String], Error>) -> Void) {
        // Parameters for the RPC call to list databases
        let params: [String: Any] = [
            "service": "db",
            "method": "list",
            "args": []  // No arguments needed for this method
        ]

        // Send the authentication request to the RPC client
        rpcClient.sendAuthenticationRequest(endpoint: "/jsonrpc", method: .post, params: params) { result in
            switch result {
            case .success(let data):
                do {
                    // Attempt to parse the JSON response
                    if let jsonData = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                       let result = jsonData["result"] as? [String] {
                        // Return the list of databases on success
                        completion(.success(result))
                    } else {
                        // Handle invalid JSON structure error
                        completion(.failure(NSError(domain: "ParseError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Invalid JSON structure"])))
                    }
                } catch {
                    // Handle any JSON parsing errors
                    completion(.failure(error))
                }
            case .failure(let error):
                // Return any errors encountered during the RPC request
                completion(.failure(error))
            }
        }
    }
}
