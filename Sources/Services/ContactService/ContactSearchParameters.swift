//
//  ContactSearchParameters.swift
//  OdooRPC
//
//  Created by Peter on 20.04.2024.
//

import Foundation

public struct ContactParameters {
    var searchName: String = ""
    var searchEmail: String = ""
    var idFilter: IDFilterType?
    var uid: Int
    var timeZone: String = ""
    var language: String = ""
    var limit: Int = 100
    var serverVersion: Double = 0.0
    var lastContactId: Int? = nil
    var customFields: [String]?
    var additionalParams: [String: Any]?
}
