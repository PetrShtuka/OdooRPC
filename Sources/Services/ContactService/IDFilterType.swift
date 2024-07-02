//
//  IDFilterType.swift
//  OdooRPC
//
//  Created by Peter on 20.04.2024.
//

import Foundation

public enum IDFilterType {
    case inFilter([Int])
    case notInFilter([Int])
    
    public func asDomain() -> [Any] {
        switch self {
        case .inFilter(let ids):
            return ["id", "in", ids]
        case .notInFilter(let ids):
            return ["id", "not in", ids]
        }
    }
}
