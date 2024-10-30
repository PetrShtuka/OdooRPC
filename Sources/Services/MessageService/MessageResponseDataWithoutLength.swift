//
//  MessageResponseDataWithoutLength.swift
//  OdooRPC
//
//  Created by Peter on 30.10.2024.
//

import Foundation

// Models for decoding the response
public struct MessageResponseDataWithoutLength: Decodable {
    let records: [MessageModel]
}
