//
//  SessionManager.swift
//  OdooRPC
//
//  Created by Peter on 30.10.2024.
//

import Foundation

public class SessionManager {
    private let rpcClient: RPCClient
    
    init(rpcClient: RPCClient) {
        // Commit: Initialize the SessionManager with an RPCClient instance.
        self.rpcClient = rpcClient
    }
    
    public func executeWithSessionCheck(request: @escaping () -> Void, completion: @escaping (Result<Data, Error>) -> Void) {
        // Commit: Check if the session is valid before executing the request.
        isSessionValid { [weak self] isValid in
            guard let self = self else { return }
            if isValid {
                // Commit: If the session is valid, execute the request.
                request()
            } else {
                // Commit: If the session is invalid, attempt to refresh it.
                self.refreshSession { success in
                    if success {
                        // Commit: After a successful refresh, execute the request again.
                        request()
                    } else {
                        // Commit: If the refresh fails, return an error.
                        completion(.failure(NSError(domain: "SessionRefreshError", code: 401, userInfo: ["message": "Session could not be refreshed"])))
                    }
                }
            }
        }
    }
    
    private func isSessionValid(completion: @escaping (Bool) -> Void) {
        // Commit: Validate the session by sending a request for session info.
        rpcClient.sendRPCRequest(endpoint: "/web/session/get_session_info", method: .post, params: [:]) { result in
            switch result {
            case .success:
                // Commit: If the request is successful, the session is valid.
                completion(true)
            case .failure:
                // Commit: If the request fails, the session is not valid.
                completion(false)
            }
        }
    }
    
    private func refreshSession(completion: @escaping (Bool) -> Void) {
        // Commit: Attempt to refresh the session by sending an authentication request.
        rpcClient.sendAuthenticationRequest(endpoint: "/web/session/authenticate", method: .post, params: [:]) { result in
            switch result {
            case .success:
                // Commit: If the refresh request is successful, return true.
                completion(true)
            case .failure:
                // Commit: If the refresh request fails, return false.
                completion(false)
            }
        }
    }
}
