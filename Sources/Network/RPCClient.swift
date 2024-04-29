//
//  RPCClient.swift
//  OdooRPC
//
//  Created by Peter on 13.04.2024.
//

import Foundation
import Foundation

public class RPCClient {
    private let session: URLSession
    private let baseURL: URL
    private var sessionService: SessionServiceDelegate?
    private var tasks: [Int: URLSessionDataTask] = [:]
    private let taskAccessQueue = DispatchQueue(label: "com.odooRPC.RPCClient.TaskAccessQueue")
    private var isRefreshingSession = false
    private var pendingRequests: [(Int, URLRequest, (Result<Data, Error>) -> Void)] = []
    
    public init(baseURL: URL) {
        self.baseURL = baseURL
        self.session = URLSession(configuration: .default)
    }
    
    @discardableResult
    public func sendRPCRequest(endpoint: String, method: HTTPMethod, params: [String: Any], completion: @escaping (Result<Data, Error>) -> Void) -> URLSessionDataTask? {
        let url = baseURL.appendingPathComponent(endpoint)
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let requestBody = ["jsonrpc": "2.0", "method": "call", "params": params, "id": Int.random(in: 1...1000)] as [String: Any]
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody, options: [])
        } catch {
            completion(.failure(error))
            return nil
        }
        
        // Check session validity or refresh if necessary
        self.isSessionValid { [weak self] isValid in
            guard let self = self else { return }
            if isValid {
                // Session is valid; proceed with the actual network request
                self.executeNetworkRequest(request: request, completion: completion)
            } else {
                // Session is not valid; attempt to refresh it
                self.refreshSession { success in
                    if success {
                        // After successful refresh, retry the network request
                        self.executeNetworkRequest(request: request, completion: completion)
                    } else {
                        completion(.failure(NSError(domain: "SessionRefreshError", code: 401, userInfo: ["message": "Session could not be refreshed"])))
                    }
                }
            }
        }
        return nil
    }
    
    private func executeNetworkRequest(request: URLRequest, completion: @escaping (Result<Data, Error>) -> Void) {
        let task = session.dataTask(with: request) { data, response, error in
            if let httpResponse = response as? HTTPURLResponse, !(200...299).contains(httpResponse.statusCode) {
                let errorInfo = [NSLocalizedDescriptionKey: "Server returned status code \(httpResponse.statusCode)", "StatusCode": "\(httpResponse.statusCode)"] as [String: Any]
                completion(.failure(NSError(domain: "HTTPError", code: httpResponse.statusCode, userInfo: errorInfo)))
                return
            }
            
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "NetworkError", code: -1, userInfo: nil)))
                return
            }
            
            completion(.success(data))
        }
        task.resume()
    }
    
    private func refreshSession(completion: @escaping (Bool) -> Void) {
        guard !isRefreshingSession else {
            completion(false)
            return
        }
        isRefreshingSession = true
        sessionService?.refreshSession { [weak self] result in
            guard let self = self else { return }
            self.isRefreshingSession = false
            switch result {
            case .success:
                completion(true)
            case .failure:
                completion(false)
            }
        }
    }
    
    private func isSessionValid(completion: @escaping (Bool) -> Void) {
        sessionService?.isSessionValid(baseURL: baseURL, completion: { result in
            switch result {
            case .success(let isValid):
                completion(isValid)
            case .failure:
                completion(false)
            }
        })
    }
    
    public func updateSessionService(_ service: SessionServiceDelegate) {
        self.sessionService = service
    }
}
