//
//  ModelOdoo.swift
//
//
//  Created by Peter on 04.06.2024.
//

import Foundation

public struct ModelOdoo: Decodable {
    public let userId: Int
    public let modelId: Int
    public let model: String
    public let name: String
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case modelId = "id"
        case model
        case name
    }
}
