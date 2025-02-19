//
//  UserDataService.swift
//  OdooRPC
//
//  Created by Peter on 20.04.2024.
//

import Foundation

public class UserDataService {
    private let rpcClient: RPCClient

    // Initialize UserDataService with an RPCClient instance
    init(rpcClient: RPCClient) {
        self.rpcClient = rpcClient
    }

    // Method to fetch user data by user ID
    public func fetchUserData(uid: Int, completion: @escaping (Result<UserData, Error>) -> Void) {
        // Prepare parameters for the RPC call
        let params: [String: Any] = [
            "model": "res.users", // The model to query
            "method": "search_read", // The method to call
            "args": [], // Arguments for the method
            "kwargs": [
                "domain": [["id", "=", uid]], // Domain to filter by user ID
                "fields": ["id", "uid", "name", "email", "lang", "tz", "partner_id", "avatar_128"] // Fields to return
            ]
        ]

        // Send the RPC request to fetch user data
        rpcClient.sendAuthenticationRequest(endpoint: "/web/dataset/call_kw", method: .post, params: params) { result in
            switch result {
            case .success(let data):
                do {
                    // Parse the returned data
                    if let jsonData = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                        // Check for results in the JSON response
                        if let result = jsonData["result"] as? [[String: Any]], !result.isEmpty {
                            // Decode the user data from the first result
                            let userData = try JSONDecoder().decode(UserData.self, from: JSONSerialization.data(withJSONObject: result.first as Any))
                            completion(.success(userData)) // Return success with user data
                        } else {
                            // Handle invalid JSON structure
                            completion(.failure(NSError(domain: "ParseError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Invalid JSON structure"])))
                        }
                    } else {
                        // Handle invalid JSON structure
                        completion(.failure(NSError(domain: "ParseError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Invalid JSON structure"])))
                    }
                } catch {
                    // Handle any decoding errors
                    completion(.failure(error))
                }
            case .failure(let error):
                // Handle request failure
                completion(.failure(error))
            }
        }
    }
}
