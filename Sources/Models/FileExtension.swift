//
//  FileExtension.swift
//
//
//  Created by Peter on 06.09.2024.
//

import Foundation

public enum FileExtension: String, Codable, CaseIterable {

    case pdf
    case gif
    case avi
    case zip
    case mp3

    case doc
    case ppt
    case txt
    case mov

    case jpeg
    case jpg
    case png

    public var extensionStr: String {
        return ".\(self.rawValue)"
    }

    public var imageName: String {
        return "fileEx_\(self.rawValue)"
    }

    public var mimeType: String {
        switch self {
        case .pdf:
            return "application/pdf"
        case .gif:
            return "image/gif"
        case .avi:
            return "video/avi"
        case .zip:
            return "application/zip"
        case .mp3:
            return "audio/mp3"
        case .doc:
            return "application/msword"
        case .ppt:
            return "application/vnd.ms-powerpoint"
        case .txt:
            return "text/plain"
        case .mov:
            return "video/quicktime"

        case .jpeg:
            return "image/jpeg"
        case .jpg:
            return "image/jpeg"
        case .png:
            return "image/jpeg"
        }
    }
}
