//
//  AuthService.swift
//  OdooRPC
//
//  Created by Peter on 13.04.2024.
//

import Foundation

final class AuthService {
    private let client: RPCClient
    private var userData: UserData?  // Store user data after authentication
    private var credentials: Credentials?  // Optionally store credentials securely

    init(client: RPCClient) {
        self.client = client
    }

    func authenticate(credentials: Credentials, completion: @escaping (Result<UserData, Error>) -> Void) {
        self.credentials = credentials  // Store credentials if needed
        client.sendRPCRequest(endpoint: "/web/session/authenticate", method: .post, params: credentials.asDictionary()) { result in
            switch result {
            case .success(let data):
                do {
                    let decoder = JSONDecoder()
                    let userData = try decoder.decode(UserData.self, from: data)
                    self.userData = userData  // Store user data
                    completion(.success(userData))
                } catch {
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    func refreshSession(completion: @escaping (Result<UserData, Error>) -> Void) {
        guard let credentials = self.credentials else {
            completion(.failure(NSError(domain: "AuthService", code: 401, userInfo: [NSLocalizedDescriptionKey: "Credentials not available"])))
            return
        }
        authenticate(credentials: credentials, completion: completion)
    }
}

