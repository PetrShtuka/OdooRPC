//
//  AuthServiceTests.swift
//  OdooRPC
//
//  Created by Peter on 23.10.2024.
//

import XCTest
@testable import OdooRPC

class AuthServiceTests: XCTestCase {
    var authService: AuthService!
    var mockRPCClient: MockRPCClient!
    
    // Setup method to initialize the mock client and auth service before each test
    override func setUp() {
        super.setUp()
        mockRPCClient = MockRPCClient(baseURL: URL(string: "https://example.com")!)
        authService = AuthService(client: mockRPCClient)
    }
    
    // Teardown method to clean up after each test
    override func tearDown() {
        authService = nil
        mockRPCClient = nil
        super.tearDown()
    }
    
    // Test for successful authentication with valid credentials
    func testLoginPasswordAuthenticationSuccess() {
        // Arrange: Prepare mock JSON response for successful authentication
        let jsonData = """
        {
            "jsonrpc": "2.0",
            "id": 1,
            "result": {
                "uid": 1,
                "name": "Jane Doe",
                "session_id": "test-session-token",
                "is_superuser": false,
                "lang": "en_US",
                "tz": "UTC",
                "partner_id": [2, "Jane Doe"],
                "server_version": 16
            }
        }
        """.data(using: .utf8)!
        
        mockRPCClient.mockResult = .success(jsonData)
        
        let credentials = Credentials(username: "jane.doe", password: "password", database: "test_db")
        let expectation = self.expectation(description: "Successful authentication")
        
        // Act: Call the authenticate method
        authService.authenticate(credentials: credentials) { result in
            switch result {
            case .success(let userData):
                // Assert: Check if returned user data matches expected values
                XCTAssertEqual(userData.uid, 1)
                XCTAssertEqual(userData.name, "Jane Doe")
                XCTAssertEqual(userData.sessionToken, "test-session-token")
                expectation.fulfill()
            case .failure(let error):
                XCTFail("Expected success, but got failure with error: \(error)")
            }
        }
        
        // Wait for the expectations to be fulfilled
        waitForExpectations(timeout: 1.0)
    }
    
    // Test for failure due to invalid credentials
    func testLoginPasswordAuthenticationFailure() {
        // Arrange: Prepare mock JSON response for invalid credentials
        let jsonData = """
        {
            "jsonrpc": "2.0",
            "id": 1,
            "error": {
                "code": 403,
                "message": "Invalid credentials"
            }
        }
        """.data(using: .utf8)!
        
        mockRPCClient.mockResult = .success(jsonData)
        
        let credentials = Credentials(username: "wrong.user", password: "wrongpassword", database: "test_db")
        let expectation = self.expectation(description: "Failed authentication")
        
        // Act: Call the authenticate method
        authService.authenticate(credentials: credentials) { result in
            switch result {
            case .success:
                XCTFail("Expected failure, but got success")
            case .failure(let error as NSError):
                // Assert: Check if the error details are correct
                XCTAssertEqual(error.domain, "NSCocoaErrorDomain")
                XCTAssertEqual(error.code, 4865) // Example error code
                expectation.fulfill()
            }
        }
        
        // Wait for the expectations to be fulfilled
        waitForExpectations(timeout: 1.0)
    }
}
