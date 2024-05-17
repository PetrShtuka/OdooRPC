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
            "args": [],  // пустой массив для args, так как критерии передаются в kwargs
            "kwargs": [
                "domain": [["id", "=", uid]],
                "fields": ["id", "name", "email", "lang", "tz", "partner_id", "avatar_128"]
            ]
        ]

        rpcClient.sendAuthenticationRequest(endpoint: "/web/dataset/call_kw", method: .post, params: params) { result in
            switch result {
            case .success(let data):
                do {
                    if let jsonData = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                        if let result = jsonData["result"] as? [[String: Any]], !result.isEmpty {
                            let userData = try JSONDecoder().decode(UserData.self, from: JSONSerialization.data(withJSONObject: result.first!))
                            completion(.success(userData))
                        } else {
                            completion(.failure(NSError(domain: "ParseError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Invalid JSON structure"])))
                        }
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
