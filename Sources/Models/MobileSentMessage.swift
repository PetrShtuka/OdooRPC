//
//  MobileSentMessage.swift
//  Oodo Messenger
//
//  Created by Peter on 14.02.2023.
//

import Foundation

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
    public var resId: Int = 0
    public var isSent: Bool = false
    public var oldBody: String = ""
    public var body: String = ""
    public var subject: String = ""
    public var wizardType: String = ""
    public var parentId: Int = 0
    
    public init(messageId: Int = 1, userId: String = "", authorDisplay: String = "", authorId: Int = 0, selectedPartners: [[Int]] = [[]], selectedPartnersCc: [[Int]] = [[]], selectedPartnersBcc: [[Int]] = [[]], attachments: [[Int]] = [[]], avatarAuthor: String = "", dateSent: String = Date().description, categories: String = "", recordName: String = "", models: String = "", resId: Int = 0, isSent: Bool = false, oldBody: String = "", body: String = "", subject: String = "", wizardType: String = "", parentId: Int = 0) {
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
        
        let selectPartnersList = selectedPartners.map { partner in
            return partner[1]
        }
        
        let selectPartnersCcList = selectedPartnersCc.map { partner in
            return partner[1]
        }
        
        let selectPartnersBccList = selectedPartnersBcc.map { partner in
            return partner[1]
        }
        
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
    public mutating func prepare(with user: UserData, replayMessage: MessageModel, typeEmail: MessageSendType, type: MailboxItem, attachments: [AttachmentModel], selectPartnersEmail: [ContactsModel], selectPartnersCc: [ContactsModel], selectPartnersBcc: [ContactsModel], messagesBody: String, subject: String?) {
        self.authorId = user.partnerID?.id ?? 0
        self.authorDisplay = user.name ?? ""
        self.avatarAuthor = user.avatar ?? ""  // Решение для аватара
        
        self.messageId = replayMessage.id
        self.parentId = replayMessage.parentID?.id ?? 0
        
        let body = messagesBody.isEmpty ? replayMessage.body : messagesBody
        let lines = body.components(separatedBy: .newlines)
        let html = lines.joined(separator: "<br>")
        self.body = messageWrapperStyle(replayMessage, newBody: html)
        
        self.subject = subject ?? replayMessage.subject ?? ""
        self.resId = replayMessage.resID
        self.models = replayMessage.model
        self.recordName = replayMessage.recordName ?? ""
        self.wizardType = typeEmail.identifier
        self.oldBody = replayMessage.body
        
        // Convert ContactsModel for email, cc, and bcc into the required format for partners
        self.selectedPartners = selectPartnersEmail.map { [4, $0.id] }
        self.selectedPartnersCc = selectPartnersCc.map { [4, $0.id] }
        self.selectedPartnersBcc = selectPartnersBcc.map { [4, $0.id] }
        
        // Handle attachments
        self.attachments = attachments.map { attachment in
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
