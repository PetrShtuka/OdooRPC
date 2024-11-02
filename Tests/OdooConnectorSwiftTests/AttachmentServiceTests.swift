//
//  AttachmentServiceTests.swift
//  OdooRPC
//
//  Created by Peter on 28.10.2024.
//

import XCTest
@testable import OdooRPC

class AttachmentServiceTests: XCTestCase {
    
    var rpcClientMock: MockRPCClient!
    var attachmentService: AttachmentService!
    
    // Setup method to initialize the mock client and attachment service before each test
    override func setUp() {
        super.setUp()
        rpcClientMock = MockRPCClient(baseURL: URL(string: "https://example.com")!)
        attachmentService = AttachmentService(rpcClient: rpcClientMock)
    }
    
    // Test for successfully fetching an attachment
    func testFetchAttachmentSuccess() {
        // Arrange: Prepare expected attachment and mock JSON response
        let expectedAttachment = AttachmentModel(id: 1)
        let mockData = try! JSONSerialization.data(withJSONObject: [
            "jsonrpc": "2.0",
            "result": [
                ["id": 1]
            ]
        ], options: [])
        
        rpcClientMock.mockResult = .success(mockData)
        
        let expectation = self.expectation(description: "Fetch attachment")
        
        // Act: Call the fetchAttachment method
        attachmentService.fetchAttachment(request: .fetch(idAttachment: 1, includeData: false), userID: 123) { result in
            switch result {
            case .success(let attachments):
                // Assert: Verify the attachment data is as expected
                XCTAssertEqual(attachments.count, 1)
                XCTAssertEqual(attachments.first?.id, expectedAttachment.id)
            case .failure:
                XCTFail("Expected success but got failure")
            }
            expectation.fulfill()
        }
        
        // Wait for the expectations to be fulfilled
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    // Test for failure when fetching an attachment
    func testFetchAttachmentFailure() {
        // Arrange: Simulate a server error
        rpcClientMock.mockResult = .failure(NSError(domain: "OdooServerError", code: 404, userInfo: [NSLocalizedDescriptionKey: "Not found"]))
        
        let expectation = self.expectation(description: "Fetch attachment failure")
        
        // Act: Call the fetchAttachment method
        attachmentService.fetchAttachment(request: .fetch(idAttachment: 1, includeData: false), userID: 123) { result in
            switch result {
            case .success:
                XCTFail("Expected failure but got success")
            case .failure(let error):
                // Assert: Verify error message is correct
                XCTAssertEqual(error.localizedDescription, "Not found")
            }
            expectation.fulfill()
        }
        
        // Wait for the expectations to be fulfilled
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    // Test for successfully uploading an attachment
    func testUploadAttachmentSuccess() {
        // Arrange: Prepare mock attachment data and JSON response
        let filename = "test.txt"
        let fileData = Data("Test data".utf8).base64EncodedString()
        let model = "test.model"
        let resId = 1
        
        rpcClientMock.mockResult = .success(try! JSONSerialization.data(withJSONObject: [
            "jsonrpc": "2.0",
            "result": 1
        ], options: []))
        
        let expectation = self.expectation(description: "Upload attachment")
        
        // Act: Call the uploadAttachment method
        attachmentService.fetchAttachment(request: .uploadAttachment(filename: filename, fileData: fileData, model: model, resId: resId), userID: 123) { result in
            switch result {
            case .success(let attachments):
                // Assert: Verify uploaded attachment data is as expected
                XCTAssertEqual(attachments.count, 1)
                XCTAssertEqual(attachments.first?.id, 1)
            case .failure:
                XCTFail("Expected success but got failure")
            }
            expectation.fulfill()
        }
        
        // Wait for the expectations to be fulfilled
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    // Test for failure when uploading an attachment
    func testUploadAttachmentFailure() {
        // Arrange: Prepare mock attachment data
        let filename = "test.txt"
        let fileData = Data("Test data".utf8).base64EncodedString()
        let model = "test.model"
        let resId = 1
        
        rpcClientMock.mockResult = .failure(NSError(domain: "OdooServerError", code: 500, userInfo: [NSLocalizedDescriptionKey: "Server error"]))
        
        let expectation = self.expectation(description: "Upload attachment failure")
        
        // Act: Call the uploadAttachment method
        attachmentService.fetchAttachment(request: .uploadAttachment(filename: filename, fileData: fileData, model: model, resId: resId), userID: 123) { result in
            switch result {
            case .success:
                XCTFail("Expected failure but got success")
            case .failure(let error):
                // Assert: Verify error message is correct
                XCTAssertEqual(error.localizedDescription, "Server error")
            }
            expectation.fulfill()
        }
        
        // Wait for the expectations to be fulfilled
        waitForExpectations(timeout: 1, handler: nil)
    }
}
