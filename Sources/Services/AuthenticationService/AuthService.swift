//
//  AuthService.swift
//  OdooRPC
//
//  Created by Peter on 13.04.2024.
//

import Foundation

public protocol SessionServiceDelegate {
    func refreshSession(completion: @escaping (Result<UserData, Error>) -> Void)
    func isSessionValid(baseURL: URL, completion: @escaping (Result<Bool, Error>) -> Void)
}

public class AuthService: SessionServiceDelegate {
    public var client: RPCClient
    private var userData: UserData?
    private var credentials: Credentials?
    public weak var delegate: AuthServiceDelegate?
    private var totpService: AuthenticationServiceTotp?
    private var requestOtpCode: ((@escaping (String?) -> Void) -> Void)?

    public func onRequestOtpCode(_ handler: @escaping (@escaping (String?) -> Void) -> Void) {
        self.requestOtpCode = handler
    }

    public init(client: RPCClient) {
        self.client = client
        self.totpService = AuthenticationServiceTotp(rpcClient: client)
        self.client.updateSessionService(self)  // Assign AuthService as the session service
        print("AuthService initialized and sessionService set.")
    }

    public func setDelegate(_ delegate: AuthServiceDelegate) {
        self.delegate = delegate
    }

    public func authenticate(credentials: Credentials, completion: @escaping (Result<UserData, Error>) -> Void) {
        self.credentials = credentials  // Сохраняем учетные данные при аутентификации
        client.sendAuthenticationRequest(endpoint: "/web/session/authenticate", method: .post, params: credentials.asDictionary()) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let data):
                do {
                    let decoder = JSONDecoder()
                    let userData = try decoder.decode(ResponseWrapper.self, from: data)
                    if userData.result.uid == nil { // Проверяем, требуется ли 2FA
                        // Отправляем уведомление, требующее ввода 2FA кода
                        NotificationCenter.default.post(name: .requireTwoFactorAuthentication, object: nil, userInfo: ["credentials": credentials])
                    } else {
                        self.userData = userData.result
                        completion(.success(userData.result))
                    }
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
            completion(.failure(NSError(domain: "AuthService", code: 401, userInfo: [NSLocalizedDescriptionKey: "Credentials not available"])))
            return
        }
        authenticate(credentials: credentials, completion: completion)
    }

    public func isSessionValid(baseURL: URL, completion: @escaping (Result<Bool, Error>) -> Void) {
        let url = baseURL.appendingPathComponent("/web/session/get_session_info")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let requestBody = ["jsonrpc": "2.0", "method": "call", "params": [:], "id": "r1"] as [String : Any]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody, options: [])
        } catch {
            completion(.failure(error))
            return
        }

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data, let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                completion(.success(false))  // Assume the session is invalid if the response isn't successful
                return
            }
            
            if let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
               let sessionValid = json["session_valid"] as? Bool {
                completion(.success(sessionValid))
            } else {
                completion(.success(false))
            }
        }
        task.resume()
    }
}


public extension Notification.Name {
    static let requireTwoFactorAuthentication = Notification.Name("requireTwoFactorAuthentication")
}
