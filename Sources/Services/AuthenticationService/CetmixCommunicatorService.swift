//
//  CetmixCommunicatorService.swift
//  OdooRPC
//
//  Created by Peter on 20.04.2024.
//

import Foundation

final class CetmixCommunicatorService {
    private let rpcClient: RPCClient

    init(rpcClient: RPCClient) {
        self.rpcClient = rpcClient
    }
    
    func fetchDatabase(login: String, password: String, completion: @escaping (Result<String, Error>) -> Void) {
        let endpoint = "/cetmix_communicator/get_db"  // Modify if necessary
        let method: HTTPMethod = .post
        
        let params: [String: Any] = [
            "login": login,
            "db": password  // This should be adjusted if "password" is not meant to be the database name
        ]

        rpcClient.sendRPCRequest(endpoint: endpoint, method: method, params: params) { result in
            switch result {
            case .success(let data):
                do {
                    if let jsonData = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                       let dbValue = jsonData["result"] as? String {  // Make sure 'result' is the correct key
                        completion(.success(dbValue))
                    } else {
                        completion(.failure(NSError(domain: "ParseError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Invalid JSON structure or 'result' key not found"])))
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

