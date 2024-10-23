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

    override func setUp() {
        super.setUp()
        mockRPCClient = MockRPCClient(baseURL: URL(string: "https://example.com")!)
        contactsService = ContactsService(rpcClient: mockRPCClient)
    }

    override func tearDown() {
        contactsService = nil
        mockRPCClient = nil
        super.tearDown()
    }

    // Тест успешной загрузки контактов
    func testLoadContactsSuccess() {
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

        contactsService.loadContacts(action: .fetch, searchParameters: ContactParameters(uid: 1, sessionId: "session-id")) { result in
            switch result {
            case .success(let contacts):
                XCTAssertEqual(contacts.count, 2)
                XCTAssertEqual(contacts[0].name, "John Doe")
                XCTAssertEqual(contacts[1].name, "Jane Smith")
                expectation.fulfill()
            case .failure(let error):
                XCTFail("Expected success, but got failure with error: \(error)")
            }
        }

        waitForExpectations(timeout: 1.0)
    }

    // Тест неуспешной загрузки контактов
    func testLoadContactsFailure() {
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

        mockRPCClient.mockResult = .success(jsonData)

        let expectation = self.expectation(description: "Load Contacts Failure")

        contactsService.loadContacts(action: .fetch, searchParameters: ContactParameters(uid: 1, sessionId: "session-id")) { result in
            switch result {
            case .success:
                XCTFail("Expected failure, but got success")
            case .failure(let error as NSError):
                XCTAssertEqual(error.domain, "Invalid response format")
                XCTAssertEqual(error.code, -1)
                XCTAssertEqual(error.localizedDescription, "The operation couldn’t be completed. (Invalid response format error -1.)")
                expectation.fulfill()
            }
        }

        waitForExpectations(timeout: 1.0)
    }

    // Тест на сетевую ошибку
    func testLoadContactsNetworkError() {
        let networkError = NSError(domain: NSURLErrorDomain, code: NSURLErrorNotConnectedToInternet, userInfo: nil)
        mockRPCClient.mockResult = .failure(networkError)

        let expectation = self.expectation(description: "Network Error")

        contactsService.loadContacts(action: .fetch, searchParameters: ContactParameters(uid: 1, sessionId: "session-id")) { result in
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
    
    // Тест успешного поиска контактов
       func testSearchContactsSuccess() {
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

           let searchParameters = ContactParameters(uid: 1, sessionId: "session-id", searchName: "John")

           contactsService.loadContacts(action: .search, searchParameters: searchParameters) { result in
               switch result {
               case .success(let contacts):
                   XCTAssertEqual(contacts.count, 1)
                   XCTAssertEqual(contacts[0].name, "John Doe")
                   XCTAssertEqual(contacts[0].email, "john.doe@example.com")
                   expectation.fulfill()
               case .failure(let error):
                   XCTFail("Expected success, but got failure with error: \(error)")
               }
           }

           waitForExpectations(timeout: 1.0)
       }

       // Тест неуспешного поиска контактов
       func testSearchContactsFailure() {
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

           mockRPCClient.mockResult = .success(jsonData)

           let expectation = self.expectation(description: "Search Contacts Failure")

           let searchParameters = ContactParameters(uid: 1, sessionId: "session-id", searchName: "Invalid Name")

           contactsService.loadContacts(action: .search, searchParameters: searchParameters) { result in
               switch result {
               case .success:
                   XCTFail("Expected failure, but got success")
               case .failure(let error as NSError):
                   XCTAssertEqual(error.domain, "Invalid response format")
                   XCTAssertEqual(error.code, -1)
                   XCTAssertEqual(error.localizedDescription, "The operation couldn’t be completed. (Invalid response format error -1.)")
                   expectation.fulfill()
               }
           }

           waitForExpectations(timeout: 1.0)
       }

       // Тест на сетевую ошибку при поиске контактов
       func testSearchContactsNetworkError() {
           let networkError = NSError(domain: NSURLErrorDomain, code: NSURLErrorNotConnectedToInternet, userInfo: nil)
           mockRPCClient.mockResult = .failure(networkError)

           let expectation = self.expectation(description: "Network Error")

           let searchParameters = ContactParameters(uid: 1, sessionId: "session-id", searchName: "John")

           contactsService.loadContacts(action: .search, searchParameters: searchParameters) { result in
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
