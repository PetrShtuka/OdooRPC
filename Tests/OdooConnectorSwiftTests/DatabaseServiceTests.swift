//
//  DatabaseServiceTests.swift
//  OdooRPC
//
//  Created by Peter on 23.10.2024.
//

import XCTest
@testable import OdooRPC

class DatabaseServiceTests: XCTestCase {
    var databaseService: DatabaseService!
    var mockRPCClient: MockRPCClient!
    
    override func setUp() {
        super.setUp()
        mockRPCClient = MockRPCClient(baseURL: URL(string: "https://example.com")!)
        databaseService = DatabaseService(rpcClient: mockRPCClient)
    }
    
    override func tearDown() {
        databaseService = nil
        mockRPCClient = nil
        super.tearDown()
    }
    
    // Тест успешного получения списка баз данных
    func testListDatabasesSuccess() {
        let jsonData = """
        {
            "jsonrpc": "2.0",
            "id": 1,
            "result": ["db1", "db2", "db3"]
        }
        """.data(using: .utf8)!
        
        mockRPCClient.mockResult = .success(jsonData)
        
        databaseService.listDatabases { result in
            switch result {
            case .success(let databases):
                XCTAssertEqual(databases, ["db1", "db2", "db3"])
            case .failure(let error):
                XCTFail("Ожидали успех, но получили ошибку: \(error)")
            }
        }
    }
    
    // Тест неуспешного получения списка баз данных
    func testListDatabasesFailure() {
        let mockError = NSError(domain: "NetworkError", code: -1, userInfo: nil)
        mockRPCClient.mockResult = .failure(mockError)
        
        let expectation = self.expectation(description: "Неудача при получении списка баз данных")
        
        databaseService.listDatabases { result in
            switch result {
            case .success:
                XCTFail("Ожидали ошибку, но получили успех")
            case .failure(let error as NSError):
                XCTAssertEqual(error.domain, "NetworkError")
                XCTAssertEqual(error.code, -1)
                expectation.fulfill()
            }
        }
        
        waitForExpectations(timeout: 1.0)
    }
}
