//
//  RPCResponse.swift
//  OdooRPC
//
//  Created by Peter on 30.10.2024.
//

import Foundation

struct RPCResponse<ResultType: Decodable>: Decodable {
    let jsonrpc: String
    let id: Int?
    let result: ResultType?
}
