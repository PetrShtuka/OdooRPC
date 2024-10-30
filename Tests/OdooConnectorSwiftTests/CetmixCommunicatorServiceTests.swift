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
    
    // Setup method to initialize the mock client and communicator service before each test
    override func setUp() {
        super.setUp()
        mockRPCClient = MockRPCClient(baseURL: URL(string: "https://example.com")!)
        cetmixCommunicatorService = CetmixCommunicatorService(rpcClient: mockRPCClient)
    }
    
    // Teardown method to clean up after each test
    override func tearDown() {
        cetmixCommunicatorService = nil
        mockRPCClient = nil
        super.tearDown()
    }
    
    // Test for successfully fetching the database
    func testFetchDatabaseSuccess() {
        // Arrange: Prepare mock JSON response with database name
        let jsonData = """
        {
            "jsonrpc": "2.0",
            "id": 1,
            "result": "test_database"
        }
        """.data(using: .utf8)!
        
        mockRPCClient.mockResult = .success(jsonData)
        
        let expectation = self.expectation(description: "Successfully fetch database")
        
        // Act: Call the fetchDatabase method
        cetmixCommunicatorService.fetchDatabase(login: "user", password: "test_db") { result in
            switch result {
            case .success(let dbValue):
                // Assert: Check if the returned database name matches the expected value
                XCTAssertEqual(dbValue, "test_database")
                expectation.fulfill()
            case .failure(let error):
                XCTFail("Expected success, but got failure with error: \(error)")
            }
        }
        
        // Wait for the expectations to be fulfilled
        waitForExpectations(timeout: 1.0)
    }
    
    // Test for failure due to parsing error
    func testFetchDatabaseFailureParseError() {
        // Arrange: Prepare mock JSON response that will cause a parsing error
        let jsonData = """
        {
            "jsonrpc": "2.0",
            "id": 1,
            "result": {}
        }
        """.data(using: .utf8)!
        
        mockRPCClient.mockResult = .success(jsonData)
        
        let expectation = self.expectation(description: "Failure fetching database due to parse error")
        
        // Act: Call the fetchDatabase method
        cetmixCommunicatorService.fetchDatabase(login: "user", password: "test_db") { result in
            switch result {
            case .success:
                XCTFail("Expected parsing error, but got success")
            case .failure(let error as NSError):
                // Assert: Check if the error details are correct
                XCTAssertEqual(error.domain, "ParseError")
                XCTAssertEqual(error.code, 1)
                expectation.fulfill()
            }
        }
        
        // Wait for the expectations to be fulfilled
        waitForExpectations(timeout: 1.0)
    }
    
    // Test for failure due to network error
    func testFetchDatabaseFailureNetworkError() {
        // Arrange: Simulate a network error
        let networkError = NSError(domain: NSURLErrorDomain, code: NSURLErrorNotConnectedToInternet, userInfo: nil)
        mockRPCClient.mockResult = .failure(networkError)
        
        let expectation = self.expectation(description: "Failure fetching database due to network error")
        
        // Act: Call the fetchDatabase method
        cetmixCommunicatorService.fetchDatabase(login: "user", password: "test_db") { result in
            switch result {
            case .success:
                XCTFail("Expected network error, but got success")
            case .failure(let error as NSError):
                // Assert: Check if the error details are correct
                XCTAssertEqual(error.domain, NSURLErrorDomain)
                XCTAssertEqual(error.code, NSURLErrorNotConnectedToInternet)
                expectation.fulfill()
            }
        }
        
        // Wait for the expectations to be fulfilled
        waitForExpectations(timeout: 1.0)
    }
}
