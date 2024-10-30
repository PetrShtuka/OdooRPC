//
//  AuthenticationServiceTotpTests.swift
//  OdooRPC
//
//  Created by Peter on 23.10.2024.
//

import XCTest
@testable import OdooRPC

class AuthenticationServiceTotpTests: XCTestCase {
    var totpService: AuthenticationServiceTotp!
    var mockRPCClient: MockRPCClient!
    
    // Setup method to initialize the mock client and TOTP service before each test
    override func setUp() {
        super.setUp()
        mockRPCClient = MockRPCClient(baseURL: URL(string: "https://example.com")!)
        totpService = AuthenticationServiceTotp(rpcClient: mockRPCClient)
    }
    
    // Teardown method to clean up after each test
    override func tearDown() {
        totpService = nil
        mockRPCClient = nil
        super.tearDown()
    }
    
    // Test for successful TOTP authentication
    func testAuthenticateTotpSuccess() {
        // Arrange: Prepare mock JSON response for successful TOTP authentication
        let jsonData = """
        {
            "jsonrpc": "2.0",
            "id": 1,
            "result": {
                "uid": 1,
                "name": "John Doe",
                "session_id": "test-session-token",
                "is_superuser": true,
                "lang": "en_US",
                "tz": "UTC",
                "partner_id": [1, "John Doe"],
                "server_version": 16
            }
        }
        """.data(using: .utf8)!
        
        mockRPCClient.mockResult = .success(jsonData)
        
        let expectation = self.expectation(description: "TOTP Authentication Success")
        
        // Act: Call the authenticateTotp method
        totpService.authenticateTotp("123456", database: "test_db") { result in
            switch result {
            case .success(let userData):
                // Assert: Verify returned user data matches expected values
                XCTAssertEqual(userData.uid, 1)
                XCTAssertEqual(userData.name, "John Doe")
                XCTAssertEqual(userData.sessionToken, "test-session-token")
                XCTAssertEqual(userData.isSuperuser, true)
                XCTAssertEqual(userData.language, "en_US")
                XCTAssertEqual(userData.timezone, "UTC")
                XCTAssertEqual(userData.partnerID?.id, 1)
                expectation.fulfill()
            case .failure(let error):
                XCTFail("Expected success, but got failure with error: \(error)")
            }
        }
        
        // Wait for the expectations to be fulfilled
        waitForExpectations(timeout: 1.0)
    }
    
    // Test for failure due to invalid TOTP code
    func testAuthenticateTotpFailure() {
        // Arrange: Prepare mock JSON response for invalid TOTP code
        let jsonData = """
        {
            "jsonrpc": "2.0",
            "id": 1,
            "error": {
                "code": 403,
                "message": "Invalid TOTP code"
            }
        }
        """.data(using: .utf8)!
        
        mockRPCClient.mockResult = .success(jsonData)
        
        let expectation = self.expectation(description: "TOTP Authentication Failure")
        
        // Act: Call the authenticateTotp method with an invalid code
        totpService.authenticateTotp("wrongotp", database: "test_db") { result in
            switch result {
            case .success:
                XCTFail("Expected failure, but got success")
            case .failure(let error as NSError):
                // Assert: Verify error details are correct
                XCTAssertEqual(error.domain, "NSCocoaErrorDomain")
                XCTAssertEqual(error.code, 4865) // Example error code
                XCTAssertEqual(error.localizedDescription, "The data couldn’t be read because it is missing.")
                expectation.fulfill()
            }
        }
        
        // Wait for the expectations to be fulfilled
        waitForExpectations(timeout: 1.0)
    }
    
    // Test for network error during TOTP authentication
    func testAuthenticateTotpNetworkError() {
        // Arrange: Simulate a network error
        let networkError = NSError(domain: NSURLErrorDomain, code: NSURLErrorNotConnectedToInternet, userInfo: nil)
        mockRPCClient.mockResult = .failure(networkError)
        
        let expectation = self.expectation(description: "Network Error")
        
        // Act: Call the authenticateTotp method
        totpService.authenticateTotp("123456", database: "test_db") { result in
            switch result {
            case .success:
                XCTFail("Expected failure, but got success")
            case .failure(let error as NSError):
                // Assert: Verify error domain and code match expected values
                XCTAssertEqual(error.domain, NSURLErrorDomain)
                XCTAssertEqual(error.code, NSURLErrorNotConnectedToInternet)
                expectation.fulfill()
            }
        }
        
        // Wait for the expectations to be fulfilled
        waitForExpectations(timeout: 1.0)
    }
}
