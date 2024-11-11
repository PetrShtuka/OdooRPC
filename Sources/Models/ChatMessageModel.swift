//
//  ChatMessageModel.swift
//  OdooRPC
//
//  Created by Peter on 31.10.2024.
//

import Foundation

public struct ChatMessageModel: Codable, Hashable {
    
   public var accountID: String = ""
   public var channelID: Int?
   public var id: Int?
   public var body: String?
   public var attachmentIds: [Int]?
   public var needAction: Bool?
   public var authorId: Int?
   public var partnerIds: [Int]?
   public var parentId: Int?
   public var deleteUid: Bool?
   public var active: Bool?
   public var model: String?
   public var resId: Int?
   public var time: String?
   public var authorName: String?
   public var hasError: Bool = false
   public var avatar: String?
   
    enum CodingKeys: String, CodingKey {
        case id
        case body
        case attachmentIds = "attachment_ids"
        case needAction = "needaction"
        case authorId = "author_id"
        case partnerIds = "partner_ids"
        case parentId = "parent_id"
        case deleteUid = "delete_uid"
        case active
        case model
        case resId = "res_id"
        case time = "date"
        case avatar = "author_avatar"
    }
    
   public  init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try? container.decode(Int.self, forKey: .id)
       body = try? container.decode(String.self, forKey: .body).removingHTMLTags()
        attachmentIds = try? container.decode([Int].self, forKey: .attachmentIds)
        needAction = try? container.decode(Bool.self, forKey: .needAction)
        if var authorIdArray = try? container.nestedUnkeyedContainer(forKey: .authorId) {
            let authorIdValue = try authorIdArray.decode(Int.self)
            let authorNameValue = try authorIdArray.decode(String.self)
            
            authorId = authorIdValue
            authorName = authorNameValue
        }
        
        
        partnerIds = try? container.decode([Int].self, forKey: .partnerIds)
        parentId  = try? container.decode(Int.self, forKey: .id)
        deleteUid = try? container.decode(Bool.self, forKey: .deleteUid)
        active = try? container.decode(Bool.self, forKey: .active)
        model = try? container.decode(String.self, forKey: .model)
        resId = try? container.decode(Int.self, forKey: .resId)
        time = try? container.decode(String.self, forKey: .time)
        avatar = try? container.decode(String.self, forKey: .avatar)
    }
    
    
    public init(accountID: String, channelID: Int?, id: Int?, body: String?, attachmentIds: [Int]?, needAction: Bool?, authorId: Int?, partnerIds: [Int]?, parentId: Int?, deleteUid: Bool?, active: Bool?, model: String?, resId: Int?, time: String?, authorDisplay: String?, hasError: Bool = false, avatar: String?) {
        self.accountID = accountID
        self.channelID = channelID
        self.id = id
        self.body = body
        self.attachmentIds = attachmentIds
        self.needAction = needAction
        self.authorId = authorId
        self.partnerIds = partnerIds
        self.parentId = parentId
        self.deleteUid = deleteUid
        self.active = active
        self.model = model
        self.resId = resId
        self.time = time
        self.authorName = authorDisplay
        self.hasError = hasError
        self.avatar = avatar
    }
}

public extension ChatMessageModel {
    mutating func setAccountID(_ accountID: String) {
        self.accountID = accountID
    }
    
    mutating func setChannelID(_ channelID: Int) {
        self.channelID = channelID
    }
}

public func parseResultObject(_ resultObject: [String: Any],
                       channelID: Int) -> [ChatMessageModel]? {
    // Attempt to retrieve the records array from resultObject
    guard let recordsArray = resultObject["records"] as? [[String: Any]] else {
        return nil
    }
    
    // Initialize JSONDecoder and set date decoding strategy
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .formatted(dateFormatter()) // Apply custom date format
    
    do {
        // Convert recordsArray to JSON data for decoding
        let jsonData = try JSONSerialization.data(withJSONObject: recordsArray)
        // Decode the data into an array of ChatMessageModel
        var messages = try decoder.decode([ChatMessageModel].self, from: jsonData)
        
        // Set the channelID for each message
        messages = messages.map { var message = $0
            message.setChannelID(channelID)
            return message
        }
        return messages
    } catch {
        // If decoding fails, return nil
        return nil
    }
}

// Helper function to define the date format for JSON decoding
public func dateFormatter() -> DateFormatter {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ" // Example ISO 8601 format
    formatter.locale = Locale(identifier: "en_US_POSIX")
    return formatter
}
