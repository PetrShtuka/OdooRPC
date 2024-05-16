//
//  OdooService.swift
//  OdooRPC
//
//  Created by Peter on 20.04.2024.
//

import Foundation

public class OdooService {
    private let rpcClient: RPCClient
    
    init(rpcClient: RPCClient) {
        self.rpcClient = rpcClient
    }
    
    public func getVersionOdoo(serverURL: URL, completion: @escaping (Result<Double, Error>) -> Void) {
        let endpoint = "/web/webclient/version_info"  // Confirm this endpoint with your server setup.
        
        // Use the provided URL directly in the RPCClient request
        rpcClient.sendAuthenticationRequest(endpoint: endpoint, method: .post, params: [:]) { result in
            switch result {
            case .success(let data):
                do {
                    if let jsonData = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                       let resultDict = jsonData["result"] as? [String: Any],
                       let versionString = resultDict["server_serie"] as? String,
                       let serverVersion = Double(versionString) {
                        completion(.success(serverVersion))
                    } else {
                        completion(.failure(NSError(domain: "DataParsingError", code: -2, userInfo: [NSLocalizedDescriptionKey: "Invalid JSON structure or 'server_serie' key not found"])))
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
