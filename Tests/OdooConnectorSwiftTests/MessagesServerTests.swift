//
//  OdooRPCTests.swift
//  OdooRPCTests
//
//  Created by Peter on 23.10.2024.
//

import XCTest
@testable import OdooRPC

// Мок для RPCClient
class MockRPCClient: RPCClient {
    var mockResult: Result<Data, Error>?
    
    override func sendRPCRequest(endpoint: String, method: HTTPMethod, params: [String: Any], completion: @escaping (Result<Data, Error>) -> Void) -> URLSessionDataTask? {
        if let result = mockResult {
            completion(result)
        }
        return nil
    }
    
    override func sendAuthenticationRequest(endpoint: String, method: HTTPMethod, params: [String: Any], completion: @escaping (Result<Data, Error>) -> Void) -> URLSessionDataTask? {
        // Проверяем, совпадает ли endpoint и method с ожидаемыми
        if endpoint == "/web/session/authenticate" && method == .post {
            if let result = mockResult {
                completion(result)
            } else {
                let error = NSError(domain: "MockError", code: 0, userInfo: [NSLocalizedDescriptionKey: "No mock result provided."])
                completion(.failure(error))
            }
        } else {
            if let result = mockResult {
                completion(result)
            }
        }
        return nil
    }
}

class MessagesServerTests: XCTestCase {
    var messagesServer: MessagesServer!
    var mockRPCClient: MockRPCClient!
    
    override func setUp() {
        super.setUp()
        mockRPCClient = MockRPCClient(baseURL: URL(string: "https://example.com")!)
        messagesServer = MessagesServer(rpcClient: mockRPCClient)
    }
    
    override func tearDown() {
        messagesServer = nil
        mockRPCClient = nil
        super.tearDown()
    }
    
    // Тест успешного получения сообщений
    func testFetchMessagesSuccess() {
        // Подготовка данных для успешного ответа
        let jsonData = """
        {
            "jsonrpc": "2.0",
            "id": 1,
            "result": {
                "records": [
                    {
                        "id": 1,
                        "author_display": "John Doe",
                        "res_id": 123,
                        "needaction": false,
                        "active": true,
                        "partner_ids": [1, 2, 3],
                        "parent_id": [1, "Parent Message"],
                        "body": "Test message",
                        "record_name": "Test Record",
                        "email_from": "john.doe@example.com",
                        "display_name": "Test Message",
                        "delete_uid": false,
                        "model": "mail.message",
                        "author_avatar": null,
                        "author_id": [1, "John Doe"],
                        "starred": false,
                        "attachment_ids": [1, 2],
                        "ref_partner_ids": [3, 4],
                        "subtype_id": [1, "Note"],
                        "date": "2024-04-01"
                    }
                ]
            }
        }
        
        """.data(using: .utf8)!
        
        // Мокаем успешный результат
        mockRPCClient.mockResult = .success(jsonData)
        
        let request = MessageFetchRequest(
            operation: .privateInbox,
            messageId: 0,
            limit: 10,
            comparisonOperator: ">",
            selectedFields: [.id, .authorDisplay, .date, .body],
            language: "en",
            timeZone: "UTC",
            uid: 1,
            inboxType: .privateInbox
        )
        
        let expectation = self.expectation(description: "FetchMessagesSuccess")
        
        messagesServer.fetchMessages(request: request) { result in
            switch result {
            case .success(let messages):
                // Проверяем, что мы получили один результат
                XCTAssertEqual(messages.count, 1)
                XCTAssertEqual(messages.first?.authorDisplay, "John Doe")
                XCTAssertEqual(messages.first?.body, "Test message")
                expectation.fulfill()
            case .failure(let error):
                // Логируем ошибку для отладки
                XCTFail("Expected success, but got failure with error: \(error)")
            }
        }
        
        // Ждем выполнения асинхронной операции
        waitForExpectations(timeout: 1.0)
    }
    
    // Тест ошибки с сервера
    func testFetchMessagesServerError() {
        // Подготовка данных для ошибки с сервера
        let jsonData = """
        {
            "jsonrpc": "2.0",
            "id": 1,
            "error": {
                "code": 500,
                "message": "Internal server error"
            }
        }
        """.data(using: .utf8)!
        mockRPCClient.mockResult = .success(jsonData)
        
        let request = MessageFetchRequest(
            operation: .privateInbox,
            messageId: 0,
            limit: 10,
            comparisonOperator: ">",
            selectedFields: [.id, .authorDisplay, .date, .body],
            language: "en",
            timeZone: "UTC",
            uid: 1,
            inboxType: .privateInbox  // Добавлено
        )
        
        let expectation = self.expectation(description: "FetchMessagesServerError")
        
        messagesServer.fetchMessages(request: request) { result in
            switch result {
            case .success:
                XCTFail("Expected failure, but got success")
            case .failure(let error as NSError):
                XCTAssertEqual(error.domain, "OdooServerError")
                XCTAssertEqual(error.code, 500)
                XCTAssertEqual(error.localizedDescription, "Internal server error")
                expectation.fulfill()
            }
        }
        
        waitForExpectations(timeout: 1.0)
    }
    
    // Тест для пустого ответа
    func testFetchMessagesEmptyResponse() {
        // Подготовка данных для ответа с пустыми сообщениями
        let jsonData = """
        {
            "jsonrpc": "2.0",
            "id": 1,
            "result": {
                "records": []
            }
        }
        """.data(using: .utf8)!
        mockRPCClient.mockResult = .success(jsonData)
        
        let request = MessageFetchRequest(
            operation: .privateInbox,
            messageId: 0,
            limit: 10,
            comparisonOperator: ">",
            selectedFields: [.id, .authorDisplay, .date, .body],
            language: "en",
            timeZone: "UTC",
            uid: 1,
            inboxType: .privateInbox  // Добавлено
        )
        
        let expectation = self.expectation(description: "FetchMessagesEmptyResponse")
        
        messagesServer.fetchMessages(request: request) { result in
            switch result {
            case .success(let messages):
                XCTAssertEqual(messages.count, 0) // Ожидаем пустой массив
                expectation.fulfill()
            case .failure:
                XCTFail("Expected success, but got failure")
            }
        }
        
        waitForExpectations(timeout: 1.0)
    }
    
    // Тест для некорректного формата данных
    func testFetchMessagesInvalidDataFormat() {
        // Некорректный JSON-ответ
        let invalidJsonData = """
        {
            "invalid": "data"
        }
        """.data(using: .utf8)!
        mockRPCClient.mockResult = .success(invalidJsonData)
        
        let request = MessageFetchRequest(
            operation: .privateInbox,
            messageId: 0,
            limit: 10,
            comparisonOperator: ">",
            selectedFields: [.id, .authorDisplay, .date, .body],
            language: "en",
            timeZone: "UTC",
            uid: 1,
            inboxType: .privateInbox  // Добавлено
        )
        
        let expectation = self.expectation(description: "FetchMessagesInvalidDataFormat")
        
        messagesServer.fetchMessages(request: request) { result in
            switch result {
            case .success:
                XCTFail("Expected failure due to invalid data format, but got success")
            case .failure:
                expectation.fulfill()
            }
        }
        
        waitForExpectations(timeout: 1.0)
    }
    
    // Тест для сетевой ошибки (например, таймаут)
    func testFetchMessagesNetworkError() {
        // Сетевой сбой
        let networkError = NSError(domain: NSURLErrorDomain, code: NSURLErrorTimedOut, userInfo: nil)
        mockRPCClient.mockResult = .failure(networkError)
        
        let request = MessageFetchRequest(
            operation: .privateInbox,
            messageId: 0,
            limit: 10,
            comparisonOperator: ">",
            selectedFields: [.id, .authorDisplay, .date, .body],
            language: "en",
            timeZone: "UTC",
            uid: 1,
            inboxType: .privateInbox  // Добавлено
        )
        
        let expectation = self.expectation(description: "FetchMessagesNetworkError")
        
        messagesServer.fetchMessages(request: request) { result in
            switch result {
            case .success:
                XCTFail("Expected failure due to network error, but got success")
            case .failure(let error as NSError):
                XCTAssertEqual(error.domain, NSURLErrorDomain)
                XCTAssertEqual(error.code, NSURLErrorTimedOut)
                expectation.fulfill()
            }
        }
        
        waitForExpectations(timeout: 1.0)
    }
    
    func testFetchNewMessages() {
        let jsonData = """
        {
            "jsonrpc": "2.0",
            "id": 1,
            "result": {
                "records": [
                    {
                        "id": 100,
                        "author_display": "Mark Smith",
                        "res_id": 125,
                        "needaction": false,
                        "active": true,
                        "partner_ids": [3, 4],
                        "parent_id": [3, "New Parent Message"],
                        "body": "New message",
                        "record_name": "New Record",
                        "email_from": "mark.smith@example.com",
                        "display_name": "New Message",
                        "delete_uid": false,
                        "model": "mail.message",
                        "author_avatar": null,
                        "author_id": false,
                        "starred": false,
                        "attachment_ids": [4, 5],
                        "ref_partner_ids": [6, 7],
                        "subtype_id": [3, "Comment"],
                        "date": "2024-05-01"
                    }
                ]
            }
        }
        
        """.data(using: .utf8)!
        
        mockRPCClient.mockResult = .success(jsonData)
        
        let request = MessageFetchRequest(
            operation: .privateInbox,
            messageId: 50, // Получаем новые сообщения с ID больше 50
            limit: 10,
            comparisonOperator: ">",
            selectedFields: [.id, .authorDisplay, .date, .body],
            language: "en",
            timeZone: "UTC",
            uid: 1,
            inboxType: .privateInbox
        )
        
        let expectation = self.expectation(description: "FetchNewMessages")
        
        messagesServer.fetchMessages(request: request) { result in
            switch result {
            case .success(let messages):
                XCTAssertEqual(messages.count, 1)
                XCTAssertEqual(messages.first?.id, 100) // Проверяем, что ID сообщения больше
                XCTAssertEqual(messages.first?.authorDisplay, "Mark Smith")
                XCTAssertEqual(messages.first?.body, "New message")
                expectation.fulfill()
            case .failure(let error):
                XCTFail("Expected success, but got failure with error: \(error)")
            }
        }
        
        waitForExpectations(timeout: 1.0)
    }
    
    func testFetchOldMessages() {
        let jsonData = """
        {
            "jsonrpc": "2.0",
            "id": 1,
            "result": {
                "records": [
                    {
                        "id": 10,
                        "author_display": "Jane Doe",
                        "res_id": 124,
                        "needaction": false,
                        "active": true,
                        "partner_ids": [1, 2],
                        "parent_id": [2, "Old Parent Message"],
                        "body": "Old message",
                        "record_name": "Old Record",
                        "email_from": "jane.doe@example.com",
                        "display_name": "Old Message",
                        "delete_uid": false,
                        "model": "mail.message",
                        "author_avatar": null,
                                               "author_id": false, 
                        "starred": false,
                        "attachment_ids": [2, 3],
                        "ref_partner_ids": [4, 5],
                        "subtype_id": [2, "Task"],
                        "date": "2024-03-01"
                    }
                ]
            }
        }
        
        """.data(using: .utf8)!
        
        mockRPCClient.mockResult = .success(jsonData)
        
        let request = MessageFetchRequest(
            operation: .privateInbox,
            messageId: 50, // Получаем старые сообщения с ID меньше 50
            limit: 10,
            comparisonOperator: "<",
            selectedFields: [.id, .authorDisplay, .date, .body],
            language: "en",
            timeZone: "UTC",
            uid: 1,
            inboxType: .privateInbox
        )
        
        let expectation = self.expectation(description: "FetchOldMessages")
        
        messagesServer.fetchMessages(request: request) { result in
            switch result {
            case .success(let messages):
                XCTAssertEqual(messages.count, 1)
                XCTAssertEqual(messages.first?.id, 10) // Проверяем, что ID сообщения меньше
                XCTAssertEqual(messages.first?.authorDisplay, "Jane Doe")
                XCTAssertEqual(messages.first?.body, "Old message")
                expectation.fulfill()
            case .failure(let error):
                XCTFail("Expected success, but got failure with error: \(error)")
            }
        }
        
        waitForExpectations(timeout: 1.0)
    }
    
    func testDeleteMessage() {
        let jsonData = """
        {
            "jsonrpc": "2.0",
            "id": 1,
            "result": {
                "records": [
                    {
                        "id": 1,
                        "author_display": "John Doe",
                        "res_id": 123,
                        "needaction": false,
                        "active": false,
                        "partner_ids": [1, 2, 3],
                        "parent_id": [1, "Parent Message"],
                        "body": "Test message",
                        "record_name": "Test Record",
                        "email_from": "john.doe@example.com",
                        "display_name": "Test Message",
                        "delete_uid": true,
                        "model": "mail.message",
                        "author_avatar": null,
                        "author_id": [1, "John Doe"], 
                        "starred": false,
                        "attachment_ids": [1, 2],
                        "ref_partner_ids": [3, 4],
                        "subtype_id": [1, "Note"],
                        "date": "2024-04-01"
                    }
                ]
            }
        }
        """.data(using: .utf8)!
        
        mockRPCClient.mockResult = .success(jsonData)
        
        let request = MessageFetchRequest(
            operation: .privateInbox,
            messageId: 0,
            limit: 10,
            comparisonOperator: "=",
            selectedFields: [.id, .authorDisplay, .body],
            language: "en",
            timeZone: "UTC",
            uid: 1,
            inboxType: .privateInbox
        )
        
        let expectation = self.expectation(description: "DeleteMessage")
        
        messagesServer.fetchMessages(request: request) { result in
            switch result {
            case .success(let messages):
                XCTAssertEqual(messages.count, 1)
                XCTAssertFalse(messages.first!.active) // Сообщение не активно
                XCTAssertTrue(messages.first!.deleteUID) // Сообщение помечено как удаленное
                expectation.fulfill()
            case .failure(let error):
                XCTFail("Expected success, but got failure with error: \(error)")
            }
        }
        
        waitForExpectations(timeout: 1.0)
    }
    
    func testArchiveMessage() {
        let jsonData = """
        {
            "jsonrpc": "2.0",
            "id": 1,
            "result": {
                "records": [
                    {
                        "id": 2,
                        "author_display": "Jane Smith",
                        "res_id": 124,
                        "needaction": false,
                        "active": false,
                        "partner_ids": [1, 2, 3],
                        "parent_id": [2, "Archived Parent Message"],
                        "body": "Archived message",
                        "record_name": "Archived Record",
                        "email_from": "jane.smith@example.com",
                        "display_name": "Archived Message",
                        "delete_uid": false,
                        "model": "mail.message",
                        "author_avatar": null,
                        "author_id": [2, "Jane Smith"],
                        "starred": false,
                        "attachment_ids": [1, 2],
                        "ref_partner_ids": [3, 4],
                        "subtype_id": [2, "Note"],
                        "date": "2024-02-01"
                    }
                ]
            }
        }
        """.data(using: .utf8)!
        
        mockRPCClient.mockResult = .success(jsonData)
        
        let request = MessageFetchRequest(
            operation: .privateInbox,
            messageId: 0,
            limit: 10,
            comparisonOperator: "=",
            selectedFields: [.id, .authorDisplay, .body],
            language: "en",
            timeZone: "UTC",
            uid: 1,
            inboxType: .privateInbox
        )
        
        let expectation = self.expectation(description: "ArchiveMessage")
        
        messagesServer.fetchMessages(request: request) { result in
            switch result {
            case .success(let messages):
                XCTAssertEqual(messages.count, 1)
                XCTAssertFalse(messages.first!.active) // Сообщение не активно
                XCTAssertFalse(messages.first!.deleteUID) // Сообщение заархивировано, но не удалено
                expectation.fulfill()
            case .failure(let error):
                XCTFail("Expected success, but got failure with error: \(error)")
            }
        }
        
        waitForExpectations(timeout: 1.0)
    }
    
    func testReadMessage() {
        let jsonData = """
        {
            "jsonrpc": "2.0",
            "id": 1,
            "result": {
                "records": [
                    {
                        "id": 3,
                        "author_display": "Alice Doe",
                        "res_id": 126,
                        "needaction": false,
                        "active": false,
                        "partner_ids": [5, 6],
                        "parent_id": [3, "Read Parent Message"],
                        "body": "Read message",
                        "record_name": "Read Record",
                        "email_from": "alice.doe@example.com",
                        "display_name": "Read Message",
                        "delete_uid": false,
                        "model": "mail.message",
                        "author_avatar": null,
                        "author_id": false,
                        "starred": false,
                        "attachment_ids": [5, 6],
                        "ref_partner_ids": [7, 8],
                        "subtype_id": [4, "Discussion"],
                        "date": "2024-06-01"
                    }
                ]
            }
        }
        
        """.data(using: .utf8)!
        
        mockRPCClient.mockResult = .success(jsonData)
        
        let request = MessageFetchRequest(
            operation: .privateInbox,
            messageId: 0,
            limit: 10,
            comparisonOperator: "=",
            selectedFields: [.id, .authorDisplay, .body],
            language: "en",
            timeZone: "UTC",
            uid: 1,
            inboxType: .privateInbox
        )
        
        let expectation = self.expectation(description: "ReadMessage")
        
        messagesServer.fetchMessages(request: request) { result in
            switch result {
            case .success(let messages):
                XCTAssertEqual(messages.count, 1)
                XCTAssertFalse(messages.first!.active) // Сообщение не активно
                XCTAssertFalse(messages.first!.deleteUID) // Сообщение прочитано
                expectation.fulfill()
            case .failure(let error):
                XCTFail("Expected success, but got failure with error: \(error)")
            }
        }
        
        waitForExpectations(timeout: 1.0)
    }
    
    // Тест для поиска сообщений по теме (subject)
    func testSearchMessagesBySubject() {
        let jsonData = """
           {
               "jsonrpc": "2.0",
               "id": 1,
               "result": {
                   "records": [
                       {
                           "id": 4,
                           "author_display": "Alice Johnson",
                           "res_id": 127,
                           "needaction": false,
                           "active": true,
                           "partner_ids": [7, 8],
                           "parent_id": [4, "Search Parent Message"],
                           "body": "Search result message",
                           "record_name": "Search Record",
                           "email_from": "alice.johnson@example.com",
                           "display_name": "Search Message",
                           "delete_uid": false,
                           "model": "mail.message",
                           "author_avatar": null,
                           "author_id": false,
                           "starred": false,
                           "attachment_ids": [7, 8],
                           "ref_partner_ids": [9, 10],
                           "subtype_id": [4, "Discussion"],
                           "date": "2024-07-01"
                       }
                   ]
               }
           }
           """.data(using: .utf8)!
        
        mockRPCClient.mockResult = .success(jsonData)
        
        let request = MessageFetchRequest(
            operation: .privateInbox,
            messageId: 0,
            limit: 10,
            comparisonOperator: "=",
            requestText: "Search Message",
            selectedFields: [.id, .authorDisplay, .subject, .body],
            language: "en",
            timeZone: "UTC",
            uid: 1,
            selectFilter: .subject,
            inboxType: .sharedInbox
        )
        
        let expectation = self.expectation(description: "SearchMessagesBySubject")
        
        messagesServer.searchMessages(request: request) { result in
            switch result {
            case .success(let messages):
                XCTAssertEqual(messages.count, 1)
                XCTAssertEqual(messages.first?.id, 4)
                XCTAssertEqual(messages.first?.authorDisplay, "Alice Johnson")
                XCTAssertEqual(messages.first?.body, "Search result message")
                expectation.fulfill()
            case .failure(let error):
                XCTFail("Expected success, but got failure with error: \(error)")
            }
        }
        
        waitForExpectations(timeout: 1.0)
    }
    
    // Тест для поиска сообщений по содержимому (body)
    func testSearchMessagesByContent() {
        let jsonData = """
           {
               "jsonrpc": "2.0",
               "id": 1,
               "result": {
                   "records": [
                       {
                           "id": 5,
                           "author_display": "Bob Smith",
                           "res_id": 128,
                           "needaction": false,
                           "active": true,
                           "partner_ids": [9, 10],
                           "parent_id": [5, "Content Parent Message"],
                           "body": "This is the message content",
                           "record_name": "Content Record",
                           "email_from": "bob.smith@example.com",
                           "display_name": "Content Message",
                           "delete_uid": false,
                           "model": "mail.message",
                           "author_avatar": null,
                           "author_id": false,
                           "starred": false,
                           "attachment_ids": [10, 11],
                           "ref_partner_ids": [12, 13],
                           "subtype_id": [5, "Note"],
                           "date": "2024-08-01"
                       }
                   ]
               }
           }
           """.data(using: .utf8)!
        
        mockRPCClient.mockResult = .success(jsonData)
        
        let request = MessageFetchRequest(
            operation: .privateInbox,
            messageId: 0,
            limit: 10,
            comparisonOperator: "=",
            requestText: "This is the message content",
            selectedFields: [.id, .authorDisplay, .body],
            language: "en",
            timeZone: "UTC",
            uid: 1,
            selectFilter: .content,
            inboxType: .sharedInbox
        )
        
        let expectation = self.expectation(description: "SearchMessagesByContent")
        
        messagesServer.searchMessages(request: request) { result in
            switch result {
            case .success(let messages):
                XCTAssertEqual(messages.count, 1)
                XCTAssertEqual(messages.first?.id, 5)
                XCTAssertEqual(messages.first?.authorDisplay, "Bob Smith")
                XCTAssertEqual(messages.first?.body, "This is the message content")
                expectation.fulfill()
            case .failure(let error):
                XCTFail("Expected success, but got failure with error: \(error)")
            }
        }
        
        waitForExpectations(timeout: 1.0)
    }
    
    // Тест для поиска сообщений по автору (author)
    func testSearchMessagesByAuthor() {
        let jsonData = """
           {
               "jsonrpc": "2.0",
               "id": 1,
               "result": {
                   "records": [
                       {
                           "id": 6,
                           "author_display": "Chris Evans",
                           "res_id": 129,
                           "needaction": false,
                           "active": true,
                           "partner_ids": [11, 12],
                           "parent_id": [6, "Author Parent Message"],
                           "body": "Author test message",
                           "record_name": "Author Record",
                           "email_from": "chris.evans@example.com",
                           "display_name": "Author Message",
                           "delete_uid": false,
                           "model": "mail.message",
                           "author_avatar": null,
                           "author_id": [6, "Chris Evans"],
                           "starred": false,
                           "attachment_ids": [13, 14],
                           "ref_partner_ids": [15, 16],
                           "subtype_id": [6, "Task"],
                           "date": "2024-09-01"
                       }
                   ]
               }
           }
           """.data(using: .utf8)!
        
        mockRPCClient.mockResult = .success(jsonData)
        
        let request = MessageFetchRequest(
            operation: .privateInbox,
            messageId: 0,
            limit: 10,
            comparisonOperator: "=",
            requestText: "Chris Evans",
            selectedFields: [.id, .authorDisplay, .body],
            language: "en",
            timeZone: "UTC",
            uid: 1,
            selectFilter: .author,
            inboxType: .sharedInbox
        )
        
        let expectation = self.expectation(description: "SearchMessagesByAuthor")
        
        messagesServer.searchMessages(request: request) { result in
            switch result {
            case .success(let messages):
                XCTAssertEqual(messages.count, 1)
                XCTAssertEqual(messages.first?.id, 6)
                XCTAssertEqual(messages.first?.authorDisplay, "Chris Evans")
                XCTAssertEqual(messages.first?.body, "Author test message")
                expectation.fulfill()
            case .failure(let error):
                XCTFail("Expected success, but got failure with error: \(error)")
            }
        }
        
        waitForExpectations(timeout: 1.0)
    }
    
    // Тест для поиска сообщений по получателям (recipients)
    func testSearchMessagesByRecipients() {
        let jsonData = """
           {
               "jsonrpc": "2.0",
               "id": 1,
               "result": {
                   "records": [
                       {
                           "id": 7,
                           "author_display": "David Lee",
                           "res_id": 130,
                           "needaction": false,
                           "active": true,
                           "partner_ids": [17, 18],
                           "parent_id": [7, "Recipients Parent Message"],
                           "body": "Recipient message",
                           "record_name": "Recipients Record",
                           "email_from": "david.lee@example.com",
                           "display_name": "Recipients Message",
                           "delete_uid": false,
                           "model": "mail.message",
                           "author_avatar": null,
                           "author_id": [7, "David Lee"],
                           "starred": false,
                           "attachment_ids": [15, 16],
                           "ref_partner_ids": [17, 18],
                           "subtype_id": [7, "Comment"],
                           "date": "2024-10-01"
                       }
                   ]
               }
           }
           """.data(using: .utf8)!
        
        mockRPCClient.mockResult = .success(jsonData)
        
        let request = MessageFetchRequest(
            operation: .privateInbox,
            messageId: 0,
            limit: 10,
            comparisonOperator: "=",
            requestText: "17",  // Ищем по partner_id
            selectedFields: [.id, .authorDisplay, .body, .partnerIDs],
            language: "en",
            timeZone: "UTC",
            uid: 1,
            selectFilter: .recipients,
            inboxType: .sharedInbox
        )
        
        let expectation = self.expectation(description: "SearchMessagesByRecipients")
        
        messagesServer.searchMessages(request: request) { result in
            switch result {
            case .success(let messages):
                XCTAssertEqual(messages.count, 1)
                XCTAssertEqual(messages.first?.id, 7)
                XCTAssertEqual(messages.first?.authorDisplay, "David Lee")
                XCTAssertEqual(messages.first?.body, "Recipient message")
                XCTAssertEqual(messages.first?.partnerIDs, [17, 18])  // Проверяем partner_ids
                expectation.fulfill()
            case .failure(let error):
                XCTFail("Expected success, but got failure with error: \(error)")
            }
        }
        
        waitForExpectations(timeout: 1.0)
    }
}
