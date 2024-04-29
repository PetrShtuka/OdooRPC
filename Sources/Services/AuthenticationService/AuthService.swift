//
//  AuthService.swift
//  OdooRPC
//
//  Created by Peter on 13.04.2024.
//

import Foundation

//public class AuthService: SessionService {
//    private var client: RPCClient
//    private var userData: UserData?
//    private var credentials: Credentials?
//
//    public init(client: RPCClient) {
//        self.client = client
//    }
//
//    public func configure(client: RPCClient) {
//          self.client = client
//      }
//
//    public func authenticate(credentials: Credentials, completion: @escaping (Result<UserData, Error>) -> Void) {
//        self.credentials = credentials  // Сохраняем учетные данные при аутентификации
//        client.sendRPCRequest(endpoint: "/web/session/authenticate", method: .post, params: credentials.asDictionary()) { result in
//            switch result {
//            case .success(let data):
//                do {
//                    let decoder = JSONDecoder()
//                    let userData = try decoder.decode(UserData.self, from: data)
//                    self.userData = userData  // Сохраняем данные пользователя
//                    completion(.success(userData))
//                } catch {
//                    completion(.failure(error))
//                }
//            case .failure(let error):
//                completion(.failure(error))
//            }
//        }
//    }
//
//    public func refreshSession(completion: @escaping (Result<UserData, Error>) -> Void) {
//        guard let credentials = self.credentials else {
//            completion(.failure(NSError(domain: "AuthService", code: 401, userInfo: [NSLocalizedDescriptionKey: "Учетные данные не доступны"])))
//            return
//        }
//        authenticate(credentials: credentials, completion: completion)
//    }
//
//    public func isSessionValid(completion: @escaping (Result<Bool, Error>) -> Void) {
//            // Example endpoint that checks session validity
//            let endpoint = "/web/session/get_session_info"
//            client.sendRPCRequest(endpoint: endpoint, method: .get, params: [:]) { result in
//                switch result {
//                case .success(let data):
//                    if let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
//                       let sessionValid = json["session_valid"] as? Bool {
//                        completion(.success(sessionValid))
//                    } else {
//                        completion(.success(false)) // Assume false if unsure
//                    }
//                case .failure(let error):
//                    completion(.failure(error))
//                }
//            }
//        }
//}
//
//public protocol SessionService {
//    func refreshSession(completion: @escaping (Result<UserData, Error>) -> Void)
//    func isSessionValid(completion: @escaping (Result<Bool, Error>) -> Void)
//}

public protocol SessionServiceDelegate {
    func refreshSession(completion: @escaping (Result<UserData, Error>) -> Void)
    func isSessionValid(baseURL: URL, completion: @escaping (Result<Bool, Error>) -> Void) 
}

import Foundation

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
                       var userData = try decoder.decode(ResponseWrapper.self, from: data)
                       if userData.result.uid == nil { // Проверяем, требуется ли 2FA
                           // Запрос 2FA кода через делегат или интерфейс
                           self.delegate?.requestTwoFactorCode { otpCode in
                               self.totpService?.authenticateTotp(otpCode, db: credentials.database) { totpResult in
                                   switch totpResult {
                                   case .success(let uid):
                                       userData.result.uid = uid // Обновляем uid после 2FA
                                       self.userData =  userData.result
                                       completion(.success( userData.result))
                                   case .failure(let error):
                                       completion(.failure(error))
                                   }
                               }
                           }
                       } else {
                           self.userData =  userData.result
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

    private func verifyTwoFactorCode(otp: String, completion: @escaping (Result<UserData, Error>) -> Void) {
        guard let credentials = self.credentials else {
            completion(.failure(NSError(domain: "AuthService", code: 401, userInfo: [NSLocalizedDescriptionKey: "Credentials not available"])))
            return
        }
        var params = credentials.asDictionary()
        params["otp"] = otp
        client.sendAuthenticationRequest(endpoint: "/web/session/verify_otp", method: .post, params: params) { result in
            switch result {
            case .success(let data):
                do {
                    let decoder = JSONDecoder()
                    let userData = try decoder.decode(UserData.self, from: data)
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
            completion(.failure(NSError(domain: "AuthService", code: 401, userInfo: [NSLocalizedDescriptionKey: "Credentials not available"])))
            return
        }
        authenticate(credentials: credentials, completion: completion)
    }
    
    public func isSessionValid(baseURL: URL, completion: @escaping (Result<Bool, Error>) -> Void) {
        let url = baseURL.appendingPathComponent("/web/session/get_session_info")
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
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
