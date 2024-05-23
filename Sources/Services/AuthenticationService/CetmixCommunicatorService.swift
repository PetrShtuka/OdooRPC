//
//  CetmixCommunicatorService.swift
//  OdooRPC
//
//  Created by Peter on 20.04.2024.
//

import Foundation

public class CetmixCommunicatorService {
    private let rpcClient: RPCClient

    init(rpcClient: RPCClient) {
        self.rpcClient = rpcClient
    }
    
    public func fetchDatabase(login: String, password: String, completion: @escaping (Result<String, Error>) -> Void) {
        let endpoint = "/cetmix_communicator/get_db"  // Modify if necessary
        let method: HTTPMethod = .post

        let params: [String: Any] = [
            "login": login,
            "db": password  // This should be adjusted if "password" is not meant to be the database name
        ]

        rpcClient.sendAuthenticationRequest(endpoint: endpoint, method: method, params: params) { result in
            switch result {
            case .success(let data):
                do {
                    if let jsonData = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                        if let dbValue = jsonData["result"] as? String {
                            // Handle the original structure
                            completion(.success(dbValue))
                        } else if let resultArray = jsonData["result"] as? [[String: Any]],
                                  let firstResult = resultArray.first,
                                  let dbValue = firstResult["db"] as? String {
                            // Handle the new structure
                            completion(.success(dbValue))
                        } else {
                            completion(.failure(NSError(domain: "ParseError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Invalid JSON structure or 'result' key not found"])))
                        }
                    } else {
                        completion(.failure(NSError(domain: "ParseError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Invalid JSON data"])))
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

