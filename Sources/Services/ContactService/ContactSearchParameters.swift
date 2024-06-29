//
//  ContactSearchParameters.swift
//  OdooRPC
//
//  Created by Peter on 20.04.2024.
//

import Foundation

public struct ContactParameters {
    public var searchName: String = ""
    public var searchEmail: String = ""
    var idFilter: IDFilterType?
    public var uid: Int
    public var timeZone: String = ""
    public var language: String = ""
    public var limit: Int = 100
    public var serverVersion: Double = 0.0
    public var lastContactId: Int? = nil
    public var customFields: [String]?
    public var additionalParams: [String: Any]?
    public var sessionId: String
}
