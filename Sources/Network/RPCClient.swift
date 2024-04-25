//
//  RPCClient.swift
//  OdooRPC
//
//  Created by Peter on 13.04.2024.
//

import Foundation

public class RPCClient {
    private let session: URLSession
    private let baseURL: URL
    private var tasks: [Int: URLSessionDataTask] = [:]
    private let taskAccessQueue = DispatchQueue(label: "com.odooRPC.RPCClient.TaskAccessQueue")
    private var isRefreshingSession = false
    private var pendingRequests: [(Int, URLRequest, (Result<Data, Error>) -> Void)] = []
    private var sessionService: SessionService?
    
    init(baseURL: URL) {
        self.baseURL = baseURL
        self.session = URLSession(configuration: .default)
        self.sessionService = SessionService.self as? any SessionService
    }
    
    @discardableResult
    func sendRPCRequest(endpoint: String, method: HTTPMethod, params: [String: Any], completion: @escaping (Result<Data, Error>) -> Void) -> Int {
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
            return -1
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
                self.taskAccessQueue.async {
                    self.pendingRequests.append((requestId, request, completion))
                    if !self.isRefreshingSession {
                        self.refreshSession()
                    }
                }
            } else {
                completion(.success(data))
            }
        }
        
        taskAccessQueue.async {
            self.tasks[requestId] = task
            task.resume()
        }
        
        return requestId
    }
    
    private func isSessionExpired(data: Data) -> Bool {
        if let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
           let error = json["error"] as? [String: Any], let message = error["data"] as? [String: Any],
           let name = message["name"] as? String, name.contains("SessionExpiredException") {
            return true
        }
        return false
    }
    
    private func refreshSession() {
        isRefreshingSession = true
        sessionService?.refreshSession { [weak self] result in
            guard let self = self else { return }
            self.taskAccessQueue.async {
                self.isRefreshingSession = false
                let retry = (try? result.get()) != nil  // Assume successful reauthentication if we can get user data
                self.processPendingRequests(retry: retry)
            }
        }
    }
    
    private func processPendingRequests(retry: Bool) {
        self.taskAccessQueue.sync {
            for (id, request, completion) in self.pendingRequests {
                if retry {
                    let task = self.session.dataTask(with: request) { data, response, error in
                        guard let data = data, error == nil else {
                            completion(.failure(error ?? NSError(domain: "NetworkError", code: -1, userInfo: nil)))
                            return
                        }
                        completion(.success(data))
                    }
                    self.tasks[id] = task
                    task.resume()
                } else {
                    completion(.failure(NSError(domain: "SessionRefreshError", 
                                                code: 0,
                                                userInfo: ["message": "Failed to refresh session"])))
                }
            }
            self.pendingRequests.removeAll()
        }
    }
}
