//
//  ModelOdoo.swift
//
//
//  Created by Peter on 04.06.2024.
//

import Foundation

public struct ModelOdoo {
    public let name: String
    
    public init(name: String) {
        self.name = name
    }
    
//    enum CodingKeys: String, CodingKey {
//        case modelId = "id"
//        case model
//        case name
//    }
}

struct ModulesResponse: Decodable {
    let result: [String]
}
