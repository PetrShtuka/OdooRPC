//
//  MailChannelServiceTests.swift
//  OdooRPC
//
//  Created by Peter on 28.10.2024.
//


import XCTest
@testable import OdooRPC

class MailChannelServiceTests: XCTestCase {
    var mockRPCClient: MockRPCClient!
    var mailChannelService: MailChannelService!
    var userData: UserData!
    
    // Setup method to initialize test dependencies
    override func setUp() {
        super.setUp()
        // Initialize a mock RPC client with a base URL
        mockRPCClient = MockRPCClient(baseURL: URL(string: "https://example.com")!)
        // Initialize the MailChannelService with the mock RPC client
        mailChannelService = MailChannelService(rpcClient: mockRPCClient)
        // Define user data used in tests
        userData = UserData(uid: 1, name: "Test User", sessionToken: "testToken", isSuperuser: false, language: "en_US", timezone: "UTC", partnerID: nil, serverVersion: 1)
    }
    
    // Teardown method to clean up after tests
    override func tearDown() {
        // Nullify dependencies to ensure clean state for each test
        mockRPCClient = nil
        mailChannelService = nil
        userData = nil
        super.tearDown()
    }
    
    // Test case to verify successful fetching of channels
    func testFetchChannelsSuccess() {
        // Inline JSON response simulating a successful fetch response
        let jsonData = """
        {
            "jsonrpc": "2.0",
            "id": 1,
            "result": {
                "records": [
                    {
                        "id": 1,
                        "write_date": null,
                        "name": "Test Channel",
                        "description": "A test channel",
                        "channel_type": "chat",
                        "avatar_128": null,
                        "channel_member_ids": [1, 2],
                        "is_member": true
                    }
                ]
            }
        }
        """.data(using: .utf8)!
        
        // Assign the JSON data to the mock RPC client’s result as a successful response
        mockRPCClient.mockResult = .success(jsonData)
        
        // Define an expectation for the asynchronous fetchChannels call
        let expectation = self.expectation(description: "Fetch Channels Success")
        
        // Call the fetchChannels method with a limit and userData
        mailChannelService.fetchChannels(limit: 1, language: userData.language ?? "", timezone: userData.timezone ?? "", uid: userData.uid ?? 0) { result in
            switch result {
            case .success(let channels):
                // Verify the count and name of the first fetched channel
                XCTAssertEqual(channels.count, 1)
                XCTAssertEqual(channels.first?.name, "Test Channel")
            case .failure(let error):
                // If fetch fails unexpectedly, record a failure in the test
                XCTFail("Expected success but got failure: \(error)")
            }
            expectation.fulfill()
        }
        
        // Wait until the expectation is fulfilled
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    // Test case to verify failure handling in fetchChannels
    func testFetchChannelsFailure() {
        // Create a mock error to simulate a fetch failure
        let error = NSError(domain: "TestErrorDomain", code: 1, userInfo: [NSLocalizedDescriptionKey: "Mock Error"])
        // Assign the error to the mock RPC client’s result
        mockRPCClient.mockResult = .failure(error)
        
        // Define an expectation for the asynchronous fetchChannels call
        let expectation = self.expectation(description: "Fetch Channels Failure")
        
        // Call the fetchChannels method
        mailChannelService.fetchChannels(limit: 10, language: userData.language ?? "", timezone: userData.timezone ?? "", uid: userData.uid ?? 0)  { result in
            switch result {
            case .success:
                // If fetch unexpectedly succeeds, record a failure
                XCTFail("Expected failure but got success")
            case .failure(let error):
                // Verify the error message matches the mock error
                XCTAssertEqual(error.localizedDescription, "Mock Error")
            }
            expectation.fulfill()
        }
        
        // Wait until the expectation is fulfilled
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    // Test case to verify successful fetching of channel members
    func testFetchChannelMembersSuccess() {
        // Inline JSON response simulating a successful member fetch response
        let jsonData = """
        {
            "jsonrpc": "2.0",
            "id": 1,
            "result": {
                "records": [
                    {
                        "last_interest_dt": null,
                        "partner_id": 1,
                        "guest_id": null,
                        "custom_channel_name": "Test Member",
                        "message_unread_counter": null,
                        "fetched_message_id": null,
                        "seen_message_id": null,
                        "last_seen_dt": null
                    }
                ]
            }
        }
        """.data(using: .utf8)!
        
        // Assign the JSON data to the mock RPC client’s result as a successful response
        mockRPCClient.mockResult = .success(jsonData)
        
        // Define an expectation for the asynchronous fetchChannelMembers call
        let expectation = self.expectation(description: "Fetch Channel Members Success")
        
        // Call the fetchChannelMembers method with a channel ID and userData
        mailChannelService.fetchChannelMembers(channelID: [1], language: userData.language ?? "", timezone: userData.timezone ?? "", uid: userData.uid ?? 0) { result in
            switch result {
            case .success(let members):
                // Verify the count and custom channel name of the first member
                XCTAssertEqual(members.count, 1)
            case .failure(let error):
                // If fetch fails unexpectedly, record a failure
                XCTFail("Expected success but got failure: \(error)")
            }
            expectation.fulfill()
        }
        
        // Wait until the expectation is fulfilled
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    // Test case to verify failure handling in fetchChannelMembers
    func testFetchChannelMembersFailure() {
        // Create a mock error to simulate a fetch failure
        let error = NSError(domain: "TestErrorDomain", code: 1, userInfo: [NSLocalizedDescriptionKey: "Mock Error"])
        // Assign the error to the mock RPC client’s result
        mockRPCClient.mockResult = .failure(error)
        
        // Define an expectation for the asynchronous fetchChannelMembers call
        let expectation = self.expectation(description: "Fetch Channel Members Failure")
        
        // Call the fetchChannelMembers method
        mailChannelService.fetchChannelMembers(channelID: [1], language: userData.language ?? "", timezone: userData.timezone ?? "", uid: userData.uid ?? 0) { result in
            switch result {
            case .success:
                // If fetch unexpectedly succeeds, record a failure
                XCTFail("Expected failure but got success")
            case .failure(let error):
                // Verify the error message matches the mock error
                XCTAssertEqual(error.localizedDescription, "Mock Error")
            }
            expectation.fulfill()
        }
        
        // Wait until the expectation is fulfilled
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    // Test case to verify successful loading of chats by ID
    func testLoadChatsByIdSuccess() {
        // Inline JSON response simulating a successful chat load by ID response
        let jsonData = """
        {
            "jsonrpc": "2.0",
            "id": 1,
            "result": {
                "records": [
                    {
                        "id": 1,
                        "write_date": null,
                        "name": "Chat Channel",
                        "description": "A chat channel",
                        "channel_type": "chat",
                        "avatar_128": null,
                        "channel_member_ids": [1, 2],
                        "is_member": true
                    }
                ]
            }
        }
        """.data(using: .utf8)!
        
        // Assign the JSON data to the mock RPC client’s result as a successful response
        mockRPCClient.mockResult = .success(jsonData)
        
        // Define an expectation for the asynchronous loadChatsById call
        let expectation = self.expectation(description: "Load Chats By Id Success")
        
        // Call the loadChatsById method with channel ID, comparison operator, and userData
        mailChannelService.loadChatsById(idChat: 1, comparison: ">", language: userData.language ?? "", timezone: userData.timezone ?? "", uid: userData.uid ?? 0) { result in
            switch result {
            case .success(let channels):
                // Verify the count and name of the loaded chat channel
                XCTAssertEqual(channels.count, 1)
                XCTAssertEqual(channels.first?.name, "Chat Channel")
            case .failure(let error):
                // If load fails unexpectedly, record a failure
                XCTFail("Expected success but got failure: \(error)")
            }
            expectation.fulfill()
        }
        
        // Wait until the expectation is fulfilled
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    // Test case to verify failure handling in loadChatsById
    func testLoadChatsByIdFailure() {
        // Create a mock error to simulate a load failure
        let error = NSError(domain: "TestErrorDomain", code: 1, userInfo: [NSLocalizedDescriptionKey: "Mock Error"])
        // Assign the error to the mock RPC client’s result
        mockRPCClient.mockResult = .failure(error)
        
        // Define an expectation for the asynchronous loadChatsById call
        let expectation = self.expectation(description: "Load Chats By Id Failure")
        
        // Call the loadChatsById method
        mailChannelService.loadChatsById(idChat: 1, comparison: ">", language: userData.language ?? "", timezone: userData.timezone ?? "", uid: userData.uid ?? 0) { result in
            switch result {
            case .success:
                // If load unexpectedly succeeds, record a failure
                XCTFail("Expected failure but got success")
            case .failure(let error):
                // Verify the error message matches the mock error
                XCTAssertEqual(error.localizedDescription, "Mock Error")
            }
            expectation.fulfill()
        }
        
        // Wait until the expectation is fulfilled
        waitForExpectations(timeout: 1, handler: nil)
    }
}
