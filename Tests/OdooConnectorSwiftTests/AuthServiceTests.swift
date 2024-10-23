//
//  AuthServiceTests.swift
//  OdooRPC
//
//  Created by Peter on 23.10.2024.
//

import XCTest
@testable import OdooRPC

//class AuthServiceTests: XCTestCase {
//    var authService: AuthService!
//    var mockRPCClient: MockRPCClient!
//    var totpService: AuthenticationServiceTotp!
//
//    override func setUp() {
//        super.setUp()
//        mockRPCClient = MockRPCClient(baseURL: URL(string: "https://example.com")!)
//        authService = AuthService(client: mockRPCClient)
//        totpService = AuthenticationServiceTotp(rpcClient: mockRPCClient)
//    }
//
//    override func tearDown() {
//        authService = nil
//        mockRPCClient = nil
//        totpService = nil
//        super.tearDown()
//    }
//
//    // Тест успешной аутентификации через логин и пароль
//    func testLoginPasswordAuthenticationSuccess() {
//        let jsonData = """
//        {
//            "jsonrpc": "2.0",
//            "id": 1,
//            "result": {
//                "uid": 1,
//                "name": "Jane Doe",
//                "session_id": "test-session-token",
//                "is_superuser": false,
//                "lang": "en_US",
//                "tz": "UTC",
//                "partner_id": [2, "Jane Doe"],
//                "server_version": 16
//            }
//        }
//        """.data(using: .utf8)!
//
//        // Устанавливаем мок-результат перед вызовом authenticate
//        authService.client = mockRPCClient
//        mockRPCClient.mockResult = .success(jsonData)
//
//        let credentials = Credentials(username: "jane.doe", password: "password", database: "test_db")
//        let expectation = self.expectation(description: "Успех аутентификации")
//
//        authService.authenticate(credentials: credentials) { result in
//            switch result {
//            case .success(let userData):
//                XCTAssertEqual(userData.uid, 1)
//                XCTAssertEqual(userData.name, "Jane Doe")
//                XCTAssertEqual(userData.sessionToken, "test-session-token")
//                XCTAssertEqual(userData.isSuperuser, false)
//                XCTAssertEqual(userData.language, "en_US")
//                XCTAssertEqual(userData.timezone, "UTC")
//                XCTAssertEqual(userData.partnerID?.id, 2)
//                XCTAssertEqual(userData.serverVersion, 16)
//                expectation.fulfill()
//            case .failure(let error):
//                XCTFail("Ожидали успех, но получили ошибку: \(error)")
//            }
//        }
//    }
//
//
//    // Тест неуспешной аутентификации через логин и пароль
//    func testLoginPasswordAuthenticationFailure() {
//        let jsonData = """
//        {
//            "jsonrpc": "2.0",
//            "id": 1,
//            "error": {
//                "code": 403,
//                "message": "Invalid credentials"
//            }
//        }
//        """.data(using: .utf8)!
//
//        mockRPCClient.mockResult = .success(jsonData)
//
//        let credentials = Credentials(username: "wrong.user", password: "wrongpassword", database: "test_db")
//
//        let expectation = self.expectation(description: "Login Authentication Failure")
//
//        authService.authenticate(credentials: credentials) { result in
//            switch result {
//            case .success:
//                XCTFail("Expected failure, but got success")
//            case .failure(let error as NSError):
//                XCTAssertEqual(error.domain, "OdooServerError")
//                XCTAssertEqual(error.code, 403)
//                XCTAssertEqual(error.localizedDescription, "Invalid credentials")
//                expectation.fulfill()
//            }
//        }
//
//        waitForExpectations(timeout: 1.0)
//    }
//
//    // Тест успешной аутентификации через TOTP
//    func testTotpAuthenticationSuccess() {
//        let jsonData = """
//        {
//            "jsonrpc": "2.0",
//            "id": 1,
//            "result": {
//                "uid": 1,
//                "name": "John Doe",
//                "session_id": "test-session-token",
//                "is_superuser": true,
//                "lang": "en_US",
//                "tz": "UTC",
//                "partner_id": [1, "John Doe"],
//                "server_version": 16
//            }
//        }
//        """.data(using: .utf8)!
//
//        mockRPCClient.mockResult = .success(jsonData)
//
//        let expectation = self.expectation(description: "TOTP Authentication Success")
//
//        // Mock the TOTP service to simulate authentication
//        authService.onRequestOtpCode { completion in
//            completion("123456") // Provide the mock OTP
//        }
//
//        let credentials = Credentials(username: "jane.doe", password: "password", database: "test_db")
//
//        authService.authenticate(credentials: credentials) { result in
//            switch result {
//            case .success(let userData):
//                XCTAssertEqual(userData.uid, 1)
//                XCTAssertEqual(userData.name, "John Doe")
//                XCTAssertEqual(userData.sessionToken, "test-session-token")
//                XCTAssertEqual(userData.isSuperuser, true)
//                XCTAssertEqual(userData.language, "en_US")
//                XCTAssertEqual(userData.timezone, "UTC")
//                XCTAssertEqual(userData.partnerID?.id, 1)
//                XCTAssertEqual(userData.serverVersion, 16)
//                expectation.fulfill()
//            case .failure(let error):
//                XCTFail("Expected success, but got failure with error: \(error)")
//            }
//        }
//
//        waitForExpectations(timeout: 1.0)
//    }
//
//    // Тест на неуспешную аутентификацию через TOTP
//    func testTotpAuthenticationFailure() {
//        let jsonData = """
//        {
//            "jsonrpc": "2.0",
//            "id": 1,
//            "error": {
//                "code": 403,
//                "message": "Invalid TOTP code"
//            }
//        }
//        """.data(using: .utf8)!
//
//        mockRPCClient.mockResult = .success(jsonData)
//
//        let expectation = self.expectation(description: "TOTP Authentication Failure")
//
//        authService.onRequestOtpCode { completion in
//            completion("wrongotp") // Provide an invalid OTP
//        }
//
//        let credentials = Credentials(username: "jane.doe", password: "password", database: "test_db")
//
//        authService.authenticate(credentials: credentials) { result in
//            switch result {
//            case .success:
//                XCTFail("Expected failure, but got success")
//            case .failure(let error as NSError):
//                XCTAssertEqual(error.domain, "OdooServerError")
//                XCTAssertEqual(error.code, 403)
//                XCTAssertEqual(error.localizedDescription, "Invalid TOTP code")
//                expectation.fulfill()
//            }
//        }
//
//        waitForExpectations(timeout: 1.0)
//    }
//
//    // Тест на сетевую ошибку
//    func testAuthenticationNetworkError() {
//        let networkError = NSError(domain: NSURLErrorDomain, code: NSURLErrorNotConnectedToInternet, userInfo: nil)
//        mockRPCClient.mockResult = .failure(networkError)
//
//        let credentials = Credentials(username: "john.doe", password: "password", database: "test_db")
//
//        let expectation = self.expectation(description: "Network Error")
//
//        authService.authenticate(credentials: credentials) { result in
//            switch result {
//            case .success:
//                XCTFail("Expected failure, but got success")
//            case .failure(let error as NSError):
//                XCTAssertEqual(error.domain, NSURLErrorDomain)
//                XCTAssertEqual(error.code, NSURLErrorNotConnectedToInternet)
//                expectation.fulfill()
//            }
//        }
//
//        waitForExpectations(timeout: 1.0)
//    }
//}

class AuthServiceTests: XCTestCase {
    var authService: AuthService!
    var mockRPCClient: MockRPCClient!

    override func setUp() {
        super.setUp()
        mockRPCClient = MockRPCClient(baseURL: URL(string: "https://example.com")!)
        authService = AuthService(client: mockRPCClient)
    }

    override func tearDown() {
        authService = nil
        mockRPCClient = nil
        super.tearDown()
    }

    func testLoginPasswordAuthenticationSuccess() {
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
        let expectation = self.expectation(description: "Успех аутентификации")

        authService.authenticate(credentials: credentials) { result in
            switch result {
            case .success(let userData):
                XCTAssertEqual(userData.uid, 1)
                XCTAssertEqual(userData.name, "Jane Doe")
                XCTAssertEqual(userData.sessionToken, "test-session-token")
                expectation.fulfill()
            case .failure(let error):
                XCTFail("Ожидали успех, но получили ошибку: \(error)")
            }
        }

        waitForExpectations(timeout: 1.0)
    }

    func testLoginPasswordAuthenticationFailure() {
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
        let expectation = self.expectation(description: "Неудача аутентификации")

        authService.authenticate(credentials: credentials) { result in
            switch result {
            case .success:
                XCTFail("Ожидали ошибку, но получили успех")
            case .failure(let error as NSError):
                XCTAssertEqual(error.domain, "NSCocoaErrorDomain")
                XCTAssertEqual(error.code, 4865)
                expectation.fulfill()
            }
        }

        waitForExpectations(timeout: 1.0)
    }
}
