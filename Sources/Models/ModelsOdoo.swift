//
//  ModelOdoo.swift
//
//
//  Created by Peter on 04.06.2024.
//

import Foundation

public struct ModelOdoo: Decodable {
    public let modelId: Int
    public let model: String
    public let name: String
    
    public init(modelId: Int, model: String, name: String) {
        self.modelId = modelId
        self.model = model
        self.name = name
    }
    
    enum CodingKeys: String, CodingKey {
        case modelId = "id"
        case model
        case name
    }
}
