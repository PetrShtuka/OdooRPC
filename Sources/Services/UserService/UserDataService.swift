//
//  UserDataService.swift
//  OdooRPC
//
//  Created by Peter on 20.04.2024.
//

import Foundation

public class UserDataService {
    private let rpcClient: RPCClient

    init(rpcClient: RPCClient) {
        self.rpcClient = rpcClient
    }

    public func fetchUserData(uid: Int, completion: @escaping (Result<UserData, Error>) -> Void) {
        let params: [String: Any] = [
            "model": "res.users",
            "method": "search_read",
            "args": [[]],  // empty array for args as specific criteria passed in kwargs
            "kwargs": [
                "domain": [["id", "=", uid]],
                "fields": ["name", "email", "lang", "tz", "partner_id", "avatar_128"]
            ]
        ]

        rpcClient.sendAuthenticationRequest(endpoint: "/web/dataset/call_kw", method: .post, params: params) { result in
            switch result {
            case .success(let data):
                do {
                    if let jsonData = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                       let result = jsonData["result"] as? [[String: Any]],
                       !result.isEmpty {
                        let userData = try JSONDecoder().decode(ResponseWrapper.self, from: JSONSerialization.data(withJSONObject: result.first!))
                        completion(.success(userData.result))
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
