//
//  AuthenticationService.swift
//  OdooRPC
//
//  Created by Peter on 20.04.2024.
//

import Foundation

public class AuthenticationServiceTotp {
    private let rpcClient: RPCClient
    
    init(rpcClient: RPCClient) {
        self.rpcClient = rpcClient
    }
    
    public func authenticateTotp(_ otp: String, db: String, completion: @escaping (Result<UserData, Error>) -> Void) {
        let endpoint = "/cetmix_communicator/authenticate/totp"
        let parameters: [String: Any] = [
            "totp_token": otp,
            "db": db
        ]
        
        rpcClient.sendAuthenticationRequest(endpoint: endpoint, method: .post, params: parameters) { result in
            switch result {
            case .success(let data):
                do {
                    let userData = try JSONDecoder().decode(ResponseWrapper.self, from: data)  // Assuming server returns UID directly as an integer
                    completion(.success(userData.result))
                } catch {
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
