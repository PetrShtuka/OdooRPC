//
//  MobileSentMessage.swift
//  Oodo Messenger
//
//  Created by Peter on 14.02.2023.
//

import Foundation

public struct PrepareParameters {
    let user: UserData
    let replayMessage: MessageModel
    let typeEmail: MessageSendType
    let type: MailboxItem
    let attachments: [AttachmentModel]
    let selectPartnersEmail: [ContactsModel]
    let selectPartnersCc: [ContactsModel]
    let selectPartnersBcc: [ContactsModel]
    let messagesBody: String
    let subject: String?
}

public struct MobileSentMessage {
    public var messageId: Int = 1
    public var userId: String = ""
    public var authorDisplay: String = ""
    public var authorId: Int = 0
    public var selectedPartners: [[Int]] = [[]]
    public var selectedPartnersCc: [[Int]] = [[]]
    public var selectedPartnersBcc: [[Int]] = [[]]
    public var attachments: [[Int]] = [[]]
    public var avatarAuthor: String = ""
    public var dateSent: String = Date().description
    public var categories: String = ""
    public var recordName: String = ""
    public var models: String = ""
    public var resId: Int?
    public var isSent: Bool = false
    public var oldBody: String = ""
    public var body: String = ""
    public var subject: String = ""
    public var wizardType: String = ""
    public var parentId: Int = 0
    
    public init(messageId: Int = 1, userId: String = "", authorDisplay: String = "", authorId: Int = 0, selectedPartners: [[Int]] = [[]], selectedPartnersCc: [[Int]] = [[]], selectedPartnersBcc: [[Int]] = [[]], attachments: [[Int]] = [[]], avatarAuthor: String = "", dateSent: String = Date().description, categories: String = "", recordName: String = "", models: String = "", resId: Int?, isSent: Bool = false, oldBody: String = "", body: String = "", subject: String = "", wizardType: String = "", parentId: Int = 0) {
        self.messageId = messageId
        self.userId = userId
        self.authorDisplay = authorDisplay
        self.authorId = authorId
        self.selectedPartners = selectedPartners
        self.selectedPartnersCc = selectedPartnersCc
        self.selectedPartnersBcc = selectedPartnersBcc
        self.attachments = attachments
        self.avatarAuthor = avatarAuthor
        self.dateSent = dateSent
        self.categories = categories
        self.recordName = recordName
        self.models = models
        self.resId = resId
        self.isSent = isSent
        self.oldBody = oldBody
        self.body = body
        self.subject = subject
        self.wizardType = wizardType
        self.parentId = parentId
    }
    
    public func createMessageModel() -> [MobileSentMessage] {
        var sentMessages: [MobileSentMessage] = []
        
        let message = MobileSentMessage(messageId: self.messageId,
                                        userId: self.userId,
                                        authorDisplay: self.authorDisplay,
                                        authorId: self.authorId,
                                        selectedPartners: selectedPartners,
                                        selectedPartnersCc: selectedPartnersCc,
                                        selectedPartnersBcc: selectedPartnersBcc,
                                        attachments: self.attachments,
                                        avatarAuthor: self.avatarAuthor,
                                        dateSent: self.dateSent,
                                        categories: self.categories,
                                        recordName: self.recordName,
                                        models: self.models,
                                        resId: self.resId,
                                        isSent: self.isSent,
                                        oldBody: self.oldBody,
                                        body: self.body,
                                        subject: self.subject,
                                        wizardType: self.wizardType,
                                        parentId: self.parentId)
        sentMessages.append(message)
        
        return sentMessages
    }
}

extension MobileSentMessage {
    public mutating func prepare(with parameters: PrepareParameters) {
        self.authorId = parameters.user.partnerID?.id ?? 0
        self.authorDisplay = parameters.user.name ?? ""
        self.avatarAuthor = parameters.user.avatar ?? ""
        
        self.messageId = parameters.replayMessage.id
        self.parentId = parameters.replayMessage.parentID?.id ?? 0
        
        let body = parameters.messagesBody.isEmpty ? parameters.replayMessage.body : parameters.messagesBody
        let lines = body.components(separatedBy: .newlines)
        let html = lines.joined(separator: "<br>")
        self.body = messageWrapperStyle(parameters.replayMessage, newBody: html)
        
        self.subject = parameters.subject ?? parameters.replayMessage.subject ?? ""
        self.resId = parameters.replayMessage.resID
        self.models = parameters.replayMessage.model
        self.recordName = parameters.replayMessage.recordName ?? ""
        self.wizardType = parameters.typeEmail.identifier
        self.oldBody = parameters.replayMessage.body
        
        // Convert ContactsModel for email, cc, and bcc into the required format for partners
        self.selectedPartners = parameters.selectPartnersEmail.map { [4, $0.id] }
        self.selectedPartnersCc = parameters.selectPartnersCc.map { [4, $0.id] }
        self.selectedPartnersBcc = parameters.selectPartnersBcc.map { [4, $0.id] }
        
        // Handle attachments
        self.attachments = parameters.attachments.map { attachment in
            [4, attachment.id]
        }
    }
    
    public func messageWrapperStyle(_ message: MessageModel, newBody: String) -> String {
        let data = """
        \(newBody)
        <div font-style=normal;>
        <br/></div>
        <blockquote>----- Original message ----- <br/>
        Date: \(message.date) <br/>
        From: \(message.authorDisplay) <br/> Subject: \(message.subject ?? "")<br/>
        <br/>\(message.body)
        """
        return data
    }
}
