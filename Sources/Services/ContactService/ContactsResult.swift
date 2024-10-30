//
//  ContactsResult.swift
//  OdooRPC
//
//  Created by Peter on 30.10.2024.
//


struct ContactsResult: Decodable {
    let length: Int
    let records: [ContactsModel]
}