//
//  AuthService.swift
//  OdooRPC
//
//  Created by Peter on 13.04.2024.
//

import Foundation

// Protocol defining session management methods
public protocol SessionServiceDelegate: AnyObject {
    func refreshSession(completion: @escaping (Result<UserData, Error>) -> Void)
    func isSessionValid(baseURL: URL, completion: @escaping (Result<Bool, Error>) -> Void)
}

public class AuthService: SessionServiceDelegate {
    public var client: RPCClient
    private var userData: UserData?
    private var credentials: Credentials?
    public weak var delegate: AuthServiceDelegate?
    var totpService: AuthenticationServiceTotp?
    private var requestOtpCode: ((@escaping (String?) -> Void) -> Void)?

    // Method to set the handler for OTP code requests
    public func onRequestOtpCode(_ handler: @escaping (@escaping (String?) -> Void) -> Void) {
        self.requestOtpCode = handler
    }

    // Initializer for AuthService
    public init(client: RPCClient) {
        self.client = client
        self.totpService = AuthenticationServiceTotp(rpcClient: client)
        self.client.updateSessionService(self)  // Set this instance as the session service
    }

    // Set a delegate for handling session events
    public func setDelegate(_ delegate: AuthServiceDelegate) {
        self.delegate = delegate
    }

    // Authenticate user with the given credentials
    public func authenticate(credentials: Credentials, completion: @escaping (Result<UserData, Error>) -> Void) {
        self.credentials = credentials
        client.sendAuthenticationRequest(endpoint: "/web/session/authenticate", method: .post, params: credentials.asDictionary()) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let data):
                do {
                    let decoder = JSONDecoder()
                    let userData = try decoder.decode(ResponseWrapper.self, from: data)
                    if userData.result.uid == nil {
                        NotificationCenter.default.post(name: .requireTwoFactorAuthentication, object: nil, userInfo: ["credentials": credentials])
                    } else {
                        self.userData = userData.result
                        completion(.success(userData.result))  // Return successful authentication
                    }
                } catch {
                    completion(.failure(error))  // Handle decoding errors
                }
            case .failure(let error):
                completion(.failure(error))  // Handle RPC client errors
            }
        }
    }

    // Refresh the current session
    public func refreshSession(completion: @escaping (Result<UserData, Error>) -> Void) {
        guard let credentials = self.credentials else {
            completion(.failure(NSError(domain: "AuthService", code: 401, userInfo: [NSLocalizedDescriptionKey: "Credentials not available"])))
            return
        }
        authenticate(credentials: credentials, completion: completion)  // Re-authenticate with existing credentials
    }

    // Check if the current session is valid
    public func isSessionValid(baseURL: URL, completion: @escaping (Result<Bool, Error>) -> Void) {
        let url = baseURL.appendingPathComponent("/web/session/get_session_info")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let requestBody = ["jsonrpc": "2.0", "method": "call", "params": [:], "id": "r1"] as [String: Any]

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody, options: [])
        } catch {
            completion(.failure(error))  // Handle serialization errors
            return
        }

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))  // Handle network errors
                return
            }

            guard let data = data, let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                completion(.success(false))  // Session is invalid if the response is not 200
                return
            }

            if let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
               let result = json["result"] as? [String: Any],
               result["uid"] as? Int != nil {
                completion(.success(true))  // Session is valid
            } else {
                completion(.success(false))  // Session is invalid
            }
        }
        task.resume()  // Start the network task
    }
}
