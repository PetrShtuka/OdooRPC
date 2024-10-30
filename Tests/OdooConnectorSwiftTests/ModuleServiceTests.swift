//
//  ModuleServiceTests.swift
//  OdooRPC
//
//  Created by Peter on 30.10.2024.
//

import XCTest
@testable import OdooRPC

class ModuleServiceTests: XCTestCase {
    
    var rpcClientMock: MockRPCClient!
    var moduleService: ModuleService!
    
    // Setup method to initialize the mock client and module service before each test
    override func setUp() {
        super.setUp()
        rpcClientMock = MockRPCClient(baseURL: URL(string: "https://example.com")!)
        moduleService = ModuleService(rpcClient: rpcClientMock)
    }
    
    // Test for successfully loading module information from the server
    func testLoadModulesSuccess() {
        // Arrange: Setting up mock module names
        let mockModuleNames = ["prt_mail_messages", "cetmix_communicator"]
        rpcClientMock.mockResult = .success(try! JSONSerialization.data(withJSONObject: mockModuleNames, options: []))
        
        let expectation = self.expectation(description: "Load modules success")
        
        // Act: Attempting to load modules from the server
        moduleService.loadModulesServer { result in
            switch result {
            case .success(let moduleStatus):
                // Assert: Check if the module status is correctly set
                XCTAssertTrue(moduleStatus.mailMessages)
                XCTAssertFalse(moduleStatus.mailMessagesPro)
                XCTAssertTrue(moduleStatus.cetmixCommunicator)
            case .failure:
                XCTFail("Expected success but got failure")
            }
            expectation.fulfill()
        }
        
        // Wait for the expectations to be fulfilled
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    // Test for handling failure when loading module information from the server
    func testLoadModulesFailure() {
        // Arrange: Setting up a failure response
        rpcClientMock.mockResult = .failure(NSError(domain: "NetworkError", code: -1, userInfo: nil))
        
        let expectation = self.expectation(description: "Load modules failure")
        
        // Act: Attempting to load modules from the server
        moduleService.loadModulesServer { result in
            switch result {
            case .success:
                XCTFail("Expected failure but got success")
            case .failure(let error as NSError):
                // Assert: Check if the error domain is as expected
                XCTAssertEqual(error.domain, "NetworkError")
            }
            expectation.fulfill()
        }
        
        // Wait for the expectations to be fulfilled
        waitForExpectations(timeout: 1, handler: nil)
    }
}
