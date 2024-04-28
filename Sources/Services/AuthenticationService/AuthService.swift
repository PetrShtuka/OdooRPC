//
//  AuthService.swift
//  OdooRPC
//
//  Created by Peter on 13.04.2024.
//

import Foundation

public class AuthService: SessionService {
    private var client: RPCClient
    private var userData: UserData?
    private var credentials: Credentials? 

    public init(client: RPCClient) {
        self.client = client
    }
    
    public func configure(client: RPCClient) {
          self.client = client
      }

    public func authenticate(credentials: Credentials, completion: @escaping (Result<UserData, Error>) -> Void) {
        self.credentials = credentials  // Сохраняем учетные данные при аутентификации
        client.sendRPCRequest(endpoint: "/web/session/authenticate", method: .post, params: credentials.asDictionary()) { result in
            switch result {
            case .success(let data):
                do {
                    let decoder = JSONDecoder()
                    let userData = try decoder.decode(UserData.self, from: data)
                    self.userData = userData  // Сохраняем данные пользователя
                    completion(.success(userData))
                } catch {
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    public func refreshSession(completion: @escaping (Result<UserData, Error>) -> Void) {
        guard let credentials = self.credentials else {
            completion(.failure(NSError(domain: "AuthService", code: 401, userInfo: [NSLocalizedDescriptionKey: "Учетные данные не доступны"])))
            return
        }
        authenticate(credentials: credentials, completion: completion)
    }

    public func isSessionValid(completion: @escaping (Result<Bool, Error>) -> Void) {
            // Example endpoint that checks session validity
            let endpoint = "/web/session/get_session_info"
            client.sendRPCRequest(endpoint: endpoint, method: .get, params: [:]) { result in
                switch result {
                case .success(let data):
                    if let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                       let sessionValid = json["session_valid"] as? Bool {
                        completion(.success(sessionValid))
                    } else {
                        completion(.success(false)) // Assume false if unsure
                    }
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
}

public protocol SessionService {
    func refreshSession(completion: @escaping (Result<UserData, Error>) -> Void)
    func isSessionValid(completion: @escaping (Result<Bool, Error>) -> Void)
}
