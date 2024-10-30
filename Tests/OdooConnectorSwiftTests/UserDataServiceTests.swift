//
//  UserDataServiceTests.swift
//  OdooRPC
//
//  Created by Peter on 29.10.2024.
//

import XCTest
@testable import OdooRPC

class UserDataServiceTests: XCTestCase {
    
    var rpcClientMock: MockRPCClient!
    var userDataService: UserDataService!
    
    override func setUp() {
        super.setUp()
        rpcClientMock = MockRPCClient(baseURL: URL(string: "https://example.com")!)
        userDataService = UserDataService(rpcClient: rpcClientMock)
    }
    
    func testFetchUserDataSuccess() {
        // Arrange
        let uid = 1
        let expectedUserData = UserData(
            uid: uid,
            name: "John Doe",
            sessionToken: "sessionToken",
            isSuperuser: true,
            language: "en_US",
            timezone: "Europe/Rome",
            partnerID: PartnerID(id: 2, name: "Partner Name"),
            serverVersion: 16
        )
        
        let jsonResponse: [String: Any] = [
            "jsonrpc": "2.0",
            "result": [
                [
                    "uid": 1,
                    "name": "John Doe",
                    "session_id": "sessionToken",
                    "is_superuser": true,
                    "lang": "en_US",
                    "tz": "Europe/Rome",
                    "partner_id": [2, "Partner Name"],
                    "avatar_128": "base64avatar"
                ]
            ]
        ]
        
        rpcClientMock.mockResult = .success(try! JSONSerialization.data(withJSONObject: jsonResponse, options: []))
        
        let expectation = self.expectation(description: "Fetch user data")
        
        // Act
        userDataService.fetchUserData(uid: uid) { result in
            switch result {
            case .success(let userData):
                XCTAssertEqual(userData.uid, expectedUserData.uid)
                XCTAssertEqual(userData.name, expectedUserData.name)
                XCTAssertEqual(userData.sessionToken, expectedUserData.sessionToken)
                XCTAssertEqual(userData.isSuperuser, expectedUserData.isSuperuser)
                XCTAssertEqual(userData.language, expectedUserData.language)
                XCTAssertEqual(userData.timezone, expectedUserData.timezone)
                XCTAssertEqual(userData.partnerID?.id, expectedUserData.partnerID?.id)
            case .failure:
                XCTFail("Expected success but got failure")
            }
            expectation.fulfill()
        }
        
        // Assert
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testFetchUserDataFailure() {
        // Arrange
        let userId = 1
        let errorResponse: [String: Any] = [
            "jsonrpc": "2.0",
            "error": [
                "code": 404,
                "message": "User not found"
            ]
        ]
        
        rpcClientMock.mockResult = .failure(NSError(domain: "OdooServerError", code: -1))
        
        let expectation = self.expectation(description: "Fetch user data failure")
        
        // Act
        userDataService.fetchUserData(uid: userId) { result in
            switch result {
            case .success:
                XCTFail("Expected failure but got success")
            case .failure(let error as NSError):
                XCTAssertEqual(error.domain, "OdooServerError")
                XCTAssertEqual(error.localizedDescription, "The operation couldn’t be completed. (OdooServerError error -1.)")
            }
            expectation.fulfill()
        }
        
        // Assert
        waitForExpectations(timeout: 1, handler: nil)
    }
}
