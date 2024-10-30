//
//  MessageFetchRequest.swift
//  OdooRPC
//
//  Created by Peter on 28.10.2024.
//

public struct MessageFetchRequest {
    public var operation: MailboxOperation
    public var messageId: Int
    public var limit: Int
    public var comparisonOperator: String
    public var partnerUserId: Int?
    public var requestText: String?
    public var localMessagesID: [Int]?
    public var selectedFields: Set<MessageField> = Set(MessageField.allCases)
    public var language: String
    public var timeZone: String
    public var uid: Int
    public var selectFilter: FilterTypeMessage = .none
    public var isActive: Bool?
    public var isNotDeleted: Bool?
    public var inboxType: MailboxOperation

    public init(operation: MailboxOperation, messageId: Int, limit: Int, comparisonOperator: String, partnerUserId: Int? = nil, requestText: String? = nil, localMessagesID: [Int]? = nil, selectedFields: Set<MessageField>, language: String, timeZone: String, uid: Int, selectFilter: FilterTypeMessage = .none, isActive: Bool? = nil, isNotDeleted: Bool? = nil, inboxType: MailboxOperation) {
        self.operation = operation
        self.messageId = messageId
        self.limit = limit
        self.comparisonOperator = comparisonOperator
        self.partnerUserId = partnerUserId
        self.requestText = requestText
        self.localMessagesID = localMessagesID
        self.selectedFields = selectedFields
        self.language = language
        self.timeZone = timeZone
        self.uid = uid
        self.selectFilter = selectFilter
        self.isActive = isActive
        self.isNotDeleted = isNotDeleted
        self.inboxType = inboxType
    }
}
