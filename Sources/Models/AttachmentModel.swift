//
//  AttachmentModel.swift
//
//
//  Created by Peter on 06.09.2024.
//

import Foundation

public struct AttachmentModel: Equatable, Hashable {
    public var id: Int
    public var resModel: String?
    public var resId: Int?
    public var resName: String?
    public var filename: String?
    public var type: String?
    public var data: String?
    public var path: String?
    public var fileMimeType: String?
    public var companyId: Int?
    public var localPath: String?
    public var fileSize: String?
    public var lastOpenedAt: String?
    public var fileExtension: FileExtension?
    public var state: AttachmentState?
    
    public init(id: Int, resModel: String?, resId: Int?, resName: String?, filename: String?, type: String?, data: String?, path: String?, fileMimeType: String?, companyId: Int?, localPath: String?, fileSize: String?, lastOpenedAt: String?, fileExtension: FileExtension?, state: AttachmentState?) {
        self.id = id
        self.resModel = resModel
        self.resId = resId
        self.resName = resName
        self.filename = filename
        self.type = type
        self.data = data
        self.path = path
        self.fileMimeType = fileMimeType
        self.companyId = companyId
        self.localPath = localPath
        self.fileSize = fileSize
        self.lastOpenedAt = lastOpenedAt
        self.fileExtension = fileExtension
        self.state = state
    }
    
    public init(id: Int) {
        self.id = id
        self.resModel = nil
        self.resId = nil
        self.resName = nil
        self.filename = nil
        self.type = nil
        self.data = nil
        self.path = nil
        self.fileMimeType = nil
        self.companyId = nil
        self.localPath = nil
        self.fileSize = nil
        self.lastOpenedAt = nil
        self.fileExtension = nil
        self.state = nil
    }
    
    static func from(json: [String: Any]) -> AttachmentModel? {
        guard let id = json["id"] as? Int else {
            return nil
        }
        
        let fileMimeType = json["mimetype"] as? String
        let filename = json["name"] as? String
        let resModel = json["res_model"] as? String
        let resId = json["res_id"] as? Int
        let resName = json["res_name"] as? String
        let type = json["type"] as? String
        let base64Data = json["datas"] as? String
        let path = json["path"] as? String
        let companyId = json["company_id"] as? Int
        let localPath = json["local_path"] as? String
        let fileSize = json["file_size"] as? String
        let lastOpenedAt = json["last_opened_at"] as? String
        let fileExtension = FileExtension(rawValue: json["file_extension"] as? String ?? "")
        let state = AttachmentState(rawValue: json["state"] as? String ?? "")
        
        var data: String?
        var convertedFileSize: String? = fileSize
        
        if let base64Data = base64Data {
            if let decodedData = Data(base64Encoded: base64Data) {
                data = decodedData.base64EncodedString()
            } else {
                convertedFileSize = nil
            }
        }
        
        return AttachmentModel(id: id, resModel: resModel, resId: resId, resName: resName, filename: filename, type: type, data: data, path: path, fileMimeType: fileMimeType, companyId: companyId, localPath: localPath, fileSize: convertedFileSize, lastOpenedAt: lastOpenedAt, fileExtension: fileExtension, state: state)
    }
}
