//
//  AuthenticationService.swift
//  OdooRPC
//
//  Created by Peter on 20.04.2024.
//

import Foundation

public class AuthenticationServiceTotp {
    private let rpcClient: RPCClient
    
    // Initializer that accepts an RPCClient instance
    init(rpcClient: RPCClient) {
        self.rpcClient = rpcClient
    }
    
    // Authenticate using TOTP (Time-based One-Time Password)
    public func authenticateTotp(_ otp: String, database: String, completion: @escaping (Result<UserData, Error>) -> Void) {
        let endpoint = "/cetmix_communicator/authenticate/totp"
        let parameters: [String: Any] = [
            "totp_token": otp,  // The TOTP token provided by the user
            "db": database       // The database to authenticate against
        ]
        
        // Send the authentication request
        rpcClient.sendAuthenticationRequest(endpoint: endpoint, method: .post, params: parameters) { result in
            switch result {
            case .success(let data):
                do {
                    // Decode the response to obtain UserData
                    let userData = try JSONDecoder().decode(ResponseWrapper.self, from: data)
                    completion(.success(userData.result))
                } catch {
                    // Handle JSON decoding errors
                    completion(.failure(error))
                }
            case .failure(let error):
                // Handle failures from the RPC client
                completion(.failure(error))
            }
        }
    }
}
