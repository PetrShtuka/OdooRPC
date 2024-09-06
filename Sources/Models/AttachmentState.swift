//
//  AttachmentState.swift
//
//
//  Created by Peter on 06.09.2024.
//

import Foundation

public enum AttachmentState: String, Codable {
  case notUploaded
  case uploading
  case uploaded
  case failed
}
