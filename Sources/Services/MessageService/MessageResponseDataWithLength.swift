//
//  MessageResponseDataWithLength.swift
//  OdooRPC
//
//  Created by Peter on 30.10.2024.
//

import Foundation

public struct MessageResponseDataWithLength: Decodable {
    let length: Int
    let records: [MessageModel]
}
