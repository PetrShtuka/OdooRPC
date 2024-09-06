//
//  AttachmentModel.swift
//
//
//  Created by Peter on 06.09.2024.
//

import Foundation

public struct AttachmentModel: Decodable, Equatable, Hashable {
    
    public var id: Int
    public var resModel: String
    public var resId: Int
    public var resName: String
    public var filename: String
    public var type: String
    public var data: Data?
    public var path: String
    public var fileMimeType: String
    public var companyId: Int
    public var localPath: String
    public var fileSize: String
    public var lastOpenedAt: String
    public var fileExtension: FileExtension?
    public var state: AttachmentState?

    enum CodingKeys: String, CodingKey {
        case id
        case resModel = "res_model"
        case resId = "res_id"
        case resName = "res_name"
        case filename
        case type
        case data
        case path
        case fileMimeType = "file_mime_type"
        case companyId = "company_id"
        case localPath = "local_path"
        case fileSize = "file_size"
        case lastOpenedAt = "last_opened_at"
        case fileExtension = "file_extension"
        case state = "state"
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.id = try container.decode(Int.self, forKey: .id)
        self.resModel = try container.decode(String.self, forKey: .resModel)
        self.resId = try container.decode(Int.self, forKey: .resId)
        self.resName = try container.decode(String.self, forKey: .resName)
        self.filename = try container.decode(String.self, forKey: .filename)
        self.type = try container.decode(String.self, forKey: .type)
        self.path = try container.decode(String.self, forKey: .path)
        self.fileMimeType = try container.decode(String.self, forKey: .fileMimeType)
        self.companyId = try container.decode(Int.self, forKey: .companyId)
        self.localPath = try container.decode(String.self, forKey: .localPath)
        self.fileSize = try container.decode(String.self, forKey: .fileSize)
        self.lastOpenedAt = try container.decode(String.self, forKey: .lastOpenedAt)
        
//        self.fileExtension = try? container.decode(FileExtension.self, forKey: .fileExtension)
//        self.state = try? container.decode(AttachmentState.self, forKey: .state)

        if let base64String = try? container.decode(String.self, forKey: .data) {
            self.data = Data(base64Encoded: base64String)
        } else {
            self.data = nil
        }
    }

    public static func ==(lhs: AttachmentModel, rhs: AttachmentModel) -> Bool {
        return lhs.id == rhs.id
    }
}
