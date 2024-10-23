//
//  CetmixCommunicatorServiceTests.swift
//  OdooRPC
//
//  Created by Peter on 23.10.2024.
//

import XCTest
@testable import OdooRPC

class CetmixCommunicatorServiceTests: XCTestCase {
    var cetmixCommunicatorService: CetmixCommunicatorService!
    var mockRPCClient: MockRPCClient!

    override func setUp() {
        super.setUp()
        mockRPCClient = MockRPCClient(baseURL: URL(string: "https://example.com")!)
        cetmixCommunicatorService = CetmixCommunicatorService(rpcClient: mockRPCClient)
    }

    override func tearDown() {
        cetmixCommunicatorService = nil
        mockRPCClient = nil
        super.tearDown()
    }

    func testFetchDatabaseSuccess() {
        let jsonData = """
        {
            "jsonrpc": "2.0",
            "id": 1,
            "result": "test_database"
        }
        """.data(using: .utf8)!

        mockRPCClient.mockResult = .success(jsonData)

        let expectation = self.expectation(description: "Получение базы данных успешно")

        cetmixCommunicatorService.fetchDatabase(login: "user", password: "test_db") { result in
            switch result {
            case .success(let dbValue):
                XCTAssertEqual(dbValue, "test_database")
                expectation.fulfill()
            case .failure(let error):
                XCTFail("Ожидали успех, но получили ошибку: \(error)")
            }
        }

        waitForExpectations(timeout: 1.0)
    }

    func testFetchDatabaseFailureParseError() {
        let jsonData = """
        {
            "jsonrpc": "2.0",
            "id": 1,
            "result": {}
        }
        """.data(using: .utf8)!

        mockRPCClient.mockResult = .success(jsonData)

        let expectation = self.expectation(description: "Неудача получения базы данных из-за ошибки парсинга")

        cetmixCommunicatorService.fetchDatabase(login: "user", password: "test_db") { result in
            switch result {
            case .success:
                XCTFail("Ожидали ошибку парсинга, но получили успех")
            case .failure(let error as NSError):
                XCTAssertEqual(error.domain, "ParseError")
                XCTAssertEqual(error.code, 1)
                expectation.fulfill()
            }
        }

        waitForExpectations(timeout: 1.0)
    }

    func testFetchDatabaseFailureNetworkError() {
        let networkError = NSError(domain: NSURLErrorDomain, code: NSURLErrorNotConnectedToInternet, userInfo: nil)
        mockRPCClient.mockResult = .failure(networkError)

        let expectation = self.expectation(description: "Неудача получения базы данных из-за сетевой ошибки")

        cetmixCommunicatorService.fetchDatabase(login: "user", password: "test_db") { result in
            switch result {
            case .success:
                XCTFail("Ожидали сетевую ошибку, но получили успех")
            case .failure(let error as NSError):
                XCTAssertEqual(error.domain, NSURLErrorDomain)
                XCTAssertEqual(error.code, NSURLErrorNotConnectedToInternet)
                expectation.fulfill()
            }
        }

        waitForExpectations(timeout: 1.0)
    }
}
