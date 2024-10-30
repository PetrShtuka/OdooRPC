//
//  OdooResponse.swift
//  OdooRPC
//
//  Created by Peter on 28.10.2024.
//

public struct OdooResponse<T: Decodable>: Decodable {
    let jsonrpc: String
    let id: Int
    let result: T
}
