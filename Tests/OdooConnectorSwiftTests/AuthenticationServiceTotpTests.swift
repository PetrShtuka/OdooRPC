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

    override func setUp() {
        super.setUp()
        mockRPCClient = MockRPCClient(baseURL: URL(string: "https://example.com")!)
        totpService = AuthenticationServiceTotp(rpcClient: mockRPCClient)
    }

    override func tearDown() {
        totpService = nil
        mockRPCClient = nil
        super.tearDown()
    }

    // Тест успешной аутентификации через TOTP
    func testAuthenticateTotpSuccess() {
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

        totpService.authenticateTotp("123456", db: "test_db") { result in
            switch result {
            case .success(let userData):
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

        waitForExpectations(timeout: 1.0)
    }

    // Тест неуспешной аутентификации через TOTP
    func testAuthenticateTotpFailure() {
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

        totpService.authenticateTotp("wrongotp", db: "test_db") { result in
            switch result {
            case .success:
                XCTFail("Expected failure, but got success")
            case .failure(let error as NSError):
                XCTAssertEqual(error.domain, "NSCocoaErrorDomain")
                XCTAssertEqual(error.code, 4865)
                XCTAssertEqual(error.localizedDescription, "The data couldn’t be read because it is missing.")
                expectation.fulfill()
            }
        }

        waitForExpectations(timeout: 1.0)
    }

    // Тест на сетевую ошибку
    func testAuthenticateTotpNetworkError() {
        let networkError = NSError(domain: NSURLErrorDomain, code: NSURLErrorNotConnectedToInternet, userInfo: nil)
        mockRPCClient.mockResult = .failure(networkError)

        let expectation = self.expectation(description: "Network Error")

        totpService.authenticateTotp("123456", db: "test_db") { result in
            switch result {
            case .success:
                XCTFail("Expected failure, but got success")
            case .failure(let error as NSError):
                XCTAssertEqual(error.domain, NSURLErrorDomain)
                XCTAssertEqual(error.code, NSURLErrorNotConnectedToInternet)
                expectation.fulfill()
            }
        }

        waitForExpectations(timeout: 1.0)
    }
}
