//
//  RPCClient.swift
//  OdooRPC
//
//  Created by Peter on 13.04.2024.
//

import Foundation

struct PendingRequest {
    let id: Int
    let request: URLRequest
    let completion: (Result<Data, Error>) -> Void
}

public class RPCClient {
    private let session: URLSession
    private let baseURL: URL
    private var sessionService: SessionServiceDelegate?
    private var tasks: [Int: URLSessionDataTask] = [:]
    private let taskAccessQueue = DispatchQueue(label: "com.odooRPC.RPCClient.TaskAccessQueue")
    private var isRefreshingSession = false
    private var pendingRequests: [PendingRequest] = []

    // Initializer that sets up the base URL and URLSession
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

        // Store the pending request for session management
        let pendingRequest = PendingRequest(id: Int.random(in: 1...1000), request: request, completion: completion)
        pendingRequests.append(pendingRequest)

        var task: URLSessionDataTask?
        self.isSessionValid { [self] isValid in
            if isValid {
                // Session is valid; proceed with the actual network request
                task = self.executeNetworkRequest(request: request, completion: completion)
            } else {
                // Session is not valid; attempt to refresh it
                self.refreshSession { success in
                    if success {
                        // After successful refresh, retry the network request
                        task = self.executeNetworkRequest(request: request, completion: completion)
                    } else {
                        completion(.failure(NSError(domain: "SessionRefreshError", code: 401, userInfo: ["message": "Session could not be refreshed"])))
                    }
                }
            }
        }
        return task
    }

    @discardableResult
    public func sendAuthenticationRequest(endpoint: String, method: HTTPMethod, params: [String: Any], completion: @escaping (Result<Data, Error>) -> Void) -> URLSessionDataTask? {
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

        // Execute the network request for authentication
        return executeNetworkRequest(request: request, completion: completion)
    }

    private func executeNetworkRequest(request: URLRequest, completion: @escaping (Result<Data, Error>) -> Void) -> URLSessionDataTask {
        let task = session.dataTask(with: request) { data, _, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(NSError(domain: "NetworkError", code: -1, userInfo: nil)))
                return
            }

            // Return the successful data response
            completion(.success(data))
        }
        task.resume()
        return task
    }

    private func refreshSession(completion: @escaping (Bool) -> Void) {
        guard !isRefreshingSession else {
            completion(false)
            return
        }
        guard let sessionService = sessionService else {
            print("sessionService is nil during refreshSession")
            completion(false)
            return
        }
        isRefreshingSession = true
        sessionService.refreshSession { [weak self] result in
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

    // Check if the current session is valid
    func isSessionValid(completion: @escaping (Bool) -> Void) {
        guard let sessionService = sessionService else {
            print("sessionService is nil during isSessionValid check")
            completion(false)
            return
        }
        sessionService.isSessionValid(baseURL: baseURL, completion: { result in
            switch result {
            case .success(let isValid):
                completion(isValid)
            case .failure:
                completion(false)
            }
        })
    }

    // Update the session service used for session management
    public func updateSessionService(_ service: SessionServiceDelegate) {
        print("Updating session service...")
        self.sessionService = service
        print("Session service updated to: \(String(describing: self.sessionService))")
    }
}
