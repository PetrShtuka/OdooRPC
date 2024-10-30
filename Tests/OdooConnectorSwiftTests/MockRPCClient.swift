//
//  MockRPCClient.swift
//  OdooRPC
//
//  Created by Peter on 30.10.2024.
//

import XCTest
@testable import OdooRPC

class MockRPCClient: RPCClient {
    var mockResult: Result<Data, Error>?
    
    var mockSessionValid: Bool = false
    override func isSessionValid(completion: @escaping (Bool) -> Void) {
        completion(mockSessionValid)
    }
    
    override func sendRPCRequest(endpoint: String, method: HTTPMethod, params: [String: Any], completion: @escaping (Result<Data, Error>) -> Void) -> URLSessionDataTask? {
        if let result = mockResult {
            // Print the data for debugging
            if case let .success(data) = result {
                print("Mocked Response Data: \(String(data: data, encoding: .utf8) ?? "Invalid Data")")
                completion(.success(data)) // Call completion with the success data
            } else {
                completion(result) // Call completion with the failure result
            }
        } else {
            let error = NSError(domain: "Invalid response format", code: -1)
            completion(.failure(error)) // Call completion with an error if no mock result is available
        }
        return nil
    }
    
    override func sendAuthenticationRequest(endpoint: String, method: HTTPMethod, params: [String: Any], completion: @escaping (Result<Data, Error>) -> Void) -> URLSessionDataTask? {
        if endpoint == "/web/session/authenticate" && method == .post {
            if let result = mockResult {
                completion(result)
            } else {
                let error = NSError(domain: "MockError", code: 0, userInfo: [NSLocalizedDescriptionKey: "No mock result provided."])
                completion(.failure(error))
            }
        } else {
            if let result = mockResult {
                completion(result)
            }
        }
        return nil
    }
}
