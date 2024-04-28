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
    private var sessionService: SessionService?
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
        
        let requestId = Int.random(in: 1...1000)
        let requestBody = ["jsonrpc": "2.0", "method": "call", "params": params, "id": requestId] as [String: Any]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody, options: [])
        } catch {
            completion(.failure(error))
            return nil
        }
        
        let task = session.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { return }
            defer { self.taskAccessQueue.async { self.tasks.removeValue(forKey: requestId) } }
            
            if let httpResponse = response as? HTTPURLResponse, !(200...299).contains(httpResponse.statusCode) {
                let errorInfo = [
                    NSLocalizedDescriptionKey: "Server returned status code \(httpResponse.statusCode)",
                    "StatusCode": "\(httpResponse.statusCode)"
                ] as [String: Any]

                completion(.failure(NSError(domain: "HTTPError", code: httpResponse.statusCode, userInfo: errorInfo)))
                return
            }
            
            guard let data = data, error == nil else {
                completion(.failure(error ?? NSError(domain: "NetworkError", code: -1, userInfo: nil)))
                return
            }
            
            if self.isSessionExpired(data: data) {
                self.refreshSession { success in
                    if success {
                        self.sendRPCRequest(endpoint: endpoint, method: method, params: params, completion: completion)
                    } else {
                        completion(.failure(NSError(domain: "SessionRefreshError", code: 401, userInfo: ["message": "Session could not be refreshed"])))
                    }
                }
            } else {
                completion(.success(data))
            }
        }
        
        taskAccessQueue.sync {
            tasks[requestId] = task
        }
        task.resume()
        return task
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
    
    private func isSessionExpired(data: Data) -> Bool {
        if let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
           let error = json["error"] as? [String: Any],
           let message = error["data"] as? [String: Any],
           let name = message["name"] as? String {
            return name.contains("SessionExpiredException")
        }
        return false
    }
    
    public func updateSessionService(_ service: SessionService) {
           self.sessionService = service
    }
}
