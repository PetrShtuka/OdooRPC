//
//  SessionManagerTests.swift
//  OdooRPC
//
//  Created by Peter on 30.10.2024.
//

import XCTest
@testable import OdooRPC

class SessionManagerTests: XCTestCase {
    var rpcClientMock: MockRPCClient!
    var sessionManager: SessionManager!
    
    override func setUp() {
        super.setUp()
        // Commit: Initialize the mock RPC client and the session manager.
        rpcClientMock = MockRPCClient(baseURL: URL(string: "https://example.com")!)
        sessionManager = SessionManager(rpcClient: rpcClientMock)
    }
    
    func testSessionValid() {
        // Commit: Arrange the test for a valid session.
        // Set the mock to return a valid session.
        rpcClientMock.mockSessionValid = true
        rpcClientMock.mockResult = .success(try! JSONSerialization.data(withJSONObject: ["result": true], options: []))
        
        // Commit: Act on the session manager with a valid session check.
        sessionManager.executeWithSessionCheck(request: {
            // Logic for the request can be added here.
        }) { result in
            // Commit: Assert that the result is successful.
            switch result {
            case .success:
                XCTAssertTrue(true)
            case .failure:
                XCTFail("Expected success but got failure")
            }
        }
    }
    
    func testSessionInvalidAndRefresh() {
        // Commit: Arrange the test for an invalid session.
        // Set the mock to return an invalid session.
        rpcClientMock.mockSessionValid = false
        rpcClientMock.mockResult = .success(try! JSONSerialization.data(withJSONObject: ["result": true], options: []))
        
        // Commit: Act on the session manager with an invalid session check.
        sessionManager.executeWithSessionCheck(request: {
            // Logic for the request can be added here.
        }) { result in
            // Commit: Assert that the result is successful after refreshing the session.
            switch result {
            case .success:
                XCTAssertTrue(true)
            case .failure:
                XCTFail("Expected success but got failure")
            }
        }
    }
}
