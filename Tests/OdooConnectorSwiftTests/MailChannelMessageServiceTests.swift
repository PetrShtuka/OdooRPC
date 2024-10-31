//
//  MailChannelMessageServiceTests.swift
//  OdooRPCTests
//
//  Created by Peter on 31.10.2024.
//

import XCTest
@testable import OdooRPC

class MailChannelMessageServiceTests: XCTestCase {
    
    var mockRPCClient: MockRPCClient!
    var service: MailChannelMessageService!
    
    override func setUp() {
        super.setUp()
        mockRPCClient = MockRPCClient(baseURL: URL(string: "https://mockserver.com")!)
        service = MailChannelMessageService(rpcClient: mockRPCClient)
    }
    
    override func tearDown() {
        mockRPCClient = nil
        service = nil
        super.tearDown()
    }
    
    func testFetchChannelMessagesSuccess() {
        // Mock JSON response for success
        let jsonData = """
        [
            {
                "id": 1,
                "body": "Test message",
                "attachment_ids": [123],
                "author_display": "Author Name"
            }
        ]
        """.data(using: .utf8)!
        
        mockRPCClient.mockResult = .success(jsonData)
        
        let expectation = XCTestExpectation(description: "Fetch channel messages success")
        
        let request = MailChannelMessageAction.fetchChannelMessages(channelID: 1, limit: 10)
        let userData = UserData(
            uid: 1,
            name: "Test User",
            sessionToken: "testSessionToken",
            isSuperuser: false,
            language: "en",
            timezone: "UTC",
            partnerID: PartnerID(id: 1, name: "Test Partner"), // или инициализируйте партнера, если он является сложным объектом
            serverVersion: 15
        )

        service.requestAttachment(request: request, user: userData) { result in
            switch result {
            case .success(let messages):
                XCTAssertEqual(messages.count, 1)
                XCTAssertEqual(messages.first?.body, "Test message")
                XCTAssertEqual(messages.first?.attachmentIds, [123])
                expectation.fulfill()
            case .failure:
                XCTFail("Expected success, got failure")
            }
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testFetchChannelMessagesFailure() {
        // Mock error response
        let error = NSError(domain: "MockError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Mocked error"])
        mockRPCClient.mockResult = .failure(error)
        
        let expectation = XCTestExpectation(description: "Fetch channel messages failure")
        
        let request = MailChannelMessageAction.fetchChannelMessages(channelID: 1, limit: 10)
        let userData = UserData(
            uid: 1,
            name: "Test User",
            sessionToken: "testSessionToken",
            isSuperuser: false,
            language: "en",
            timezone: "UTC",
            partnerID: PartnerID(id: 1, name: "Test Partner"), // или инициализируйте партнера, если он является сложным объектом
            serverVersion: 15
        )
        
        service.requestAttachment(request: request, user: userData) { result in
            switch result {
            case .success:
                XCTFail("Expected failure, got success")
            case .failure(let err):
                XCTAssertEqual((err as NSError).domain, "MockError")
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testFetchChannelNewMessagesSuccess() {
        // Mock JSON response for success
        let jsonData = """
        [
            {
                "id": 2,
                "body": "New message",
                "attachment_ids": [456],
                "author_display": "New Author"
            }
        ]
        """.data(using: .utf8)!
        
        mockRPCClient.mockResult = .success(jsonData)
        
        let expectation = XCTestExpectation(description: "Fetch channel new messages success")
        
        let request = MailChannelMessageAction.fetchChannelNewMessages(channelID: 2, limit: 5, messagesID: 1, comparisonOperator: ">", userPartnerID: 3, isChat: true)
        let userData = UserData(
            uid: 2,
            name: "Test User",
            sessionToken: "testSessionToken",
            isSuperuser: false,
            language: "en",
            timezone: "UTC",
            partnerID: PartnerID(id: 1, name: "Test Partner"), // или инициализируйте партнера, если он является сложным объектом
            serverVersion: 15
        )
        
        service.requestAttachment(request: request, user: userData) { result in
            switch result {
            case .success(let messages):
                XCTAssertEqual(messages.count, 1)
                XCTAssertEqual(messages.first?.body, "New message")
                XCTAssertEqual(messages.first?.attachmentIds, [456])
                expectation.fulfill()
            case .failure:
                XCTFail("Expected success, got failure")
            }
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testFetchChannelNewMessagesFailure() {
        // Mock error response
        let error = NSError(domain: "MockError", code: -2, userInfo: [NSLocalizedDescriptionKey: "Mocked error"])
        mockRPCClient.mockResult = .failure(error)
        
        let expectation = XCTestExpectation(description: "Fetch channel new messages failure")
        
        let request = MailChannelMessageAction.fetchChannelNewMessages(channelID: 2, limit: 5, messagesID: 1, comparisonOperator: ">", userPartnerID: 3, isChat: true)
        let userData = UserData(
            uid: 2,
            name: "Test User",
            sessionToken: "testSessionToken",
            isSuperuser: false,
            language: "en",
            timezone: "UTC",
            partnerID: PartnerID(id: 1, name: "Test Partner"), // или инициализируйте партнера, если он является сложным объектом
            serverVersion: 15
        )
        
        service.requestAttachment(request: request, user: userData) { result in
            switch result {
            case .success:
                XCTFail("Expected failure, got success")
            case .failure(let err):
                XCTAssertEqual((err as NSError).domain, "MockError")
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testFetchCheckOutMessagesSuccess() {
        // Mock JSON response for success
        let jsonData = """
        [
            {
                "id": 3,
                "body": "Checkout message",
                "attachment_ids": []
            }
        ]
        """.data(using: .utf8)!
        
        mockRPCClient.mockResult = .success(jsonData)
        
        let expectation = XCTestExpectation(description: "Fetch checkout messages success")
        
        let request = MailChannelMessageAction.fetchCheckOutMessages(channelID: 3, messagesIDs: [1, 2, 3])
        let userData = UserData(
            uid: 3,
            name: "Test User",
            sessionToken: "testSessionToken",
            isSuperuser: false,
            language: "en",
            timezone: "UTC",
            partnerID: PartnerID(id: 1, name: "Test Partner"),
            serverVersion: 15
        )
        
        service.requestAttachment(request: request, user: userData) { result in
            switch result {
            case .success(let messages):
                XCTAssertEqual(messages.count, 1)
                XCTAssertEqual(messages.first?.body, "Checkout message")
                XCTAssertEqual(messages.first?.attachmentIds, [])
                expectation.fulfill()
            case .failure:
                XCTFail("Expected success, got failure")
            }
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testFetchCheckOutMessagesFailure() {
        // Mock error response
        let error = NSError(domain: "MockError", code: -3, userInfo: [NSLocalizedDescriptionKey: "Mocked error"])
        mockRPCClient.mockResult = .failure(error)
        
        let expectation = XCTestExpectation(description: "Fetch checkout messages failure")
        
        let request = MailChannelMessageAction.fetchCheckOutMessages(channelID: 3, messagesIDs: [1, 2, 3])
        let userData = UserData(
            uid: 3,
            name: "Test User",
            sessionToken: "testSessionToken",
            isSuperuser: false,
            language: "en",
            timezone: "UTC",
            partnerID: PartnerID(id: 1, name: "Test Partner"), // или инициализируйте партнера, если он является сложным объектом
            serverVersion: 15
        )
        
        service.requestAttachment(request: request, user: userData) { result in
            switch result {
            case .success:
                XCTFail("Expected failure, got success")
            case .failure(let err):
                XCTAssertEqual((err as NSError).domain, "MockError")
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
}
