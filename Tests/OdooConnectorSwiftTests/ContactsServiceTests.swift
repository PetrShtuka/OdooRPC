//
//  ContactsServiceTests.swift
//  OdooRPC
//
//  Created by Peter on 23.10.2024.
//

import XCTest
@testable import OdooRPC

class ContactsServiceTests: XCTestCase {
    var contactsService: ContactsService!
    var mockRPCClient: MockRPCClient!
    
    // Setup method to initialize the mock client and contacts service before each test
    override func setUp() {
        super.setUp()
        mockRPCClient = MockRPCClient(baseURL: URL(string: "https://example.com")!)
        contactsService = ContactsService(rpcClient: mockRPCClient)
    }
    
    // Teardown method to clean up after each test
    override func tearDown() {
        contactsService = nil
        mockRPCClient = nil
        super.tearDown()
    }
    
    // Test for successfully loading contacts
    func testLoadContactsSuccess() {
        // Arrange: Prepare mock JSON response with contact data
        let jsonData = """
        {
            "jsonrpc": "2.0",
            "id": 1,
            "result": [
                {
                    "id": 1,
                    "name": "John Doe",
                    "email": "john.doe@example.com"
                },
                {
                    "id": 2,
                    "name": "Jane Smith",
                    "email": "jane.smith@example.com"
                }
            ]
        }
        """.data(using: .utf8)!
        
        mockRPCClient.mockResult = .success(jsonData)
        
        let expectation = self.expectation(description: "Load Contacts Success")
        
        // Act: Call the loadContacts method
        contactsService.loadContacts(action: .fetch, searchParameters: ContactParameters(uid: 1, sessionId: "session-id")) { result in
            switch result {
            case .success(let contacts):
                // Assert: Check if the returned contacts match the expected data
                XCTAssertEqual(contacts.count, 2)
                XCTAssertEqual(contacts[0].name, "John Doe")
                XCTAssertEqual(contacts[1].name, "Jane Smith")
                expectation.fulfill()
            case .failure(let error):
                XCTFail("Expected success, but got failure with error: \(error)")
            }
        }
        
        // Wait for the expectations to be fulfilled
        waitForExpectations(timeout: 1.0)
    }
    
    // Test for failure in loading contacts
    func testLoadContactsFailure() {
        // Arrange: Prepare mock error response
        let jsonData = """
        {
            "jsonrpc": "2.0",
            "id": 1,
            "error": {
                "code": 400,
                "message": "Invalid parameters"
            }
        }
        """.data(using: .utf8)!
        
        mockRPCClient.mockResult = .failure(NSError(domain: "Invalid response format", code: -1))
        
        // Act: Call the loadContacts method
        contactsService.loadContacts(action: .fetch, searchParameters: ContactParameters(uid: 1, sessionId: "session-id")) { result in
            switch result {
            case .success:
                XCTFail("Expected failure, but got success")
            case .failure(let error as NSError):
                // Assert: Check if the error details are correct
                XCTAssertEqual(error.domain, "Invalid response format")
                XCTAssertEqual(error.code, -1)
                XCTAssertEqual(error.localizedDescription, "The operation couldn’t be completed. (Invalid response format error -1.)")
            }
        }
    }
    
    // Test for network error while loading contacts
    func testLoadContactsNetworkError() {
        // Arrange: Simulate a network error
        let networkError = NSError(domain: NSURLErrorDomain, code: NSURLErrorNotConnectedToInternet, userInfo: nil)
        mockRPCClient.mockResult = .failure(networkError)
        
        let expectation = self.expectation(description: "Network Error")
        
        // Act: Call the loadContacts method
        contactsService.loadContacts(action: .fetch, searchParameters: ContactParameters(uid: 1, sessionId: "session-id")) { result in
            switch result {
            case .success:
                XCTFail("Expected failure, but got success")
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
    
    // Test for successfully searching contacts
    func testSearchContactsSuccess() {
        // Arrange: Prepare mock JSON response for search results
        let jsonData = """
           {
               "jsonrpc": "2.0",
               "id": 1,
               "result": {
                   "length": 1,
                   "records": [
                       {
                           "id": 1,
                           "name": "John Doe",
                           "email": "john.doe@example.com"
                       }
                   ]
               }
           }
           """.data(using: .utf8)!
        
        mockRPCClient.mockResult = .success(jsonData)
        
        let expectation = self.expectation(description: "Search Contacts Success")
        
        // Act: Create search parameters and call loadContacts
        let searchParameters = ContactParameters(uid: 1, sessionId: "session-id", searchName: "John")
        
        contactsService.loadContacts(action: .search, searchParameters: searchParameters) { result in
            switch result {
            case .success(let contacts):
                // Assert: Check if the returned contacts match the expected data
                XCTAssertEqual(contacts.count, 1)
                XCTAssertEqual(contacts[0].name, "John Doe")
                XCTAssertEqual(contacts[0].email, "john.doe@example.com")
                expectation.fulfill()
            case .failure(let error):
                XCTFail("Expected success, but got failure with error: \(error)")
            }
        }
        
        // Wait for the expectations to be fulfilled
        waitForExpectations(timeout: 1.0)
    }
    
    // Test for failure in searching contacts
    func testSearchContactsFailure() {
        // Arrange: Prepare mock error response for search
        let jsonData = """
           {
               "jsonrpc": "2.0",
               "id": 1,
               "error": {
                   "code": 400,
                   "message": "Invalid search parameters"
               }
           }
           """.data(using: .utf8)!
        
        mockRPCClient.mockResult = .failure(NSError(domain: "Invalid response format", code: -1))
        
        let expectation = self.expectation(description: "Search Contacts Failure")
        
        // Act: Create invalid search parameters and call loadContacts
        let searchParameters = ContactParameters(uid: 1, sessionId: "session-id", searchName: "Invalid Name")
        
        contactsService.loadContacts(action: .search, searchParameters: searchParameters) { result in
            switch result {
            case .success:
                XCTFail("Expected failure, but got success")
            case .failure(let error as NSError):
                // Assert: Check if the error details are correct
                XCTAssertEqual(error.domain, "Invalid response format")
                XCTAssertEqual(error.code, -1)
                XCTAssertEqual(error.localizedDescription, "The operation couldn’t be completed. (Invalid response format error -1.)")
                expectation.fulfill()
            }
        }
        
        // Wait for the expectations to be fulfilled
        waitForExpectations(timeout: 1.0)
    }
    
    // Test for network error while searching contacts
    func testSearchContactsNetworkError() {
        // Arrange: Simulate a network error
        let networkError = NSError(domain: NSURLErrorDomain, code: NSURLErrorNotConnectedToInternet, userInfo: nil)
        mockRPCClient.mockResult = .failure(networkError)
        
        let expectation = self.expectation(description: "Network Error")
        
        // Act: Create search parameters and call loadContacts
        let searchParameters = ContactParameters(uid: 1, sessionId: "session-id", searchName: "John")
        
        contactsService.loadContacts(action: .search, searchParameters: searchParameters) { result in
            switch result {
            case .success:
                XCTFail("Expected failure, but got success")
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
